/*
 *  Diagnostic.h
 *  Plugin diagnostic
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <WebKit/WebKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>

@interface Diagnostic : CDVPlugin <CBCentralManagerDelegate, CLLocationManagerDelegate>

    @property (nonatomic, retain) CBCentralManager* bluetoothManager;
    @property (nonatomic) BOOL bluetoothEnabled;
    @property (nonatomic) NSString* bluetoothState;
    @property (strong, nonatomic) CLLocationManager* locationManager;
    @property (nonatomic, retain) NSString* locationRequestCallbackId;
    @property (nonatomic) EKEventStore *eventStore;

- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command;
- (void) isLocationEnabledSetting: (CDVInvokedUrlCommand*)command;
- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestLocationAuthorization: (CDVInvokedUrlCommand*)command;

- (void) isCameraEnabled: (CDVInvokedUrlCommand*)command;
- (void) isCameraPresent: (CDVInvokedUrlCommand*)command;
- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command;
- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command;

- (void) isWifiEnabled: (CDVInvokedUrlCommand*)command;
- (void) isBluetoothEnabled: (CDVInvokedUrlCommand*)command;

- (void) isRemoteNotificationsEnabled: (CDVInvokedUrlCommand*)command;
- (void) getRemoteNotificationTypes: (CDVInvokedUrlCommand*)command;
- (void) isRegisteredForRemoteNotifications: (CDVInvokedUrlCommand*)command;

- (void) switchToSettings: (CDVInvokedUrlCommand*)command;

- (void) isMicrophoneAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getMicrophoneAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestMicrophoneAuthorization: (CDVInvokedUrlCommand*)command;

- (void) getAddressBookAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) isAddressBookAuthorized: (CDVInvokedUrlCommand*)command;
- (void) requestAddressBookAuthorization: (CDVInvokedUrlCommand*)command;

- (void) getCalendarAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) isCalendarAuthorized: (CDVInvokedUrlCommand*)command;
- (void) requestCalendarAuthorization: (CDVInvokedUrlCommand*)command;
- (void) getRemindersAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) isRemindersAuthorized: (CDVInvokedUrlCommand*)command;
- (void) requestRemindersAuthorization: (CDVInvokedUrlCommand*)command;


@end
