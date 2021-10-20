# SAMD11 Woes, part 2

The SAMD11D14A (hereby referred to as SAMD11, not to be confused with the other variants like the C14) solution for a unified UPDI programmer and TTL serial device is elegant and cheap to implement, relative to the more in demand USB-UART chips that we've seen go out of stock everywhere, with existing stock rising to sky-high prices.

However, it is not without its downsides, as shown in the badly documented procedures and ill-maintained repositories, the SAMD11 approach to solving the two-birds-in-one-stone UPDI+UART problem is hardly a straightforward one.

## Rough overview

The SAMD11 acts as a bridge between the host computer's USB port  and the Mega4809, and utilises a total of 3 protocols: USB, UPDI and Serial. 

The SAMD11 is quite different from the AVR microcontrollers that we've seen so far, but are also similar in some major ways. For example, the SAMD11 has a bootloader that allows users to flash programs directly through its native USB port without having to use its specialised programming port called SWD. This is similar to how AVR microcontrollers can be flashed directly with their Serial ports instead of going through a complicated AVR-ISP.

On the firmware side, this implementation of a hybrid adapter, called MuxTO, exposes 3 peripherals: the USB port and 2 Serial ports. One of the Serial ports is bitbanged to simulate a UPDI interface, connected to USB. The other Serial port communicates with the Mega4809, and forwards information to and from this physical Serial port to USB as a virtual Serial port. 

## Prelude

The first problem started when I attempted uploading the bootloader: OpenOCD refused to upload regardless of the settings I used. I eventually solved the issue by using PyOCD for actual erasure and uploading of flash, while using OpenOCD to perform maintenance tasks such as locking the boot sector (4096 bytes). 

## The "last known working"

The last known working method I used to upload the MuxTO firmware is as below:

1. Connect the board to an SWD programmer
2. Erase the chip with `pyocd erase -t atsamd11d14as --chip --pack ~/Downloads/Microchip.SAMD11_DFP.2.5.61.atpack`
3. Flash the bootloader with `pyocd flash -t atsamd11d14as --base-address 0x0 sam_ba_arduino_MuxTO_SAMD11D14AM.bin --pack ~/Downloads/Microchip.SAMD11_DFP.2.5.61.atpack`
4. Protect the bootloader by executing a custom OpenOCD script to set the bootloader length to 4096 bits. Run `sudo openocd -f protect_bootloader.cfg`
5. Flash the rest of the firmware with `pyocd flash -t atsamd11d14as ~/Library/Arduino15/packages/arduino/hardware/megaavr/1.8.7/firmwares/MuxTO/MuxTO.hex --pack ~/Downloads/Microchip.SAMD11_DFP.2.5.61.atpack`

The alternative using `bossac` and the native USB port would be to replace step 5 with: Flash the rest of the firmware with `./bossac --port=/dev/cu.usbmodem14101 -U true -i -e -w -v ~/Library/Arduino15/packages/arduino/hardware/megaavr/1.8.7/firmwares/MuxTO/MuxTO.bin -R`.


## The problem

The SAMD11 solution worked flawlessly for its 1st goal: to flash the Mega4809 target through UPDI. However, the 2nd goal, which is to deliver a serial interface bridge between USB at the ATmega4809's serial port, had serious issues. Getting the serial port to write strings to the host computer resulted in consistently garbled text, implying there's something wrong with the serial signal timings. 

The flow of data is as below:

```
[ATmega4809] -> (Serial) -> [SAMD11] -> (USB) -> [USB on host computer]
```

The garbled text seems to have a consistency to it, and is not resolved by changing around the serial configuration (adding parity and stop bits, changing the baud rate).

## Possibilities

The possibilities here are ordered in easiest to hardest to identify and/or fix.

### Board design or build

It could possibly be a design/build issue with the board, with how thin the serial lines are, they might have caused signal integrity issues. However, at these low speeds, signal integrity is very unlikely to be a concern...

This possibility of a build issue can be more or less eliminated by flashing the firmware to a different board, but for design issue that would need a more skilled pair of eyes to take a look...

### Flash overfill

