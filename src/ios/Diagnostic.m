/*
 *  Diagnostic.m
 *  Diagnostic Plugin - Core Module
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import "Diagnostic.h"

@interface Diagnostic()

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
@property (nonatomic, retain) CNContactStore* contactStore;
#endif

@property (nonatomic, retain) CMPedometer* cmPedometer;
@property (nonatomic, retain) NSUserDefaults* settings;

@end


@implementation Diagnostic

// Public constants
NSString*const UNKNOWN = @"unknown";

NSString*const AUTHORIZATION_NOT_DETERMINED = @"not_determined";
NSString*const AUTHORIZATION_DENIED = @"denied";
NSString*const AUTHORIZATION_GRANTED = @"authorized";

// Internal constants
static NSString*const LOG_TAG = @"Diagnostic[native]";
static NSString*const CPU_ARCH_ARMv6 = @"ARMv6";
static NSString*const CPU_ARCH_ARMv7 = @"ARMv7";
static NSString*const CPU_ARCH_ARMv8 = @"ARMv8";
static NSString*const CPU_ARCH_X86 = @"X86";
static NSString*const CPU_ARCH_X86_64 = @"X86_64";

static Diagnostic* diagnostic = nil;

BOOL debugEnabled = false;
float osVersion;

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
ABAddressBookRef _addressBook;
#endif

/********************************/
#pragma mark - Public static functions
/********************************/
+ (id) getInstance{
    return diagnostic;
}


/********************************/
#pragma mark - Plugin API
/********************************/

-(void)enableDebug:(CDVInvokedUrlCommand*)command{
    debugEnabled = true;
    [self logDebug:@"Debug enabled"];
}

#pragma mark -  Settings
- (void) switchToSettings: (CDVInvokedUrlCommand*)command
{
    @try {
        if (UIApplicationOpenSettingsURLString != nil ){
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] :command];
                    }else{
                        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] :command];
                    }
                }];
#endif
            }else{
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
                [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] :command];
            }
        }else{
            [self sendPluginError:@"Not supported below iOS 8":command];
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

#pragma mark - Audio
- (void) isMicrophoneAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        @try {
#ifdef __IPHONE_8_0
            AVAudioSessionRecordPermission recordPermission = [AVAudioSession sharedInstance].recordPermission;
            
            if(recordPermission == AVAudioSessionRecordPermissionGranted) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
            }
            else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            }
            [self sendPluginResultBool:recordPermission == AVAudioSessionRecordPermissionGranted :command];
#else
            [self sendPluginError:@"Only supported on iOS 8 and higher":command];
#endif
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        };
    }];
}

- (void) getMicrophoneAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
#ifdef __IPHONE_8_0
            NSString* status;
            AVAudioSessionRecordPermission recordPermission = [AVAudioSession sharedInstance].recordPermission;
            switch(recordPermission){
                case AVAudioSessionRecordPermissionDenied:
                    status = AUTHORIZATION_DENIED;
                    break;
                case AVAudioSessionRecordPermissionGranted:
                    status = AUTHORIZATION_GRANTED;
                    break;
                case AVAudioSessionRecordPermissionUndetermined:
                    status = AUTHORIZATION_NOT_DETERMINED;
                    break;
            }
            
            [self logDebug:[NSString stringWithFormat:@"Microphone authorization status is: %@", status]];
            [self sendPluginResultString:status:command];
#else
            [self sendPluginError:@"Only supported on iOS 8 and higher":command];
#endif
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) requestMicrophoneAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                [self logDebug:[NSString stringWithFormat:@"Has access to microphone: %d", granted]];
                [self sendPluginResultBool:granted :command];
            }];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

#pragma mark - Address Book (Contacts)

- (void) getAddressBookAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status;
            
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
            CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if(authStatus == CNAuthorizationStatusDenied || authStatus == CNAuthorizationStatusRestricted){
                status = AUTHORIZATION_DENIED;
            }else if(authStatus == CNAuthorizationStatusNotDetermined){
                status = AUTHORIZATION_NOT_DETERMINED;
            }else if(authStatus == CNAuthorizationStatusAuthorized){
                status = AUTHORIZATION_GRANTED;
            }
