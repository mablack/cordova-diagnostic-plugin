/*
 *  Diagnostic.h
 *  Diagnostic Plugin - Core Module
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <WebKit/WebKit.h>

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

// Public constants
extern NSString*const UNKNOWN;

extern NSString*const AUTHORIZATION_NOT_DETERMINED;
extern NSString*const AUTHORIZATION_DENIED;
extern NSString*const AUTHORIZATION_GRANTED;

@interface Diagnostic : CDVPlugin

@property (strong, nonatomic) CMMotionActivityManager* motionManager;
@property (strong, nonatomic) NSOperationQueue* motionActivityQueue;
@property (nonatomic) EKEventStore *eventStore;

+ (id) getInstance;
- (void) sendPluginResult: (CDVPluginResult*)result :(CDVInvokedUrlCommand*)command;
- (void) sendPluginResultBool: (BOOL)result :(CDVInvokedUrlCommand*)command;
- (void) sendPluginResultString: (NSString*)result :(CDVInvokedUrlCommand*)command;
- (void) sendPluginError: (NSString*) errorMessage :(CDVInvokedUrlCommand*)command;
- (void) handlePluginException: (NSException*) exception :(CDVInvokedUrlCommand*)command;
- (void)executeGlobalJavascript: (NSString*)jsString;
- (NSString*) arrayToJsonString:(NSArray*)inputArray;
- (NSString*) objectToJsonString:(NSDictionary*)inputObject;
- (NSArray*) jsonStringToArray:(NSString*)jsonStr;
- (NSDictionary*) jsonStringToDictionary:(NSString*)jsonStr;
- (bool)isNull: (NSString*)str;

- (void)logDebug: (NSString*)msg;
- (void)logError: (NSString*)msg;
- (NSString*)escapeDoubleQuotes: (NSString*)str;
- (void) setSetting: (NSString*)key forValue:(id)value;
- (id) getSetting: (NSString*) key;

- (void) enableDebug: (CDVInvokedUrlCommand*)command;

- (void) isCameraAvailable: (CDVInvokedUrlCommand*)command;
- (void) isCameraPresent: (CDVInvokedUrlCommand*)command;
- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command;
- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command;

- (void) isWifiAvailable: (CDVInvokedUrlCommand*)command;
- (void) isWifiEnabled: (CDVInvokedUrlCommand*)command;

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
