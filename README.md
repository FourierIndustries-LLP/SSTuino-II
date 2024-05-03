Designed by FourierIndustries LLP | Designed and tested in Singapore

# SSTuino II

SSTuino II is an easy to use and industrial-ready Wi-Fi enabled microcontroller, designed and fabricated by SST Alumni. With a smaller form factor, improved Wi-Fi and processing capabilities, this is the next generation of SSTuino.

**SSTuino II documentation available at: https://knowledge.fourier.industries**

## Technical information

### Pinout diagram

![Pinout](Documentation/SSTuino%20II%20Rev%20A%20Pinout%20Final.png)

### Repository Layout

* **SSTuino_II**: CAD files for SSTuino II
* **SSTuinoII_Jig**: CAD files for the SSTuino II test jig
* **Manufacturing**: Manufacturing files (Gerbers, BOM, component placement)
* **Documentation**: Documentation for design and manufacturing (not user manuals)
* **Tooling**: Software tools for production and debugging of the SSTuino II

### Automatic repair tool

Paste and run the following command in your terminal to run the autorepair tool, should you run into difficulty launching Arduino IDE or uploading programs onto your SSTuino II. Follow the on-screen instructions carefully. 

Note: This tool is only compatible with Arduino IDE 2. 

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/FourierIndustries-LLP/SSTuino-II/HEAD/Tooling/sstuino-autorepair.sh)"
```

## Contributing

Contributing to the SSTuino II Git Repository requires you to have EAGLE 8.4 or newer which supports Managed Libraries.

SSTuino II primarily uses EAGLE's Managed Libraries made by Sparkfun, but also contain our own custom footprints and SMD component footprints from various manufacturers.

SSTuino II is derived from the [Arduino Uno WiFi REV2](https://store-usa.arduino.cc/products/arduino-uno-wifi-rev2), and is licensed under a [CC BY-SA 4.0 International license](http://creativecommons.org/licenses/by-sa/4.0/).

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>

## Our team

* Goh Qian Zhe ([@QianZheGoh](https://twitter.com/QianZheGoh))
* Pan Ziyue ([@d3lta-v](https://twitter.com/sammy0025))

And special acknowledgement to the awesome folks at Arduino, Sparkfun and Adafruit for technical reference and ECAD models.

![OSHW](https://www.oshwa.org/wp-content/uploads/2014/03/oshw-logo-100-px.png)

Open Source Hardware (OSHW)