#else
            ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
            if(authStatus == kABAuthorizationStatusDenied || authStatus == kABAuthorizationStatusRestricted){
                status = AUTHORIZATION_DENIED;
            }else if(authStatus == kABAuthorizationStatusNotDetermined){
                status = AUTHORIZATION_NOT_DETERMINED;
            }else if(authStatus == kABAuthorizationStatusAuthorized){
                status = AUTHORIZATION_GRANTED;
            }
            
#endif
            
            [self logDebug:[NSString stringWithFormat:@"Address book authorization status is: %@", status]];
            [self sendPluginResultString:status:command];
            
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isAddressBookAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
            CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            [self sendPluginResultBool:authStatus == CNAuthorizationStatusAuthorized :command];
#else
            ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
            [self sendPluginResultBool:authStatus == kABAuthorizationStatusAuthorized :command];
#endif
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) requestAddressBookAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
            ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
                [self logDebug:@"Access request to address book: %d", granted];
                [self sendPluginResultBool:granted :command];
            });
            
#else
            [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(error == nil) {
                    [self logDebug:[NSString stringWithFormat:@"Access request to address book: %d", granted]];
                    [self sendPluginResultBool:granted :command];
                }
                else {
                    [self sendPluginResultBool:FALSE :command];
                }
            }];
#endif
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

#pragma mark - Calendar Events

- (void) getCalendarAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status;
            
            EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
            
            if(authStatus == EKAuthorizationStatusDenied || authStatus == EKAuthorizationStatusRestricted){
                status = AUTHORIZATION_DENIED;
            }else if(authStatus == EKAuthorizationStatusNotDetermined){
                status = AUTHORIZATION_NOT_DETERMINED;
            }else if(authStatus == EKAuthorizationStatusAuthorized){
                status = AUTHORIZATION_GRANTED;
            }
            [self logDebug:[NSString stringWithFormat:@"Calendar event authorization status is: %@", status]];
            [self sendPluginResultString:status:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isCalendarAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
            [self sendPluginResultBool:authStatus == EKAuthorizationStatusAuthorized:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) requestCalendarAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            
            if (!self.eventStore) {
                self.eventStore = [EKEventStore new];
            }
            
            [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                [self logDebug:[NSString stringWithFormat:@"Access request to calendar events: %d", granted]];
                [self sendPluginResultBool:granted:command];
            }];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

#pragma mark - Reminder Events

- (void) getRemindersAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status;
            
            EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
            
            if(authStatus == EKAuthorizationStatusDenied || authStatus == EKAuthorizationStatusRestricted){
                status = AUTHORIZATION_DENIED;
            }else if(authStatus == EKAuthorizationStatusNotDetermined){
                status = AUTHORIZATION_NOT_DETERMINED;
            }else if(authStatus == EKAuthorizationStatusAuthorized){
                status = AUTHORIZATION_GRANTED;
            }
            [self logDebug:[NSString stringWithFormat:@"Reminders authorization status is: %@", status]];
            [self sendPluginResultString:status:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isRemindersAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
            [self sendPluginResultBool:authStatus == EKAuthorizationStatusAuthorized:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) requestRemindersAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            
            if (!self.eventStore) {
                self.eventStore = [EKEventStore new];
            }
            
            [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
                [self logDebug:[NSString stringWithFormat:@"Access request to reminders: %d", granted]];
                [self sendPluginResultBool:granted:command];
            }];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

