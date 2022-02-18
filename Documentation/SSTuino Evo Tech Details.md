# SSTuino Evo Technical Information

This document outlines the deep technical information regarding the SSTuino Evo ("the device") and its constituent modules on the board ("module"), ensuring a high level of design stability, documentation and conformity to standards.

{{TOC}}

## Board layout

The board is routed in imperial units on a 12.5 mil (mili-inch, thousandths of an inch, 1/1000).

Power traces are mostly 24-16 mils, while signal traces are 10 mils standard, going down to a minimum of 8 mils when needed.

Isolate is set at 10 mils, same as majority of signal traces to ensure good manufacturability. 

Text is set at 32 mils, 14% ratio for component identifiers for optimal legibility across manufacturers.

## External Interface (pins)

The pinout of the device is as follows:

**Left Side:**

| Pin |    Name   | Purpose                   |
| :-: | :-------- | :------------------------ |
|  1  |   SWDIO   | COM: Programming port     |
|  2  | RST (PF6) | MCU: Reset (active low)   |
|  3  |    3.3V   | Power, 3.3V out           |
|  4  |   SWCLK   | COM: Programming port     |
|  5  |  A0 (PD0) | MCU: Analog in            |
|  6  |  A1 (PD1) | MCU: Analog in            |
|  7  |  A2 (PD2) | MCU: Analog in            |
|  8  |  A3 (PD3) | MCU: Analog in            |
|  9  |  A4 (PD4) | MCU: Analog in            |
|  10 |  A5 (PD5) | MCU: Analog in            |
|  11 |  ESP/SDA  | ESP: I2C SDA pin          |
|  12 |  ESP/SCL  | ESP: I2C SCL pin          |
|  13 |   ESP/EN  | ESP: EN pin (active high) |
|  14 |  ESP/IO0  | ESP: IO0 pin for bootup   |
|  15 |     NC    |                           |
|  16 |     NC    |                           |
|  17 |   ESP/TX  | ESP: UART Tx (5v logic)   |
|  18 |   ESP/RX  | ESP: UART Rx (5v logic)   |
|  19 |    GND    | Ground                    |
|  20 |     5V    | Power, 5V out/in          |

**Right Side:** 

| Pin |     Name     | Purpose                          |
| :-: | :----------- | :------------------------------- |
|  1  |    RESETN    | COM: Programming port            |
|  2  | 21 (SCL/PA3) | MCU: I2C SCL pin                 |
|  3  | 20 (SDA/PA2) | MCU: I2C SDA pin                 |
|  4  | AREF (7/PD7) | MCU: AREF pin                    |
|  5  |      GND     | GND                              |
|  6  |   13 (PE2)   | MCU: digital IO 13               |
|  7  |   12 (PE1)   | MCU: digital IO 12               |
|  8  |   11 (PE0)   | MCU: digital IO 11               |
|  9  |   10 (PB1)   | MCU: digital IO 10 (PWM capable) |
|  10 |    9 (PB0)   | MCU: digital IO 9 (PWM capable)  |
|  11 |    8 (PE3)   | MCU: digital IO 8                |
|  12 |    7 (PA1)   | MCU: digital IO 7                |
|  13 |    6 (PF4)   | MCU: digital IO 6 (PWM capable)  |
|  14 |    5 (PB2)   | MCU: digital IO 5 (PWM capable)  |
|  15 |    4 (PC6)   | MCU: digital IO 4                |
|  16 |    3 (PF5)   | MCU: digital IO 3 (PWM capable)  |
|  17 |    2 (PA0)   | MCU: digital IO 2                |
|  18 |    1 (PC4)   | MCU: digital IO 1 (TX)           |
|  19 |    0 (PC5)   | MCU: digital IO 0 (RX)           |

This needs further validation with the MegaCoreX pin designations.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | Pending |
| Logic Validation  | Pending |

## USB Interface

### USB 2.0 Type C Plug

This module includes the Type-C (USB 2.0 protocol only) receptacle and the appropriate CC1 and CC2 pull-down resistors of 5.1kOhm 0402 SMD resistors. 

