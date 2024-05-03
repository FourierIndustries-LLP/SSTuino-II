#!/bin/bash

set -o errexit

# Check if Rosetta installed
echo 'Checking if Rosetta 2 is installed'
if [ -f /Library/Apple/usr/libexec/oah/libRosettaRuntime ]; then
    echo 'Rosetta 2 is already installed :)'
else
    echo 'Rosetta 2 not installed, installing now...'
    softwareupdate --install-rosetta --agree-to-license
fi

echo

# Find where is Arduino.app
ARDUINO_APP="$(osascript -l JavaScript -e 'a=Application.currentApplication();a.includeStandardAdditions=true;a.chooseFile({withPrompt:"Select your Arduino IDE.app"}).toString()')"
ARDUINO_INSTALLATION="${ARDUINO_APP}/Contents/Resources/app/lib/backend/resources/"
ARDUINO_PLIST="${ARDUINO_APP}/Contents/Info.plist"
export PATH="$PATH:$ARDUINO_INSTALLATION"

# Check Arduino version to ensure it is not nightly
ARDUINO_VERSION=`defaults read "$ARDUINO_PLIST" CFBundleShortVersionString`
SUB="nightly"
if [[ "$ARDUINO_VERSION" == *"$SUB"* ]]; then
  echo "Your version of Arduino is a nightly (beta) build!"
  echo "Please remove it. We are downloading the latest stable version..."
  cd ~/Downloads
  curl -O https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.2_macOS_arm64.dmg
  echo "Download complete! Please go to your downloads folder and install Arduino again"
  exit 0
fi
echo "Arduino version confirmed as $ARDUINO_VERSION"

echo

# Purge original SSTuino installation and AVR cores
echo "Purging existing cores (safe to ignore errors)..."
arduino-cli core uninstall "SSTuino II Series Boards:megaavr" || true
arduino-cli core uninstall "arduino:avr" || true
arduino-cli core uninstall "arduino:megaavr" || true

echo

# Reinstall both cores
echo "Reinstalling cores..."
arduino-cli core update-index --additional-urls https://fourierindustries-llp.github.io/SSTuino_II_Core/package_FourierIndustries-LLP_SSTuino_II_Core_index.json
arduino-cli core install "arduino:avr"
arduino-cli core install "SSTuino II Series Boards:megaavr" --additional-urls https://fourierindustries-llp.github.io/SSTuino_II_Core/package_FourierIndustries-LLP_SSTuino_II_Core_index.json
arduino-cli core upgrade

echo

# Test compile
echo "Testing compilation of a sample program..."
arduino-cli compile -b "SSTuino II Series Boards:megaavr:4809" ~/Library/Arduino15/packages/SSTuino\ II\ Series\ Boards/hardware/megaavr/*.*/libraries/WiFiNINA-SSTuino/examples/Ubidots_5_Demo/Ubidots_5_Demo.ino
echo "ALL TESTS PASSED, your computer is ready to run Arduino and SSTuino II software!"
echo "If you still don't see your SSTuino II's port show up in Arduino, please go to 'System Settings > Privacy & Security > Allow accessories to connect' and set it to 'Automatically When Unlocked'"