#pragma mark - Background refresh
- (void) getBackgroundRefreshStatus: (CDVInvokedUrlCommand*)command
{
    UIBackgroundRefreshStatus _status;
    @try {
        // Must run on UI thread
        _status = [[UIApplication sharedApplication] backgroundRefreshStatus];
    }@catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status;
            
            if (_status == UIBackgroundRefreshStatusAvailable) {
                status = AUTHORIZATION_GRANTED;
                [self logDebug:@"Background updates are available for the app."];
            }else if(_status == UIBackgroundRefreshStatusDenied){
                status = AUTHORIZATION_DENIED;
                [self logDebug:@"The user explicitly disabled background behavior for this app or for the whole system."];
            }else if(_status == UIBackgroundRefreshStatusRestricted){
                status = @"restricted";
                [self logDebug:@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user."];
            }
            [self sendPluginResultString:status:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}
#pragma mark - Motion methods

- (void) isMotionAvailable:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            
            [self sendPluginResultBool:[self isMotionAvailable] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isMotionRequestOutcomeAvailable:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            
            [self sendPluginResultBool:[self isMotionRequestOutcomeAvailable] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) getMotionAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        if([self getSetting:@"motion_permission_requested"] == nil){
            // Permission not yet requested
            [self sendPluginResultString:@"not_requested":command];
        }else{
            // Permission has been requested so determine the outcome
            [self _requestMotionAuthorization:command];
        }
    }];
}

- (void) requestMotionAuthorization: (CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
        if([self getSetting:@"motion_permission_requested"] != nil){
            [self sendPluginError:@"requestMotionAuthorization() has already been called and can only be called once after app installation":command];
        }else{
            [self _requestMotionAuthorization:command];
        }
    }];
}

- (void) _requestMotionAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        if([self isMotionAvailable]){
            @try {
                [self.cmPedometer queryPedometerDataFromDate:[NSDate date]
                                                      toDate:[NSDate date]
                                                 withHandler:^(CMPedometerData* data, NSError *error) {
                                                     @try {
                                                         [self setSetting:@"motion_permission_requested" forValue:(id)kCFBooleanTrue];
                                                         NSString* status = UNKNOWN;
                                                         if (error != nil) {
                                                             if (error.code == CMErrorMotionActivityNotAuthorized) {
                                                                 status = AUTHORIZATION_DENIED;
                                                             }else if (error.code == CMErrorMotionActivityNotEntitled) {
                                                                 status = @"restricted";
                                                             }else if (error.code == CMErrorMotionActivityNotAvailable) {
                                                                 // Motion request outcome cannot be determined on this device
                                                                 status = AUTHORIZATION_NOT_DETERMINED;
                                                             }
                                                         }
                                                         else{
                                                             status = AUTHORIZATION_GRANTED;
                                                         }
                                                         
                                                         [self logDebug:[NSString stringWithFormat:@"Motion tracking authorization status is %@", status]];
                                                         [self sendPluginResultString:status:command];
                                                     }@catch (NSException *exception) {
                                                         [self handlePluginException:exception :command];
                                                     }
                                                 }];
            }@catch (NSException *exception) {
                [self handlePluginException:exception :command];
            }
        }else{
            // Activity tracking not available on this device
            [self sendPluginResultString:@"not_available":command];
        }
    }@catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

/********************************/
#pragma mark - Internal functions
/********************************/

- (void)pluginInitialize {

    [super pluginInitialize];

    diagnostic = self;

    osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];

    self.contactStore = [[CNContactStore alloc] init];
    self.motionManager = [[CMMotionActivityManager alloc] init];
    self.motionActivityQueue = [[NSOperationQueue alloc] init];
    self.cmPedometer = [[CMPedometer alloc] init];
    self.settings = [NSUserDefaults standardUserDefaults];
}

// https://stackoverflow.com/a/38441011/777265
- (void) getArchitecture: (CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* cpuArch = UNKNOWN;
            
            size_t size;
            cpu_type_t type;
            cpu_subtype_t subtype;
            size = sizeof(type);
            sysctlbyname("hw.cputype", &type, &size, NULL, 0);
            
            size = sizeof(subtype);
            sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
            
            // values for cputype and cpusubtype defined in mach/machine.h
            if (type == CPU_TYPE_X86_64) {
                cpuArch = CPU_ARCH_X86_64;
            } else if (type == CPU_TYPE_X86) {
                cpuArch = CPU_ARCH_X86;
            } else if (type == CPU_TYPE_ARM64) {
                cpuArch = CPU_ARCH_ARMv8;
            } else if (type == CPU_TYPE_ARM) {
                switch(subtype){
                    case CPU_SUBTYPE_ARM_V6:
                        cpuArch = CPU_ARCH_ARMv6;
                        break;
                    case CPU_SUBTYPE_ARM_V7:
                        cpuArch = CPU_ARCH_ARMv7;
                        break;
                    case CPU_SUBTYPE_ARM_V8:
                        cpuArch = CPU_ARCH_ARMv8;
                        break;
                }
            }
            [self logDebug:[NSString stringWithFormat:@"Current CPU architecture: %@", cpuArch]];
            [self sendPluginResultString:cpuArch:command];
        }@catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}