For standards surrounding the USB PD protocol for Type-C, please refer to [Microchip's AN1953 Application Note](http://ww1.microchip.com/downloads/en/appnotes/00001953a.pdf), section 3.2.

It is very similar to a [reference design made by Tyler Ward](https://www.scorpia.co.uk/2016/03/17/using-usb-type-c-on-hobyist-projects/)

| Validation Type   | Result |
| :---------------- | :----- |
| Pinout Validation | PASS   |
| Logic Validation  | PASS   |

The shield of the USB Connector is connected to ground, as per design reference from many designs such as the Adafruit Feather series. A potential future improvement is to connect it to an RC circuit of 4.7nF and 1MOhm components. As mentioned in the SAMD11 data sheet, "Tying the shield directly to ground would create a direct path from the ground plane to the shield, turning the USB cable into an antenna. To limit the USB cable antenna effect, it is recommended to connect the shield and ground through an RC filter.".

### Overcurrent and ESD Protection

This module protects the rest of the device from dangerous electrical conditions, namely overcurrent and electrostatic discharge (ESD). 

The overcurrent protection is handled by a [Littelfuse 1206L075THYR](https://datasheet.lcsc.com/lcsc/1810111934_Littelfuse-1206L075THYR_C99563.pdf) polyfuse packaged in 1206, which cuts off at 6V, 0.75A, with a maximum time to trip of 0.2s at 8A.

ESD protection is handled by a [TechPublic TPUSBLC6](https://datasheet.lcsc.com/lcsc/2005211235_TECH-PUBLIC-TPUSBLC6-2SC6_C558442.pdf) TVS diode array specifically designed for USB 2.0 interfaces.

| Validation Type   | Result |
| :---------------- | :----- |
| Pinout Validation | PASS   |
| Logic Validation  | PASS   |

### Serial Interface

#### Hardware

The serial interface of the device is provided by an ATSAMD11D14A-SSUT/SSNT (20-pin SOIC) ARM Cortex-M0 processor acting as a USB to TTL Serial and USB to UPDI two-in-one converter. This design is based on the Arduino Nano Every, modified to use a larger 20-pin SOIC chip due to board density constraints as well as the 2020/2021 global chip shortage.

The chip itself contains a pinout for RESETN, SWDIO and SWCLK (standard ARM MCU programming port using CWSIS-DAP). Keep in mind that all of this is 3.3V I/O.

The chip is supported by a 0.1uF (100nF) capacitor for decoupling.

RESETN (PA28) and SWCLK (PA30) is tied to logic high through a 4.7kOhm resistor, while SWDIO (PA31) is floating. This is validated.

PA24 and PA25 on the MCU are connected to USB D- and D+ respectively. This pinout is validated.

PA14 and PA15 are programmed as a normal serial port, bit-banged to UPDI spec, and goes through bidirectional level shifting `(3.3V<->5V)`. This pinout is validated.

PA22 and PA23 are the TX and RX lines respectively. Both of them go through bidirectional voltage shifting `(3.3V<->5V)`.

The only component that was not integrated with this design compared with the Arduino Nano Every are the two LED lights sitting on the TX/RX lines.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

#### Software

The software of the Serial Interface shall convert USB signals to TTL-Serial and Atmel UPDI signals for programming and communication between the host computer and the device.

Reprogramming the software on the SAMD11 requires a CMSIS-DAP ARM programmer running at 3.3V logic levels, to target the RESETN, SWDIO and SWCLK pins exposed on the board. Power is still provided by 5V and GND.

The [breadboard SAMD11 tutorial](https://funwithsoftware.org/posts/2019-09-01-breadboard-samd11-part1.html) is an excellent place to start for ARM-based firmware flashing.

The full procedures are [here](https://www.avrfreaks.net/comment/2832921#comment-2832921).

How to load the Bootloader:

1. Install OpenOCD on your Mac if you haven't already: `brew install openocd`
2. Create a folder for two files: the bootloader file itself (looks like `sam_ba_arduino_MuxTO_SAMD11D14AM.bin`) and the `openocd.cfg` file
3. Copy the SAMD11 tutorial's default code for OpenOCD into the configuration file and edit the file name
4. Type `sudo openocd` to begin programming

How to load the Bootloader (PyOCD version)

1. Install PyOCD if you have not: `brew install libusb; python3 -mpip install -U pyocd`
2. Create a folder for 3 important files: the target chip's .pack file, the programmer's .pack file, and the bootloader
3. Download the bootloaders from the [Arduino Core SAMD MuxTO branch repo](https://github.com/arduino/ArduinoCore-samd/tree/muxto/bootloaders/zero/binaries)
4. Erase the chip with `pyocd erase -t atsamd11d14as --chip --pack ~/Downloads/Microchip.SAMD11_DFP.2.5.61.atpack`
5. Execute the command `pyocd flash -t atsamd11d14as --base-address 0x0 sam_ba_arduino_MuxTO_SAMD11D14AM.bin --pack ~/Downloads/Microchip.SAMD11_DFP.2.5.61.atpack`
6. Protect the bootloader by executing a custom OpenOCD script to set the bootloader length to 4096 bits. Run `sudo openocd -f protect_bootloader.cfg`

After the Bootloader is loaded onto the SAMD11, it's time to load the firmware. You might want to compile the firmware for yourself first with the [steps in this guide](https://forum.arduino.cc/t/compiling-and-loading-the-muxto-code/627145)

1.  Add board manager URL: 
2.  Install MattairTech SAM D|L|C core for Arduino - Beta build v1.6.18-beta-b1
3.  Download **bootloader** binary blob from 
4.  Flash bootloader to device
5.  Short SWDIO to GND
6.  Flash the MuxTO **firmware** to device with the following command over the native USB port: 
        
    ```
    ./bossac --port=/dev/cu.usbmodem14101 -U true -i -e -w -v ./MuxTO_SST.bin -R
    ```

Alternatively, it should be possible to flash the hex file directly to the system through the same CMSIS-DAP PyOCD interface by running the following command: `pyocd flash -t atsamd11d14as ~/Library/Arduino15/packages/arduino/hardware/megaavr/1.8.7/firmwares/MuxTO/MuxTO.hex --pack ~/Downloads/Microchip.SAMD11_DFP.2.5.61.atpack`

At this point, we're not done yet. We need to patch MegaCoreX's `boards.txt` with our own custom configuration to let MuxTO work through a hacky version of JTAG2UPDI:

```
################################################
4809.menu.pinout.sstuinoii=SSTuino II
4809.menu.pinout.sstuinoii.build.variant=uno-wifi
4809.menu.pinout.sstuinoii.upload.tool=avrdude_nanoevery
4809.menu.pinout.sstuinoii.upload.use_1200bps_touch=true
4809.menu.pinout.sstuinoii.upload.protocol=jtag2updi
4809.menu.pinout.sstuinoii.program.extra_params=-P{serial.port} -e
4809.menu.pinout.sstuinoii.build.compat=
#################################################
```

If you need to build from source, you will need to patch Arduino specific changes to MT's core. 

Compilation options available here: `arduino:samd:muxto:float=default,config=enabled,clock=internal_usb,timer=timer_732Hz,bootloader=4kb,serial=two_uart,usb=cdc`

[Link](https://github.com/arduino/ArduinoCore-megaavr/blob/master/.github/workflows/compile-muxto.yml)

If you wish to change the MuxTO firmware without recompilation, you can directly edit the `MuxTO.bin` file using a hex editor. 

For example, the USB VID and PID can be edited at offset 0x2E3C, with an order of `[VID LSB][VID MSB][PID LSB][PID MSB]` (least and most significant *byte*, not bit). For more details, see this [line of code in Arduino Core](https://github.com/arduino/ArduinoCore-samd/blob/9f91accecc8298976670234e4d6ac0afef5c7a39/bootloaders/zero/sam_ba_usb.c#L47)

If the bootloader + an existing firmware is already on the chip, short SWDIO to GND to enter bootloader mode for direct USB programming.

During the flashing of the ATmega4809 target, the programmer type needs to be JTAG2UPDI, as it essentially pretends to be a JTAG device, with a bit of a special 1200bps handshake in between to initiate the UPDI process. You will need to specify the target serial port.

These were the fuses returned by avrdude:

```
fuse0: 0x0 (WDTCFG)
fuse1: 0x0 (BODCFG)
fuse2: 0x2 (OSCCFG)
fuse4: 0x0
fuse5: 0xe4 (SYSCFG0)
fuse6: 0x7 (SYSCFG1: startup time only)
fuse7: 0x0 (APPEND: end of application section)
fuse8: 0x0 (BOOTEND: end of boot section)
lock: 0xc5 (LOCK)
```

`OSCCFG` is configured as: 0x02, same as default factory setting, which is to run at 20MHz, with no oscillator lock meaning that calibration registers can be adjusted at runtime.

`SYSCFG0` seems to be configured as: 0xe4. Note that default factory value is 0xCO, which echoes exactly the same fuse settings (but not as corrupted)! It appears that the reserved fuses are not even properly cleared as 0? The correct hex value is 0xc9,

**Current chip settings**: 

* CRCSRC: BOOTAPP
* RSTPINCFG: GPIO <- this is interesting! Because it should have been set to RESET. A fuse configuration error?
* EESAVE: EEPROM erased by chip erase

**Correct settings as per board definition**:

* CRCSRC: BOOTAPP
* RSTPINCFG: RESET
* EESAVE: EEPROM NOT erased by chip erase

`LOCK` is as factory default, no need to change as altering it will lock the chip.

Comparison between the two settings:

```
0xe4: 1110 0100
0xc9: 1100 1001
```

**Further Reading**

* [PyOCD Tutorial](https://www.hackster.io/sabas1080/how-to-debug-hardware-with-openocd-or-pyocd-e7e718)
* [PyOCD Tutorial #2](https://chowdera.com/2021/08/20210825013223713b.html)
* [PiOCD GitHub](https://github.com/pyocd/pyOCD)
* [Keil .pack library](https://www.keil.com/dd2/pack/#!#third-party-download-dialog)
* [OpenOCD CPU configuration](https://openocd.org/doc/html/CPU-Configuration.html)
* [OpenOCD Debug Adapter config](https://openocd.org/doc/html/Debug-Adapter-Configuration.html)
* [OpenOCD Config File Guide](https://openocd.org/doc/html/Config-File-Guidelines.html)

### Level Shifting

The level shifting portion of the USB interface is handled by a dual transistor BSS138PS IC and a single transistor BSS138PW, which shifts 3.3V to 5V and vice versa, fully bidirectional.

All transistors use 4.7kOhm resistors.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

## Voltage Regulator

The onboard voltage regulation is handled by an AMS1117-3.3 Low Dropout (LDO) linear voltage regulator. The voltage regulator is responsible for delivering adequate current and stable power at the correct voltage to the ESP32 and ATSAMD11D14A chips. 

This particular type of LDO is cheap and widely available, but is not the most efficient, especially at low power, due to its higher quiescent current.

For reference, [Andrea's video on ESP32 boards](https://www.youtube.com/watch?v=ajt7vtgKNNM) offers a fantastic comparison of the different power supplies used by the different boards. Future boards may use more efficient power conversion circuitry.

The current voltage regulator circuitry has an input and output capacitor of 10uF. Further decoupling capacitors are closer to the individual chips and will not be discussed in this section.

| Validation Type   | Result |
| :---------------- | :----- |
| Pinout Validation | PASS   |
| Logic Validation  | PASS   |

## Main Controller

### Pinout

The pinout of the main controller needs to be validated against the datasheet and firmware. The current firmware we are intending to run is the MegaCoreX (Uno Wifi Rev2) configuration, with the following settings:

* Chip: 4809
* Clock: Internal 16MHz
* BOD: 2.6V
* Pinout: Uno Wifi
* Reset pin: Reset
* Bootloader: No
* Programmer: JTAG2UPDI

```
#define SPIWIFI_SS    35   // Chip select pin PF2
#define SPIWIFI_ACK   36   // a.k.a BUSY or READY pin PF3
#define ESP32_RESETN  29   // Reset pin PA7
#define ESP32_GPIO0   28   // GPIO0 PA6
// MOSI: PC0
// MISO: PC1
// SCK:  PC2
```

### Reset switch

The reset switch is tied to PF6, which is pulled to logic high by a 100kOhm resistor. This design has been proven in the Curiosity Nano demo board.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

### Decoupling

The decoupling capacitors C7-C12 are important in decoupling the MCU from the rest of the electrical noise on the board. VDD1 and AVDD uses 0.1uF capacitors, while VDD2 and PD7/AREF uses a 0.1uF and 4.7uF capacitor in parallel.

This design has been validated with the Arduino Uno Wifi's design for correctness.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

### Built-in LED

The device comes with a user-controllable built in LED on PD06 (A6), which can be invoked with the LED_BUILTIN. It is connected to a 1kOhm resistor to prevent burnout. (Might want to calculate the LED's brightness here) This design is validated against the Arduino Uno Wifi Rev2.

Need to double check the LED's polarity markings for a proper placement.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

## ESP32 Module

The ESP32 Module acts as a wireless coprocessor and handles Wi-Fi and Bluetooth connections. Given the right tools, it can be modified or "hacked" to behave as if it's the master. The design of the ESP32 Module can be traced back to the design of the [Adafruit AirLift breakout board](https://learn.adafruit.com/adafruit-airlift-breakout/downloads)

### Firmware uploading

One can upload the firmware using a Serial bypass called `SerialNINAPassthrough`, which passes through the USB serial port to Serial1, which is then manually linked to the ESP32's 5V tolerant serial port (so you just need a jumper cable).

Flash the firmware using the following command:

`esptool.py --port /dev/cu.usbmodem14101 --before no_reset --baud 115200 write_flash 0 ~/Downloads/NINA_W102-1.7.4.bin`

### Decoupling circuitry

Decoupling is handled by a 100uF tantalum capacitor and a 0.1uF ceramic capacitor. This design is validated with the NodeMCU-32 design.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

### Voltage shifting circuitry

#### MOSFET parts

The voltage shifting circuitry closely tied to the ESP32 are based on the BSS138 MOSFET. Design is based on Arduino Uno Wifi Rev2 and will require further validation. In addition, IO0 has a  jumper to D28/PA6 for ATMega to ESP32 reprogramming needs.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

#### Logic IC parts

The voltage shifting circuitry that is further away from the ESP32 module on the schematic includes a CD74HC4050 buffer (operating at 3.3V, referred as the '4050 for brevity) and a 74AHC1G125 single buffer gate (referred to as the '1G125 for brevity)

The '4050 acts as a uni-directional logic level shifter to convert 5V to 3.3V at reasonable signal speeds. The '1G125 has a single buffered gate through which MISO is toggled by the ESP side "chip select" pin. This is to free up the MISO bus when the ESP is not actively communicating with the Main Controller, and doubles as a logic level shifter.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

### RGB LED

The RGB LED is a 5050 sized RGB LED utilising a 1k resistor array. It is controllable from the Arduino by instructing the ESP32 module to power up and down those pins to indicate state.
The model of the RGB LED is [TC5050RGBF08](https://datasheet.lcsc.com/lcsc/2009231707_TCWIN-TC5050RGBF08-3CJH-AF53A_C784540.pdf).

Do take note of a few things during validation: cathode/anode markings and pinout with ESP32.

| Validation Type   | Result  |
| :---------------- | :------ |
| Pinout Validation | PASS    |
| Logic Validation  | PASS    |

## Testing programs

The SSTuino II shall be put through a series of acceptance testing to ensure it fully meets the needs of our customers. We adapted our testing program from a select subset of industry-standard testing programs.

The tests are: Engineering Validation Test (EVT), Product Validation Test (PVT), and finally Mass Production QC (MPQC). 

For an overview of standard development processes, please check out [this article](https://formlabs.com/asia/blog/validation-testing-product-development-poc-evt-dvt-pvt-mp/)

### Engineering Validation Testing (EVT)

The primary goal of EVT is to determine the feasibility of the entire project in technical terms. Essentially, it boils to "whether the product works as a fully built prototype".

This section will go through all the exact tests that the EVT stage will conduct to ensure the success of the product. This will also involve replicating common projects from previous existing SSTuino 1 projects so that we can be assured that all previous projects will work perfectly.

#### EVT1: Digital I/O

All digital I/O must be able to write and read a digital signal with no error. They must be able to generate a stable clock signal and inspected by an oscilloscope to verify their signal characteristics (bit-bang). For pins with PWM capability, they must be able to emit the desired PWM percentage at the pre-defined frequency, validated by means of an oscilloscope. For the purposes of this test, a simple program is used to trigger pins based on serial input. [WORKING]

It would also be good to test the performance of Servo-related libraries, to check if it is able to actuate a servo under certain circumstances. [WORKING]

For digital inputs, they must be tested with a simple pushbutton test with pull-up/down resistor. [WORKING]

#### EVT2: Analogue inputs

All pins capable of analogue inputs must be tested with a simple potentiometer and serial readout of the analogue voltage. [WORKING]

#### EVT3: Serial ports

The sole external serial port provided to the user, `Serial1`, will need to be validated with a simple loopback functionality (connect TX to RX and watch it read back whatever you type into it) at 9600bps 8N1 and 115200bps 8N1 protocols. [WORKING]

#### EVT4: I2C functionality

Test out I2C peripherals, such as screen and sensors. [WORKING]

#### EVT5 Series: Basic projects

This section will go over all the basic projects that the SSTuino II should be perfectly capable of performing.

##### EVT5-1: Ultrasonic sensor

An ultrasonic sensor is a basic sensor that requires precise signal timing to produce correct results. As such, an ultrasonic sensor should be tested with the SSTuino for accuracy. [WORKING]

##### EVT5-2: HTTP(S) connected applications

The device shall be able to connect to HTTP(S) endpoints to GET as well as to POST requests. Adafruit IO's HTTP interface is an ideal playground to get started with these requests. To extend the HTTP(S) testing, simple JSON decoding should also be tested. [WORKING]

##### EVT5-3: MQTT connected applications

The device shall be able to connect to MQTT endpoints to publish and subscribe to endpoints. More importantly, the publish and subscribe should be mixed together in the same program (reflecting many real life applications) and the subscribe function must not drop out during normal operations due to signal integrity issues. A good example would be to subscribe to a colour and hence reprogram the RGB LED on the board through the internet. [WORKING]

In addition, a test should be done for simultaneous subscribe and publish, to ensure that extended functionality like this works. [WORKING]

This is also a good chance to test the QoS capabilities of MQTT, with the ability to guarantee delivery of messages with QoS level 1. [WORKING]

#### EVT6: Connection with host computers

This device will need to test its connection of device with various host computers including:

* Intel Mac with USB-A (USB 3) [WORKING]
* Intel Mac with USB-C (TB3/4) [WORKING]
* Apple Silicon Mac with USB-C (TB4) [WORKING]
* Windows PC with USB-A (USB 3/2) [WORKING]
* Windows PC with USB-C (USB 3/TB3/TB4)

Our USB PID/VID combo is 0x557D/0x1206. For reference to our application on `pidcodes`, please click [this link](https://github.com/pidcodes/pidcodes.github.com/pull/704)

### Product Validation Test (PVT)

PVT performs an initial production batch of 5% of the full production run, locking in all aspects of the project such as the Bill-of-Materials, circuit board and mechanical design, circuit board specifications among many other factors.

This final test will run identical tests to those defined in EVT, but on a different subset of products. Additionally, it will lay down the required specifications for the test jigs and automated testing programs in anticipation of the next stage, MPQC. 

### Mass Production Quality Control (MPQC)

In mass production, the product will have to go through a short but comprehensive automated test to both flash the firmwares to the 3 major chips on the board, but also to test for end-to-end functionality.

For more information regarding the good use of rigorous testing programs, check out [this article](https://www.bunniestudios.com/blog/?p=5450). For testing and reverse logistics, check out [this article](https://www.bunniestudios.com/blog/?p=4981).

The proposed program scheme is as follows. It will be split into 2 phases:

Phase 1, ARM Mode:

1. Upload **SAMD11**'s bootloader and program both through PyOCD
2. (Optional) Protect the bootloader by locking the boot sector

Phase 2, USB Mode:
1. Check if USB device is connected and recognised (with VID and PID)
2. Upload to **Mega4809** the passthrough program to reprogram the ESP32
3. Invoke `esptool.py` to upload to **ESP32** the AirLift firmware
4. Upload to the **Mega4809** a testing firmware to QC it, with serial responses

The final QC program will consist of the following functions:

* Blink the LED_BUILTIN for 3 seconds [DONE]
* Run an RGB routine on the ESP32's RGB LED for 3 seconds, all the way to full power [DONE]
* (Optional?) Test every pin's digital power out. This will need some sort of an external device that's reading every single pin. A cheaper way is to use LED lights, but that may result in more operator error. In addition, add a buzzer connected to one of the pins to indicate success or failure of QC. [NOT IMPLEMENTED]
* (Optional?) Test analog values (maybe using resistive dividers?) for all the analog pins [NOT IMPLEMENTED]
* Connect to Wi-Fi [DONE]
* Run a MQTT publish operation
* Run a HTTPS GET operation on an endpoint (validating if the MQTT publish action has completed correctly, for example)


Some of the other factors we need to take into consideration are:

* "Auditability" of test: how auditable the test is. The article above proposed a log that's burnt into the chip, giving each and every board a fully auditable history right in the silicon.
* Updating the test jig and remote testing: make sure that in larger production runs where the testing is done offsite, that you are able to OTA update the test jig and to be able to fully replicate a test jig's behaviour locally before transmitting the testing firmware offsite. Currently the SSTuino II has no such requirement
