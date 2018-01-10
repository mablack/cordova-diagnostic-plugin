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
#import <CoreMotion/CoreMotion.h>
#import <EventKit/EventKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK
#import <mach/machine.h>
#import <sys/types.h>
#import <sys/sysctl.h>

static NSString*const LOG_TAG = @"Diagnostic[native]";

static NSString*const UNKNOWN = @"unknown";

static NSString*const CPU_ARCH_ARMv6 = @"ARMv6";
static NSString*const CPU_ARCH_ARMv7 = @"ARMv7";
static NSString*const CPU_ARCH_ARMv8 = @"ARMv8";
static NSString*const CPU_ARCH_X86 = @"X86";
static NSString*const CPU_ARCH_X86_64 = @"X86_64";

static NSString*const AUTHORIZATION_NOT_DETERMINED = @"not_determined";
static NSString*const AUTHORIZATION_DENIED = @"denied";
static NSString*const AUTHORIZATION_GRANTED = @"authorized";

static NSString*const REMOTE_NOTIFICATIONS_ALERT = @"alert";
static NSString*const REMOTE_NOTIFICATIONS_SOUND = @"sound";
static NSString*const REMOTE_NOTIFICATIONS_BADGE = @"badge";

@interface Diagnostic : CDVPlugin <CBCentralManagerDelegate, CLLocationManagerDelegate>

    @property (nonatomic, retain) CBCentralManager* bluetoothManager;
    @property (strong, nonatomic) CLLocationManager* locationManager;
    @property (strong, nonatomic) CMMotionActivityManager* motionManager;
    @property (strong, nonatomic) NSOperationQueue* motionActivityQueue;
    @property (nonatomic, retain) NSString* locationRequestCallbackId;
    @property (nonatomic) EKEventStore *eventStore;
    @property (nonatomic, retain) NSString* currentLocationAuthorizationStatus;

- (void) enableDebug: (CDVInvokedUrlCommand*)command;

- (void) isLocationAvailable: (CDVInvokedUrlCommand*)command;
- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command;
- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestLocationAuthorization: (CDVInvokedUrlCommand*)command;

- (void) isCameraAvailable: (CDVInvokedUrlCommand*)command;
- (void) isCameraPresent: (CDVInvokedUrlCommand*)command;
- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command;
- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command;

- (void) isWifiAvailable: (CDVInvokedUrlCommand*)command;
- (void) isWifiEnabled: (CDVInvokedUrlCommand*)command;

- (void) isBluetoothAvailable: (CDVInvokedUrlCommand*)command;
- (void) getBluetoothState: (CDVInvokedUrlCommand*)command;
- (void) requestBluetoothAuthorization: (CDVInvokedUrlCommand*)command;

- (void) isRemoteNotificationsEnabled: (CDVInvokedUrlCommand*)command;
- (void) getRemoteNotificationTypes: (CDVInvokedUrlCommand*)command;
- (void) isRegisteredForRemoteNotifications: (CDVInvokedUrlCommand*)command;
- (void) getRemoteNotificationsAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestRemoteNotificationsAuthorization: (CDVInvokedUrlCommand*)command;

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

- (void) getBackgroundRefreshStatus: (CDVInvokedUrlCommand*)command;

- (void) isMotionAvailable: (CDVInvokedUrlCommand*)command;
- (void) isMotionRequestOutcomeAvailable: (CDVInvokedUrlCommand*)command;
- (void) getMotionAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestMotionAuthorization: (CDVInvokedUrlCommand*)command;

- (void) getArchitecture: (CDVInvokedUrlCommand*)command;

@end
