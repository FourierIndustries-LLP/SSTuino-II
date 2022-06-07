Original post available at https://github.com/MCUdude/MegaCoreX/issues/143

Hi there,

Thank you for creating this open-source Arduino core! I recently ran into a serious issue with `arduino-cli` and your core and I wasn't quite able to figure out what exactly happened. My environment is as below:

Hardware:
- Custom board with ATmega4809 (internal 16MHz oscillator), SAMD11 acting as UPDI through `jtag2updi`
- MacBook Pro running macOS 12.1

Software:
- Arduino IDE: 1.8.19
- Arduino CLI: 0.21.0 commit 10107d24

I was recently flashing Arduino programs to my prototype units through `arduino-cli` on a Mac with MegaCoreX 1.0.8. I have previously done this many times before and encountered little to no issues. However, I tried flashing an Arduino program through `arduino-cli` today and noticed that while the program uploaded successfully, subsequent programs could not be uploaded - in effect bricking my boards. 

The only difference I noticed with `arduino-cli` was that it was installing an update today, which I thought to be inconsequential.

```
Downloading missing tool builtin:serial-discovery@1.3.2...
builtin:serial-discovery@1.3.2 downloaded                                       
Installing builtin:serial-discovery@1.3.2...
builtin:serial-discovery@1.3.2 installed
Sketch uses 3428 bytes (6%) of program storage space. Maximum is 49152 bytes.
Global variables use 323 bytes (5%) of dynamic memory, leaving 5821 bytes for local variables. Maximum is 6144 bytes.
avrdude: jtagmkII_initialize(): Cannot locate "flash" and "boot" memories in description
avrdude: jtagmkII_reset(): bad response to reset command: RSP_ILLEGAL_MCU_STATE
avrdude: jtagmkII_close(): bad response to sign-off command: RSP_ILLEGAL_MCU_STATE
```

*^ Full console output of the first time it bricked my board ^*

I confirmed this after a second board had the same Arduino program uploaded successfully through Arduino IDE 1.8.19, but was bricked in an identical sequence of events with `arduino-cli`.

