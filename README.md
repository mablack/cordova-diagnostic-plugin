Cordova diagnostic plugin
=========================

* [Overview](#overview)
* [Installation](#installation)
* [Usage](#usage)
    * [Android and iOS](#android-and-ios)
        - [isLocationEnabled()](#islocationenabled)
        - [isWifiEnabled()](#iswifienabled)
        - [isCameraEnabled()](#iscameraenabled)
        - [isBluetoothEnabled()](#isbluetoothenabled)
    * [Android only](#android-only)
        - [isGpsLocationEnabled()](#isgpslocationenabled)
        - [isNetworkLocationEnabled()](#isnetworklocationenabled)
        - [switchToLocationSettings()](#switchtolocationsettings)
        - [switchToMobileDataSettings()](#switchtomobiledatasettings)
        - [switchToBluetoothSettings()](#switchtobluetoothsettings)
        - [switchToWifiSettings()](#switchtowifisettings)
    * [iOS only](#ios-only)
        - [isLocationEnabledSetting()](#isLocationEnabledSetting)
        - [isLocationAuthorized()](#islocationauthorized)
        - [isLocationAuthorizedAlways()](#islocationauthorizedalways)
        - [isLocationAuthorizedWhenInUse()](#islocationauthorizedwheninuse)
        - [switchToSettings()](#switchtosettings)
* [Example project](#example-project)
* [Credits](#credits)

# Overview

This Cordova/Phonegap plugin for iOS and Android is used to check the state of the following device settings:

- Location
- WiFi
- Camera
- Bluetooth

The plugin also enables an app to show the relevant settings screen, to allow users to change the above device settings.

The plugin is registered in the [the Cordova Registry](http://plugins.cordova.io/#/package/cordova.plugins.diagnostic)(Cordova CLI 3/4) and on [npm](https://www.npmjs.com/package/cordova.plugins.diagnostic) (Cordova CLI 5+) as `cordova.plugins.diagnostic`

# Installation

## Using the Cordova/Phonegap [CLI](http://docs.phonegap.com/en/edge/guide_cli_index.md.html)

    $ cordova plugin add cordova.plugins.diagnostic
    $ phonegap plugin add cordova.plugins.diagnostic

## Using [Cordova Plugman](https://github.com/apache/cordova-plugman)

    $ plugman install --plugin=cordova.plugins.diagnostic --platform=<platform> --project=<project_path> --plugins_dir=plugins

For example, to install for the Android platform

    $ plugman install --plugin=cordova.plugins.diagnostic --platform=android --project=platforms/android --plugins_dir=plugins

## PhoneGap Build
Add the following xml to your config.xml to use the latest version of this plugin from [the Cordova Registry](http://plugins.cordova.io/#/package/cordova.plugins.diagnostic):

    <gap:plugin name="cordova.plugins.diagnostic" source="plugins.cordova.io" />

or from [npm](https://www.npmjs.com/package/cordova.plugins.diagnostic):

    <gap:plugin name="cordova.plugins.diagnostic" source="npm" />

# Usage

The plugin is exposed via the `cordova.plugins.diagnostic` object and provides the following functions:

## Android and iOS

### isLocationEnabled()

Checks if app is able to access device location.

    cordova.plugins.diagnostic.isLocationEnabled(successCallback, errorCallback);

On iOS this returns true if both the device setting for Location Services is ON, AND the application is authorized to use location.
When location is enabled, the locations returned are by a mixture GPS hardware, network triangulation and Wifi network IDs.

On Android, this returns true if Location mode is enabled and any mode is selected (e.g. Battery saving, Device only, High accuracy)
When location is enabled, the locations returned are dependent on the location mode:

* Battery saving = network triangulation and Wifi network IDs (low accuracy)
* Device only = GPS hardware only (high accuracy)
* High accuracy = GPS hardware, network triangulation and Wifi network IDs (high and low accuracy)

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful. 
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isLocationEnabled(function(enabled){
        console.log("Location is " + (enabled ? "enabled" : "disabled"));
    }, function(error){
        console.error("The following error occurred: "+error);
    });

### isWifiEnabled()

Checks if Wifi is connected/enabled.
On iOS this returns true if the device is connected to a network by WiFi.
On Android this returns true if the WiFi setting is set to enabled.

    cordova.plugins.diagnostic.isWifiEnabled(successCallback, errorCallback);

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isWifiEnabled(function(enabled){
        console.log("WiFi is " + (enabled ? "enabled" : "disabled"));
    }, function(error){
        console.error("The following error occurred: "+error);
    });


### isCameraEnabled()

Checks if the device has a camera (same on Android and iOS)

    cordova.plugins.diagnostic.isCameraEnabled(successCallback, errorCallback);

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isCameraEnabled(function(exists){
        console.log("Device " + (exists ? "does" : "does not") + " have a camera");
    }, function(error){
        console.error("The following error occurred: "+error);
    });

### isBluetoothEnabled()

Checks if the device has Bluetooth capabilities and if so that Bluetooth is switched on (same on Android and iOS)

    cordova.plugins.diagnostic.isBluetoothEnabled(successCallback, errorCallback);

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isBluetoothEnabled(function(enabled){
        console.log("Bluetooth is " + (enabled ? "enabled" : "disabled"));
    }, function(error){
        console.error("The following error occurred: "+error);
    });

## Android only

### isGpsLocationEnabled()

Checks if location mode is set to return high-accuracy locations from GPS hardware.

    cordova.plugins.diagnostic.isGpsLocationEnabled(successCallback, errorCallback);

Returns true if Location mode is enabled and is set to either:

* Device only = GPS hardware only (high accuracy)
* High accuracy = GPS hardware, network triangulation and Wifi network IDs (high and low accuracy)

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isGpsLocationEnabled(function(enabled){
        console.log("GPS location is " + (enabled ? "enabled" : "disabled"));
    }, function(error){
        console.error("The following error occurred: "+error);
    });

### isNetworkLocationEnabled()

Checks if location mode is set to return low-accuracy locations from network triangulation/WiFi access points.

    cordova.plugins.diagnostic.isNetworkLocationEnabled(successCallback, errorCallback);

Returns true if Location mode is enabled and is set to either:

* Battery saving = network triangulation and Wifi network IDs (low accuracy)
* High accuracy = GPS hardware, network triangulation and Wifi network IDs (high and low accuracy)

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isNetworkLocationEnabled(function(enabled){
        console.log("Network location is " + (enabled ? "enabled" : "disabled"));
    }, function(error){
        console.error("The following error occurred: "+error);
    });

### switchToLocationSettings()

Displays the device location settings to allow user to enable location services/change location mode.

    cordova.plugins.diagnostic.switchToLocationSettings();

### switchToMobileDataSettings()

Displays mobile settings to allow user to enable mobile data.

    cordova.plugins.diagnostic.switchToMobileDataSettings();

### switchToBluetoothSettings()

Displays Bluetooth settings to allow user to enable Bluetooth.

    cordova.plugins.diagnostic.switchToBluetoothSettings();


### switchToWifiSettings()

Displays WiFi settings to allow user to enable WiFi.

    cordova.plugins.diagnostic.switchToWifiSettings();

## iOS only

### isLocationEnabledSetting()

Returns true if the device setting for location is on.

    cordova.plugins.diagnostic.isLocationEnabledSetting(successCallback, errorCallback);

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isLocationEnabledSetting(function(enabled){
        console.log("Location setting is " + (enabled ? "enabled" : "disabled"));
    }, function(error){
        console.error("The following error occurred: "+error);
    });


### isLocationAuthorized()

Returns true if the application is authorized to use location AND the device setting for location is on.

    cordova.plugins.diagnostic.isLocationAuthorized(successCallback, errorCallback);

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isLocationAuthorized(function(enabled){
        console.log("Location authorization is " + (enabled ? "enabled" : "disabled"));
    }, function(error){
        console.error("The following error occurred: "+error);
    });

### isLocationAuthorizedAlways()

Checks and returns true if the application is authorized to use location "always" (foreground and background).
If your app uses background location mode then location mode must be set to this to receive location updates while in the background.

    cordova.plugins.diagnostic.isLocationAuthorizedAlways(successCallback, errorCallback);

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isLocationAuthorizedAlways(function(always){
        console.log("App " + (always ? "is" : "isn't") + " always authorized to use location");
    }, function(error){
        console.error("The following error occurred: "+error);
    });

### isLocationAuthorizedWhenInUse()

Checks and returns true if the application is authorized to use location "when in use" (only in foreground).
If this location mode is set, the app will only receive location updates while in the foreground (not be background),
even if your app uses background location mode.

    cordova.plugins.diagnostic.isLocationAuthorizedWhenInUse(successCallback, errorCallback);

#### Parameters

- {Function} successCallback -  The callback which will be called when diagnostic is successful.
This callback function is passed a single boolean parameter with the diagnostic result.
- {Function} errorCallback -  The callback which will be called when diagnostic encounters an error.
This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.isLocationAuthorizedWhenInUse(function(always){
        console.log("App " + (always ? "is" : "isn't") + " authorized for location when in use");
    }, function(error){
        console.error("The following error occurred: "+error);
    });

### switchToSettings()

Switch to Settings app. Opens settings page for this app. This works only on iOS 8+. iOS 7 and below will invoke the errorCallback.

    cordova.plugins.diagnostic.switchToSettings(successCallback, errorCallback);

#### Parameters

- {Function} successCallback - The callback which will be called when switch to settings is successful.
- {Function} errorCallback - The callback which will be called when switch to settings encounters an error. This callback function is passed a single string parameter containing the error message.


#### Example usage

    cordova.plugins.diagnostic.switchToSettings(function(){
        console.log("Successfully switched to Settings app"));
    }, function(error){
        console.error("The following error occurred: "+error);
    });

# Example project

An example project illustrating use of this plugin can be found here: [https://github.com/dpa99c/cordova-diagnostic-plugin-example](https://github.com/dpa99c/cordova-diagnostic-plugin-example)


# Credits

Forked from: [https://github.com/mablack/cordova-diagnostic-plugin](https://github.com/mablack/cordova-diagnostic-plugin)

Orignal Cordova 2 implementation by: AVANTIC ESTUDIO DE INGENIEROS ([www.avantic.net](http://www.avantic.net/))