- (BOOL) isMotionAvailable
{
    return [CMMotionActivityManager isActivityAvailable];
}

- (BOOL) isMotionRequestOutcomeAvailable
{
    return [CMPedometer respondsToSelector:@selector(isPedometerEventTrackingAvailable)] && [CMPedometer isPedometerEventTrackingAvailable];
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (ABAddressBookRef)addressBook {
    if (!_addressBook) {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (addressBook) {
            [self setAddressBook:CFAutorelease(addressBook)];
        }
    }
    
    return _addressBook;
}

- (void)setAddressBook:(ABAddressBookRef)newAddressBook {
    if (_addressBook != newAddressBook) {
        if (_addressBook) {
            CFRelease(_addressBook);
        }
        
        if (newAddressBook) {
            CFRetain(newAddressBook);
        }
        
        _addressBook = newAddressBook;
    }
}

- (void)dealloc {
    if (_addressBook) {
        CFRelease(_addressBook);
        _addressBook = NULL;
    }
}
#endif

/********************************/
#pragma mark - Send results
/********************************/

- (void) sendPluginResult: (CDVPluginResult*)result :(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) sendPluginResultBool: (BOOL)result :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if(result) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) sendPluginResultString: (NSString*)result :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) sendPluginError: (NSString*) errorMessage :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
    [self logError:errorMessage];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) handlePluginException: (NSException*) exception :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self logError:[NSString stringWithFormat:@"EXCEPTION: %@", exception.reason]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)executeGlobalJavascript: (NSString*)jsString
{
    [self.commandDelegate evalJs:jsString];
}

- (NSString*) arrayToJsonString:(NSArray*)inputArray
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString*) objectToJsonString:(NSDictionary*)inputObject
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSArray*) jsonStringToArray:(NSString*)jsonStr
{
    NSError* error = nil;
    NSArray* array = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error != nil){
        array = nil;
    }
    return array;
}

- (NSDictionary*) jsonStringToDictionary:(NSString*)jsonStr
{
    return (NSDictionary*) [self jsonStringToArray:jsonStr];
}

- (bool)isNull: (NSString*)str
{
    return str == nil || str == (id)[NSNull null] || str.length == 0 || [str isEqual: @"<null>"];
}


/********************************/
#pragma mark - utility functions
/********************************/

- (void)logDebug: (NSString*)msg
{
    if(debugEnabled){
        NSLog(@"%@: %@", LOG_TAG, msg);
        NSString* jsString = [NSString stringWithFormat:@"console.log(\"%@: %@\")", LOG_TAG, [self escapeDoubleQuotes:msg]];
        [self executeGlobalJavascript:jsString];
    }
}

- (void)logError: (NSString*)msg
{
    NSLog(@"%@ ERROR: %@", LOG_TAG, msg);
    if(debugEnabled){
        NSString* jsString = [NSString stringWithFormat:@"console.error(\"%@: %@\")", LOG_TAG, [self escapeDoubleQuotes:msg]];
        [self executeGlobalJavascript:jsString];
    }
}

- (NSString*)escapeDoubleQuotes: (NSString*)str
{
    NSString *result =[str stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""];
    return result;
}

- (void) setSetting: (NSString*)key forValue:(id)value
{

    [self.settings setObject:value forKey:key];
    [self.settings synchronize];
}

- (id) getSetting: (NSString*) key
{
    return [self.settings objectForKey:key];
}

@end


