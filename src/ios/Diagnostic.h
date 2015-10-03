/*
 *  Diagnostic.h
 *  Plugin diagnostic
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import <Cordova/CDV.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface Diagnostic : CDVPlugin <CBCentralManagerDelegate>

    @property (nonatomic, retain) CBCentralManager *bluetoothManager;
    @property (nonatomic) BOOL bluetoothEnabled;

- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command;
- (void) isLocationEnabledSetting: (CDVInvokedUrlCommand*)command;
- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command;

- (void) isCameraEnabled: (CDVInvokedUrlCommand*)command;
- (void) isCameraPresent: (CDVInvokedUrlCommand*)command;
- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command;

- (void) isWifiEnabled: (CDVInvokedUrlCommand*)command;
- (void) isBluetoothEnabled: (CDVInvokedUrlCommand*)command;

- (void) switchToSettings: (CDVInvokedUrlCommand*)command;

@end
