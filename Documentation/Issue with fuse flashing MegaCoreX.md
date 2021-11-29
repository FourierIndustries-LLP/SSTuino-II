# Issue with fuse flashing in MegaCoreX

I am currently developing my own board with a blend of design choices: 

- Uses a SAMD11 for a combined UART+UPDI to USB interface, with JTAG2UPDI and the need for 1200bps touch (identical to the Arduino Nano)
- Uses an ATmega4809
- Uses Arduino Uno Wifi pinout and is attached to an onboard ESP32 Wi-Fi chipset

I modified the core by duplicating the Nano Every's board definition and changed the `build.variant` to `uno-wifi` for that specific pinout, while still retaining the other properties for a SAMD11 based programmer (1200bps touch, JTAG2UPDI).

```
4809.menu.pinout.sstuinoii=SSTuino II
4809.menu.pinout.sstuinoii.build.variant=uno-wifi
4809.menu.pinout.sstuinoii.upload.tool=avrdude_nanoevery
4809.menu.pinout.sstuinoii.upload.use_1200bps_touch=true
4809.menu.pinout.sstuinoii.upload.protocol=jtag2updi
4809.menu.pinout.sstuinoii.program.extra_params=-P{serial.port} -e
4809.menu.pinout.sstuinoii.build.compat=
```

I started running into UART issues when I changed the board frequency from 20MHz to 16MHz (and by extension, all clock speeds that depend on the 16MHz oscillator). I tried to dump the fuses from the ATmega4809 and found out that the fuses were not burnt, meaning that while `F_CPU` was altered, the relevant fuse was never changed to reflect the correct frequency.

The original version of the upload pattern used by the `avrdude_nanoevery` is:

```
tools.avrdude_nanoevery.upload.pattern="{runtime.tools.avrdude.path}/bin/avrdude" "-C{runtime.platform.path}/avrdude.conf" {upload.verbose} {upload.verify} -p{build.mcu} -c{upload.protocol} {program.extra_params} "-Uflash:w:{build.path}/{build.project_name}.hex:i" {bootloader.fuse0} {bootloader.fuse1} {bootloader.fuse2} {bootloader.fuse4} {bootloader.fuse5} {bootloader.fuse6} {bootloader.fuse7} {bootloader.fuse8} {bootloader.lock}
```

It uploads the program perfectly, but does not upload any of the fuses.

The upload pattern below burns a single fuse, and it does the job perfectly fine, but only burns a fuse.

```
tools.avrdude_nanoevery.upload.pattern="{runtime.tools.avrdude.path}/bin/avrdude" "-C{runtime.platform.path}/avrdude.conf" {upload.verbose} {upload.verify} -p{build.mcu} -c{upload.protocol} {program.extra_params} "-Ufuse5:w:0xc9:m"
```

I tried to put the `-Uflash` parameter to the last part of the command like the example below, but that didn't help either: 

```
tools.avrdude_nanoevery.upload.pattern="{runtime.tools.avrdude.path}/bin/avrdude" "-C{runtime.platform.path}/avrdude.conf" {upload.verbose} {upload.verify} -p{build.mcu} -c{upload.protocol} {program.extra_params} {bootloader.fuse0} {bootloader.fuse1} {bootloader.fuse2} {bootloader.fuse4} {bootloader.fuse5} {bootloader.fuse6} {bootloader.fuse7} {bootloader.fuse8} {bootloader.lock} "-Uflash:w:{build.path}/{build.project_name}.hex:i"
```

An alternate version would be to upload only fuses, but no program:

```
tools.avrdude_nanoevery.upload.pattern="{runtime.tools.avrdude.path}/bin/avrdude" "-C{runtime.platform.path}/avrdude.conf" {upload.verbose} {upload.verify} -p{build.mcu} -c{upload.protocol} {program.extra_params} {bootloader.fuse0} {bootloader.fuse1} {bootloader.fuse2} {bootloader.fuse4} {bootloader.fuse5} {bootloader.fuse6} {bootloader.fuse7} {bootloader.fuse8} {bootloader.lock}
```

I'm wondering if there is a known issue specifically with Nano Every style of uploading the flash and uploading fuses in tandem with the flash memory.
