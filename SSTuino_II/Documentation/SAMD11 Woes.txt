# SAMD11 Failed to write memory using OpenOCD

This little writing is all about the insanity that is debugging this SAMD11 and why it's not working:

## Environment:

**Software**:
* macOS 11.5.2
* OpenOCD 0.11.0 installed through Homebrew

**Hardware**:
* [NanoDAP (CMSIS-DAP compatible)](https://github.com/wuxx/nanoDAP)
* Custom board

## Problem

I designed a custom board with an ATSAMD11D14A-SSNT onboard, to act as an USB-UART interface and UPDI programmer similar to the Arduino Nano Every's design:

<insert Arduino every's diagram here>

I was attempting to flash a generic bootloader onto the SAMD11 using the helpful [Breadboard SAMD11 Tutorial](https://funwithsoftware.org/posts/2019-09-01-breadboard-samd11-part1.html), but the OpenOCD prompt threw errors in the console log below:

```
Open On-Chip Debugger 0.11.0
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
DEPRECATED! use 'adapter srst delay' not 'adapter_nsrst_delay'
DEPRECATED! use 'adapter srst pulse_width' not 'adapter_nsrst_assert_width'
Info : CMSIS-DAP: SWD  Supported
Info : CMSIS-DAP: JTAG Supported
Info : CMSIS-DAP: FW Version = 0254
Info : CMSIS-DAP: Serial# = 0700000105dbff343634564643237741a5a5a5a597969908
Info : CMSIS-DAP: Interface Initialised (SWD)
Info : SWCLK/TCK = 1 SWDIO/TMS = 1 TDI = 0 TDO = 1 nTRST = 0 nRESET = 1
Info : CMSIS-DAP: Interface ready
Info : clock speed 400 kHz
Info : SWD DPIDR 0x0bc11477
Info : at91samd11d14ass.cpu: hardware has 4 breakpoints, 2 watchpoints
Error: at91samd11d14ass.cpu -- clearing lockup after double fault
Polling target at91samd11d14ass.cpu failed, trying to reexamine
Info : at91samd11d14ass.cpu: hardware has 4 breakpoints, 2 watchpoints
Info : starting gdb server for at91samd11d14ass.cpu on 3333
Info : Listening on port 3333 for gdb connections
target halted due to debug-request, current mode: Thread 
xPSR: 0x91000000 pc: 0x000004a0 msp: 0x20000ffc
target halted due to debug-request, current mode: Thread 
xPSR: 0x91000000 pc: 0x000004a0 msp: 0x20000ffc
** Programming Started **
Info : SAMD MCU: SAMD11D14ASS (16KB Flash, 4KB RAM)
Info : SWD DPIDR 0x0bc11477
Error: Failed to write memory at 0x00000040
Error: samd_write: 889
Error: error writing to flash at address 0x00000000 at offset 0x00000000
embedded:startup.tcl:530: Error: ** Programming Failed **
in procedure 'script' 
at file "embedded:startup.tcl", line 26
in procedure 'program' called at file "openocd.cfg", line 17
in procedure 'program_error' called at file "embedded:startup.tcl", line 595
at file "embedded:startup.tcl", line 530
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
```

The following diagram is a section of my own design which involved the SAMD11:

<insert my own design here>

My `openocd.cfg` is as below: 

```
source [find interface/cmsis-dap.cfg]
transport select swd

set CHIPNAME at91samd11d14ass
source [find target/at91samdXX.cfg]

reset_config srst_nogate

adapter_nsrst_delay 100
adapter_nsrst_assert_width 100

init
targets
reset halt

at91samd bootloader 0
program sam_ba_Generic_D11D14AS_SAMD11D14AS.bin verify
at91samd bootloader 4096
reset
shutdown
```

## Steps taken

### Hardware inspection

I have previously checked my wiring and design, and did not find any issues that indicated a fault in wiring, although an extra pair of eyes would be helpful. I have tried this on 2 boards and got identical results, which hopefully rules out a faulty chip or board.

I have also swapped the cables around and have tested all hookup cables for continuity. All cables are known good.

### Environment

As I'm a first-time ARM microcontroller user (previously only tinkered with AVRs), I'm not very familiar with some of the tools used. My first instinct was perhaps a specific software environment that resulted in the error.

I have attempted this in a Windows 10 environment as well, with OpenOCD 0.10.0 instead of 0.11.0, and resulted in identical console output.

### Chip-erase

I tried running the `at91samd chip-erase` through the OpenOCD telnet interface, followed by running OpenOCD as usual with the .cfg file, but that does not appear to resolve any issues. 

### Reducing frequency

I also attempted to reduce the speed of the adapter from 400kHz to 40kHz as outlined in an [Arduino.cc forum post](https://forum.arduino.cc/t/flash-problem-with-samd21g18a-using-openocd-swd/609867/4), but that did not solve anything; the output was identical.

## Other possibilities to explore

### Lack of an external crystal?

[One post](https://community.atmel.com/comment/2541201#comment-2541201) on a tangentially related device, a SAMD21, proposed that a lack of an external crystal might be the issue. However, as there is no program loaded to the microcontroller, I doubt that it's looking for an external crystal, especially when the tutorial I followed made no mention of a crystal.

### Something wrong with my CMSIS-DAP?

My CMSIS-DAP compatible programmer might be faulty, hopefully this is not the case as I'm not quite ready to throw down the cash for an Atmel-ICE :')