The `-vvvv` dump of avrdude is available at [this GitHub gist](https://gist.github.com/d3lta-v/3ed9a9af7f2e65bfcb978f4c68e754a2). By comparison, I also did an avrdude `-vvvv` dump of a known good board [here](https://gist.github.com/d3lta-v/037b3eaa1a266f62e7e05fed128f805f). It was completely identical up until `avrdude: jtagmkII_reset(): Sending reset command:`, at which the reset command was sent. 

The correct sequence of bytes to be received after the reset command is:
```
avrdude: Recv: . [1b]
avrdude: Recv: . [08] 
avrdude: Recv: . [00] 
avrdude: Recv: . [01] 
avrdude: Recv: . [00] 
avrdude: Recv: . [00] 
avrdude: Recv: . [00] 
avrdude: Recv: . [0e] 
avrdude: Recv: . [80] 
avrdude: Recv: . [ce] 
avrdude: Recv: / [2f] 
```

The sequence of bytes I got instead was (refer to arrows for diff):
```
avrdude: Recv: . [1b] 
avrdude: Recv: . [08] 
avrdude: Recv: . [00] 
avrdude: Recv: . [02]        <---
avrdude: Recv: . [00] 
avrdude: Recv: . [00] 
avrdude: Recv: . [00] 
avrdude: Recv: . [0e] 
avrdude: Recv: . [a5] . [83] <---
avrdude: Recv: + [2b]        <---
avrdude: Recv: l [6c]        <---
```

Unfortunately I did not manage to capture the verbose dump of avrdude commands when the board was bricked. I referred to the [JTAGICE MkII protocol spec sheet](http://www.professordan.com/avr/techlib/techlib8/appnotes/pdf_avr/AVR067.pdf) and noted that 0xa5 is "5.2.10 Operation cannot be performed (RSP_ILLEGAL_MCU_STATE)", but the very next byte for the current mode the MCU is in is not documented (0x83).

Weirdly enough, the commands emitted from the Arduino CLI version and the Arduino IDE version were basically the same as far as fuses are concerned (only fuse1 is different as I had a different setting on the IDE). 

Arduino CLI:

```
"/Users/panziyue/Library/Arduino15/packages/arduino/tools/avrdude/6.3.0-arduino18/bin/avrdude" "-C/Users/panziyue/Library/Arduino15/packages/MegaCoreX/hardware/megaavr/1.0.8/avrdude.conf" -v -V -patmega4809 -cjtag2updi -P/dev/cu.usbmodem14101 -e "-Uflash:w:/private/var/folders/dx/mwn31wlj3db_q1112jfbg5qc0000gn/T/arduino-sketch-269C1E9B0F6B6C5D3659CC2C8E76FDFC/QCTest.ino.hex:i" 
"-Ufuse0:w:0x00:m" "-Ufuse1:w:0x54:m" "-Ufuse2:w:0x01:m" "-Ufuse4:w:0x00:m" "-Ufuse5:w:0xC9:m" "-Ufuse6:w:0x06:m" "-Ufuse7:w:0x00:m" "-Ufuse8:w:0x00:m" "-Ulock:w:0xC5:m"
```

Arduino IDE:

```
/Users/panziyue/Library/Arduino15/packages/arduino/tools/avrdude/6.3.0-arduino18/bin/avrdude -C/Users/panziyue/Library/Arduino15/packages/MegaCoreX/hardware/megaavr/1.0.8/avrdude.conf -v -patmega4809 -cjtag2updi -P/dev/cu.usbmodem14101 -e -Uflash:w:/var/folders/dx/mwn31wlj3db_q1112jfbg5qc0000gn/T/arduino_build_131524/QCTest.ino.hex:i 
-Ufuse0:w:0x00:m -Ufuse1:w:0xF4:m -Ufuse2:w:0x01:m -Ufuse4:w:0x00:m -Ufuse5:w:0xC9:m -Ufuse6:w:0x06:m -Ufuse7:w:0x00:m -Ufuse8:w:0x00:m -Ulock:w:0xC5:m
```

At this point I have not tried using an external UPDI compatible programmer to rescue these two devices, so as far as `jtag2updi` is concerned, it's effectively bricked. I couldn't dump the fuses from these devices to check what's wrong as a result of this as well.

I browsed around forums as well and noticed that there's a few odd instances where the official Arduino Nano Every was bricked with the exact same error in [2017](https://forum.arduino.cc/t/arduino-nano-every-unable-to-upload-program-any-sketch-error-rsp-illegal-mcu-state/960461) and twice in [2021](https://forum.arduino.cc/t/arduino-nano-every-atmega4809-locked-bad-response-to-sign-off-command-rsp-illegal-mcu-state/908016), albeit due to different circumstances. There was another interesting thread in [2021](https://forum.arduino.cc/t/atmega4809-fuse-settings-via-arduino-boards-txt/902643) regarding modifying fuse settings that locked the fella out, **with the exact same errors**. Perhaps it's an issue with setting "corrupted" fuse bits causing the MCU to stop/result in undefined behaviour?

At this stage, I'm not really sure if the issue is inherent of some bug within `arduino-cli`, or an in issue of the interaction of `arduino-cli` with this core and was hoping if you might be able to shed some light on this. What I'm currently speculating is that `arduino-cli` caused some sort of "invalid configuration" to occur. This actually happened to me before but in a less destructive fashion, it failed to program the right frequency fuse and caused serial to output garbage, and it was remedied by updating `arduino-cli` in homebrew at that time.


Update: 

Thanks for the idea and I concur with that UPDI should in theory mean that the controller is "unbrickable" by design. I managed to restore it to working condition with a spare Curiosity Nano (nEDBG) I had lying around by cutting the programming traces out and hooking its UPDI port into my custom board's UPDI pin, while disabling my SAMD11 based `jtag2updi` programmer by pulling its reset pin to ground.

This is the command that fixed the issue: `avrdude -C ~/Library/Arduino15/packages/MegaCoreX/hardware/megaavr/1.0.8/avrdude.conf -v -patmega4809 -ccuriosity_updi -Pusb -e -F` which performed a chip erase with that nEDBG debugger.

My device uses the same firmware and design as the Nano Every (running the Arduino MuxTO firmware, with code derived from [jtag2updi](https://github.com/ElTangas/jtag2updi)) as its mechanism for flashing firmware and serial communications. As a result of the SAMD11's limited flash, I wasn't able to recompile another version of MuxTO that supports [chip erase through interactive mode](https://github.com/ElTangas/jtag2updi/blob/master/README.md#using-with-avrdude) as the non-interactive mode (i.e. simply using `-e -F` as avrdude arguments) doesn't work as recorded by [some others](https://github.com/ElTangas/jtag2updi/issues/44#issuecomment-802211602)...although it is proposed that [avrdude may require changes](https://github.com/ElTangas/jtag2updi/issues/43#issuecomment-1046886009) so one could erase a locked chip without modifying the firmware of the programmer. In my custom board's original layout, it would be quite difficult to rescue the board without an external (non jtag2updi based) UPDI programmer to initiate a chip erase.

Since I was able to unbrick my device, I thought it was time to "brick" it again for science and document the exact sequence of events:

1. Flashed an Arduino program through Arduino IDE -> No issues, even after repeatedly flashing it (as it should be) [Full verbose dump available here](https://gist.github.com/d3lta-v/faa7301fd2d40c5c64fb2dd1da36b2d4)
2. Flashed the same program through CLI -> No issues. [Full verbose dump available here](https://gist.github.com/d3lta-v/feef27181c091c8e4d1a6dfb53c5cbeb)
3. Flashed the same program again through CLI -> program loaded successfully with identical output but the final reset and sign-off commands sent to the MCU failed. [Full verbose dump available here](https://gist.github.com/d3lta-v/e9579ccf601baece5cb1b3c69eb7708d)
4. Flashed the same program through CLI -> Fails completely as the device is locked.

At this point I'm not quite sure on what was the exact difference between `arduino-cli` and Arduino IDE that caused this error. The only one difference I spotted in the avrdude command was that `arduino-cli` used `-V` which disabled automatic verification. I will follow up this issue with `arduino-cli`'s repo, thanks for your help :)

Update:

I tried Arduino-CLI again but with `-t` to enforce a verification pass during upload and there were no further issues. I now believe that the lack of the `-V` argument is the cause. 