My first suspicion focused on the bootloader and program size. The MuxTO firmware is known to be too large to feasibly fit into the flash. I was unable to flash the firmware through the native USB port with `bossac` as it complained about flash overfill, but was able to flash the firmware over SWD. This is weird and possibly implies a flash corruption, which will certainly explain the corrupted transmission when transmitting back to the host.

Through a flash dump and by comparing the hex files of the original and the data retrieved from the chip, we might be able to inspect what went wrong with the flashing process (and whether PyOCD overfilled the flash without warning the user). This issue can be extended to my next point, which would be an inherent issue with the firmware provided on official repositories.

### Inherent issue with the firmware or build environment

We preferably want to have a copy of the exact build environment (including pinning down the exact `arm-eabi-g++` toolchain) to ensure that the build passes with no problems or overflows.

Alternatively...it appears from some forum posts imply that a newer compiler might fix the issues. Alternatively, an older version of MattairTech's SAMD11 Core might also be the key to the fix, although all of this are just speculations.

### Mega4809 at fault?

All of our efforts have focused on the SAMD11, but it's also possible that the Mega4809 was at fault. `MCUdude/MegaCoreX` repository had [Issue #59](https://github.com/MCUdude/MegaCoreX/issues/59) saying that the Serial baud rate was incorrect at a certain clock speed, due to a very specific host and client configuration. The author said that it is possibly a chip level issue on the 4809 (internal oscillator being out of whack), while the contributor said it is likely an issue with the host machine. 

Given this precedence, an out-of-whack oscillator theory may not be far fetched. SAMD11 is able to calibrate its own oscillator through its USB host, but the Mega4809 has no such capability. If this was really the fault of the Mega4809, it means we may have to "eat up" some of the responsibility through either a partial redesign, or to perform board-level repairs as and when it fails QC.

### Mega4809 at fault: validation

This theory might be able to be validated through a serial monitor on any of the Mega4809's other serial pins (although this may not be a perfect fix).

## Recreating the build chain

Given the lack of Arduino's official documentation on the matter, it is very difficult to recreate their build chain. 

To recreate Arduino's build chain, we need to construct a timeline of how they built MuxTO:

* Dec 2017 - The last stable version of `mattairtech/ArduinoCore-samd` was introduced, 1.6.17
* June 2018 - The last beta version of `mattairtech/ArduinoCore-samd` was introduced, 1.6.18-beta-b1
* May 2019 - Nano Every is announced, MuxTO bootloader and modifications added to `arduino/ArduinoCore-samd/muxto` branch (bootloader) <- need to find out which version of `mattairtech/ArduinoCore-samd` was used around this time. According to the commits, they were using the bleeding edge beta release
* June 2019 - first units of Nano Every is shipped
* July 2019 - Issue #51 was lodged on `arduino/ArduinoCore-megaavr` that the serial interface locks up when transferring >128 chars
* Aug 2019 - Issue #51 was patched in `arduino/ArduinoCore-samd/muxto`
* Sept 2019 - Issue #52 was flagged out and some improvements were made to the bootloader. This is when the bootloader was last updated. You can go to [this link](https://github.com/arduino/ArduinoCore-megaavr/pull/52) and proceed to the files changed section to download that particular build of MuxTO.
* May 2021 - Issue #103 was filed in `arduino/ArduinoCore-megaavr` that the custom firmware was too large. The creator of MuxTO [commented](https://github.com/arduino/ArduinoCore-megaavr/issues/103#issuecomment-849440652) that using a newer compiler might fix the issue. Eventually someone set up a CI workflow for MuxTO using `mattairtech/ArduinoCore-samd` 1.6.17 (which every build failed :^))


## Allocation of boot flash

0-4096 bytes [4096]: Bootloader
4097-16384 bytes [12288]: Program

It appears that the latest version of the precompiled MuxTO firmware fully bursts the 12288 byte cap allocated to the program.

## Conclusion

Overall quite the frustrating experience with the SAMD11 as a universal UART+UPDI gateway. 

We can try the old firmware compiled by the firmware author in [this link](https://github.com/arduino/ArduinoCore-megaavr/issues/51#issuecomment-517702530)




