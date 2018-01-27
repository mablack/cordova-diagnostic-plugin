/*
 *  Diagnostic.h
 *  Plugin diagnostic
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




BOOL debugEnabled = false;
float osVersion;

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
ABAddressBookRef _addressBook;
#endif
- (void)pluginInitialize {
    
    [super pluginInitialize];
    
    osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    self.locationRequestCallbackId = nil;
    self.currentLocationAuthorizationStatus = nil;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.bluetoothManager = [[CBCentralManager alloc]
                             initWithDelegate:self
                             queue:dispatch_get_main_queue()
                             options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
    self.contactStore = [[CNContactStore alloc] init];
    self.motionManager = [[CMMotionActivityManager alloc] init];
    self.motionActivityQueue = [[NSOperationQueue alloc] init];
    self.cmPedometer = [[CMPedometer alloc] init];
    self.settings = [NSUserDefaults standardUserDefaults];
}

/********************************/
#pragma mark - Plugin API
/********************************/

-(void)enableDebug:(CDVInvokedUrlCommand*)command{
    debugEnabled = true;
    [self logDebug:@"Debug enabled"];
}

#pragma mark - Location
- (void) isLocationAvailable: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[CLLocationManager locationServicesEnabled] && [self isLocationAuthorized] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[CLLocationManager locationServicesEnabled] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}


- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[self isLocationAuthorized] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status = [self getLocationAuthorizationStatusAsString:[CLLocationManager authorizationStatus]];
            [self logDebug:[NSString stringWithFormat:@"Location authorization status is: %@", status]];
            [self sendPluginResultString:status:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) requestLocationAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)])
            {
                BOOL always = [[command argumentAtIndex:0] boolValue];
                if(always){
                    NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationAlwaysUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationAlwaysUsageDescription in its Info.plist");
                    [self.locationManager requestAlwaysAuthorization];
                    [self logDebug:@"Requesting location authorization: always"];
                }else{
                    NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationWhenInUseUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationWhenInUseUsageDescription in its Info.plist");
                    [self.locationManager requestWhenInUseAuthorization];
                    [self logDebug:@"Requesting location authorization: when in use"];
                }
            }
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
        self.locationRequestCallbackId = command.callbackId;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [self sendPluginResult:pluginResult :command];
    }];
}

#pragma mark - Camera
- (void) isCameraAvailable: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[self isCameraPresent] && [self isCameraAuthorized] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isCameraPresent: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[self isCameraPresent] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[self isCameraAuthorized] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            
            if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
                status = AUTHORIZATION_DENIED;
            }else if(authStatus == AVAuthorizationStatusNotDetermined){
                status = AUTHORIZATION_NOT_DETERMINED;
            }else if(authStatus == AVAuthorizationStatusAuthorized){
                status = AUTHORIZATION_GRANTED;
            }
            [self logDebug:[NSString stringWithFormat:@"Camera authorization status is: %@", status]];
            [self sendPluginResultString:status:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                [self sendPluginResultBool:granted :command];
            }];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[[self getCameraRollAuthorizationStatus]  isEqual: AUTHORIZATION_GRANTED] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status = [self getCameraRollAuthorizationStatus];
            [self logDebug:[NSString stringWithFormat:@"Camera Roll authorization status is: %@", status]];
            [self sendPluginResultString:status:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) requestCameraRollAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authStatus) {
                NSString* status = [self getCameraRollAuthorizationStatusAsString:authStatus];
                [self sendPluginResultString:status:command];
            }];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

#pragma mark -  Wifi
- (void) isWifiAvailable: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[self connectedToWifi] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) isWifiEnabled: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self sendPluginResultBool:[self isWifiEnabled] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (BOOL) isWifiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}


#pragma mark - Bluetooth

- (void) isBluetoothAvailable: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* state = [self getBluetoothState];
            bool bluetoothEnabled;
            if([state  isEqual: @"powered_on"]){
                bluetoothEnabled = true;
            }else{
                bluetoothEnabled = false;
            }
            [self sendPluginResultBool:bluetoothEnabled :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) getBluetoothState: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* state = [self getBluetoothState];
            [self logDebug:[NSString stringWithFormat:@"Bluetooth state is: %@", state]];
            [self sendPluginResultString:state:command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
    
}

- (void) requestBluetoothAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* state = [self getBluetoothState];
            
            if([state isEqual: @"unauthorized"]){
                /*
                 When the application requests to start scanning for bluetooth devices that is when the user is presented with a consent dialog.
                 */
                [self logDebug:@"Requesting bluetooth authorization"];
                [self.bluetoothManager scanForPeripheralsWithServices:nil options:nil];
                [self.bluetoothManager stopScan];
            }else{
                [self logDebug:@"Bluetooth authorization is already granted"];
            }
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] :command];
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
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

#pragma mark - Remote (Push) Notifications
- (void) isRemoteNotificationsEnabled: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                // iOS 8+
                if(NSClassFromString(@"UNUserNotificationCenter")) {
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                    // iOS 10+
                    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                        BOOL userSettingEnabled = settings.authorizationStatus == UNAuthorizationStatusAuthorized;
                        [self isRemoteNotificationsEnabledResult:userSettingEnabled:command];
                    }];
#endif
                } else{
                    // iOS 8 & 9
                    UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
                    BOOL userSettingEnabled = userNotificationSettings.types != UIUserNotificationTypeNone;
                    [self isRemoteNotificationsEnabledResult:userSettingEnabled:command];
                }
            } else {
                // iOS7 and below
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
                UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
                BOOL isEnabled = enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
                [self sendPluginResultBool:isEnabled:command];
#endif
            }
            
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception:command];
        }
    }];
}
- (void) isRemoteNotificationsEnabledResult: (BOOL) userSettingEnabled : (CDVInvokedUrlCommand*)command
{
    // iOS 8+
    [self _isRegisteredForRemoteNotifications:^(BOOL remoteNotificationsEnabled) {
        BOOL isEnabled = remoteNotificationsEnabled && userSettingEnabled;
        [self sendPluginResultBool:isEnabled:command];
    }];
}

- (void) getRemoteNotificationTypes: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                // iOS 8+
                if(NSClassFromString(@"UNUserNotificationCenter")) {
                    // iOS 10+
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                        BOOL alertsEnabled = settings.alertSetting == UNNotificationSettingEnabled;
                        BOOL badgesEnabled = settings.badgeSetting == UNNotificationSettingEnabled;
                        BOOL soundsEnabled = settings.soundSetting == UNNotificationSettingEnabled;
                        BOOL noneEnabled = !alertsEnabled && !badgesEnabled && !soundsEnabled;
                        [self getRemoteNotificationTypesResult:command:noneEnabled:alertsEnabled:badgesEnabled:soundsEnabled];
                    }];
#endif
                } else{
                    // iOS 8 & 9
                    UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
                    BOOL noneEnabled = userNotificationSettings.types == UIUserNotificationTypeNone;
                    BOOL alertsEnabled = userNotificationSettings.types & UIUserNotificationTypeAlert;
                    BOOL badgesEnabled = userNotificationSettings.types & UIUserNotificationTypeBadge;
                    BOOL soundsEnabled = userNotificationSettings.types & UIUserNotificationTypeSound;
                    [self getRemoteNotificationTypesResult:command:noneEnabled:alertsEnabled:badgesEnabled:soundsEnabled];
                }
            } else {
                // iOS7 and below
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
                UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
                BOOL oneEnabled = enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone;
                BOOL alertsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeAlert;
                BOOL badgesEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeBadge;
                BOOL soundsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeSound;
                [self getRemoteNotificationTypesResult:command:noneEnabled:alertsEnabled:badgesEnabled:soundsEnabled];
#endif
            }
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}
- (void) getRemoteNotificationTypesResult: (CDVInvokedUrlCommand*)command :(BOOL)noneEnabled :(BOOL)alertsEnabled :(BOOL)badgesEnabled :(BOOL)soundsEnabled
{
    // iOS 8+
    NSMutableDictionary* types = [[NSMutableDictionary alloc]init];
    if(alertsEnabled) {
        [types setValue:@"1" forKey:REMOTE_NOTIFICATIONS_ALERT];
    } else {
        [types setValue:@"0" forKey:REMOTE_NOTIFICATIONS_ALERT];
    }
    if(badgesEnabled) {
        [types setValue:@"1" forKey:REMOTE_NOTIFICATIONS_BADGE];
    } else {
        [types setValue:@"0" forKey:REMOTE_NOTIFICATIONS_BADGE];
    }
    if(soundsEnabled) {
        [types setValue:@"1" forKey:REMOTE_NOTIFICATIONS_SOUND];
    } else {;
        [types setValue:@"0" forKey:REMOTE_NOTIFICATIONS_SOUND];
    }
    [self sendPluginResultString:[self objectToJsonString:types]:command];
}


- (void) isRegisteredForRemoteNotifications: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                // iOS8+
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
                [self _isRegisteredForRemoteNotifications:^(BOOL registered) {
                    [self sendPluginResultBool:registered :command];
                }];
                
#endif
            } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_7_0
                // iOS7 and below
                UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
                BOOL registered; = enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
                [self sendPluginResultBool:registered :command];
#endif
            }
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception :command];
        }
    }];
}

- (void) getRemoteNotificationsAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            if(NSClassFromString(@"UNUserNotificationCenter")) {
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                // iOS 10+
                UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSString* status = UNKNOWN;
                    UNAuthorizationStatus authStatus = settings.authorizationStatus;
                    if(authStatus == UNAuthorizationStatusDenied){
                        status = AUTHORIZATION_DENIED;
                    }else if(authStatus == UNAuthorizationStatusNotDetermined){
                        status = AUTHORIZATION_NOT_DETERMINED;
                    }else if(authStatus == UNAuthorizationStatusAuthorized){
                        status = AUTHORIZATION_GRANTED;
                    }
                    [self logDebug:[NSString stringWithFormat:@"Remote notifications authorization status is: %@", status]];
                    [self sendPluginResultString:status:command];
                }];
#endif
            } else{
                // iOS <= 9
                [self sendPluginError:@"getRemoteNotificationsAuthorizationStatus() is not supported below iOS 10":command];
            }
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception:command];
        }
    }];
}

- (void) requestRemoteNotificationsAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* s_options = [command.arguments objectAtIndex:0];
            if([self isNull:s_options]){
                NSArray* a_options = [NSArray arrayWithObjects:REMOTE_NOTIFICATIONS_ALERT, REMOTE_NOTIFICATIONS_SOUND, REMOTE_NOTIFICATIONS_BADGE, nil];
                s_options = [self arrayToJsonString:a_options];
            }
            NSDictionary* d_options = [self jsonStringToDictionary:s_options];
            
            if(NSClassFromString(@"UNUserNotificationCenter")) {
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                // iOS 10+
                BOOL omitRegistration = [[command argumentAtIndex:1] boolValue];
                UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    UNAuthorizationStatus authStatus = settings.authorizationStatus;
                    if(authStatus == UNAuthorizationStatusNotDetermined){
                        UNAuthorizationOptions options = 0;
                        for(id key in d_options){
                            NSString* s_key = (NSString*) key;
                            if([s_key isEqualToString:REMOTE_NOTIFICATIONS_ALERT]){
                                options = options + UNAuthorizationOptionAlert;
                            }else if([s_key isEqualToString:REMOTE_NOTIFICATIONS_SOUND]){
                                options = options + UNAuthorizationOptionSound;
                            }else if([s_key isEqualToString:REMOTE_NOTIFICATIONS_BADGE]){
                                options = options + UNAuthorizationOptionBadge;
                            }
                        }
                        
                        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
                            if(error != nil){
                                [self sendPluginError:[NSString stringWithFormat:@"Error when requesting remote notifications authorization: %@", error] :command];
                            }else if (granted) {
                                [self logDebug:@"Remote notifications authorization granted"];
                                if(!omitRegistration){
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                                        [self sendPluginResultString:AUTHORIZATION_GRANTED:command];
                                    });
                                }else{
                                    [self sendPluginResultString:AUTHORIZATION_GRANTED:command];
                                }
                            }else{
                                [self sendPluginError:@"Remote notifications authorization was denied" :command];
                            }
                        }];
                    }else if(authStatus == UNAuthorizationStatusAuthorized){
                        [self logDebug:@"Remote notifications already authorized"];
                        if(!omitRegistration){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication] registerForRemoteNotifications];
                                [self sendPluginResultString:AUTHORIZATION_GRANTED:command];
                            });
                        }else{
                            [self sendPluginResultString:AUTHORIZATION_GRANTED:command];
                        }
                        [self sendPluginResultString:@"already_authorized":command];
                    }else if(authStatus == UNAuthorizationStatusDenied){
                        [self sendPluginError:@"Remote notifications authorization is denied" :command];
                    }
                }];
#endif
            } else if(NSClassFromString(@"UIUserNotificationSettings")){
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
                // iOS 8 & 9
                UIUserNotificationType types = 0;
                for(id key in d_options){
                    NSString* s_key = (NSString*) key;
                    if([s_key isEqualToString:REMOTE_NOTIFICATIONS_ALERT]){
                        types = types + UIUserNotificationTypeAlert;
                    }else if([s_key isEqualToString:REMOTE_NOTIFICATIONS_SOUND]){
                        types = types + UIUserNotificationTypeSound;
                    }else if([s_key isEqualToString:REMOTE_NOTIFICATIONS_BADGE]){
                        types = types + UIUserNotificationTypeBadge;
                    }
                }
                UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
                    [self sendPluginResultString:AUTHORIZATION_GRANTED:command];
                });
#endif
            } else{
                // iOS < 8
                [self sendPluginError:@"requestRemoteNotificationsAuthorization() is not supported below iOS 8" :command];
            }
        }
        @catch (NSException *exception) {
            [self handlePluginException:exception:command];
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

- (void)executeGlobalJavascript: (NSString*)jsString{
    [self.commandDelegate evalJs:jsString];
}


/********************************/
#pragma mark - utility functions
/********************************/

- (void)logDebug: (NSString*)msg{
    if(debugEnabled){
        NSLog(@"%@: %@", LOG_TAG, msg);
        NSString* jsString = [NSString stringWithFormat:@"console.log(\"%@: %@\")", LOG_TAG, [self escapeDoubleQuotes:msg]];
        [self executeGlobalJavascript:jsString];
    }
}

- (void)logError: (NSString*)msg{
    NSLog(@"%@ ERROR: %@", LOG_TAG, msg);
    if(debugEnabled){
        NSString* jsString = [NSString stringWithFormat:@"console.error(\"%@: %@\")", LOG_TAG, [self escapeDoubleQuotes:msg]];
        [self executeGlobalJavascript:jsString];
    }
}

- (NSString*)escapeDoubleQuotes: (NSString*)str{
    NSString *result =[str stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""];
    return result;
}

- (void) setSetting: (NSString*)key forValue:(id)value{
    
    [self.settings setObject:value forKey:key];
    [self.settings synchronize];
}

- (id) getSetting: (NSString*) key{
    return [self.settings objectForKey:key];
}

- (void) _isRegisteredForRemoteNotifications:(void (^)(BOOL result))completeBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL registered = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
        if( completeBlock ){
            completeBlock(registered);
        }
    });
};

- (BOOL) isMotionAvailable
{
    return [CMMotionActivityManager isActivityAvailable];
}

- (BOOL) isMotionRequestOutcomeAvailable
{
    return [CMPedometer respondsToSelector:@selector(isPedometerEventTrackingAvailable)] && [CMPedometer isPedometerEventTrackingAvailable];
}


- (NSString*) getLocationAuthorizationStatusAsString: (CLAuthorizationStatus)authStatus
{
    NSString* status;
    if(authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted){
        status = AUTHORIZATION_DENIED;
    }else if(authStatus == kCLAuthorizationStatusNotDetermined){
        status = AUTHORIZATION_NOT_DETERMINED;
    }else if(authStatus == kCLAuthorizationStatusAuthorizedAlways){
        status = AUTHORIZATION_GRANTED;
    }else if(authStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        status = @"authorized_when_in_use";
    }
    return status;
}

- (BOOL) isLocationAuthorized
{
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    if([status  isEqual: AUTHORIZATION_GRANTED] || [status  isEqual: @"authorized_when_in_use"]) {
        return true;
    } else {
        return false;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)authStatus {
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    BOOL statusChanged = false;
    if(self.currentLocationAuthorizationStatus != nil && ![status isEqual: self.currentLocationAuthorizationStatus]){
        statusChanged = true;
    }
    self.currentLocationAuthorizationStatus = status;
    
    if(!statusChanged) return;
    
    
    [self logDebug:[NSString stringWithFormat:@"Location authorization status changed to: %@", status]];
    
    if(self.locationRequestCallbackId != nil){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.locationRequestCallbackId];
        self.locationRequestCallbackId = nil;
    }
    
    [self executeGlobalJavascript:[NSString stringWithFormat:@"cordova.plugins.diagnostic._onLocationStateChange(\"%@\");", status]];
}

- (BOOL) isCameraPresent
{
    BOOL cameraAvailable =
    [UIImagePickerController
     isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(cameraAvailable) {
        [self logDebug:@"Camera available"];
        return true;
    }
    else {
        [self logDebug:@"Camera unavailable"];
        return false;
    }
}

- (BOOL) isCameraAuthorized
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        return true;
    } else {
        return false;
    }
}

- (NSString*) getCameraRollAuthorizationStatus
{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    return [self getCameraRollAuthorizationStatusAsString:authStatus];
    
}

- (NSString*) getCameraRollAuthorizationStatusAsString: (PHAuthorizationStatus)authStatus
{
    NSString* status;
    if(authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted){
        status = AUTHORIZATION_DENIED;
    }else if(authStatus == PHAuthorizationStatusNotDetermined ){
        status = AUTHORIZATION_NOT_DETERMINED;
    }else if(authStatus == PHAuthorizationStatusAuthorized){
        status = AUTHORIZATION_GRANTED;
    }
    return status;
}

- (BOOL) connectedToWifi  // Don't work on iOS Simulator, only in the device
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    
    if (getifaddrs(&addresses) != 0) {
        return NO;
    }
    
    cursor = addresses;
    while (cursor != NULL)  {
        if (cursor -> ifa_addr -> sa_family == AF_INET && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                
                [self logDebug:@"Wifi ON"];
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    freeifaddrs(addresses);
    return wiFiAvailable;
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


- (NSString*)getBluetoothState{
    NSString* state;
    NSString* description;
    
    switch(self.bluetoothManager.state)
    {
            
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        case CBManagerStateResetting:
#else
        case CBCentralManagerStateResetting:
#endif
            state = @"resetting";
            description =@"The connection with the system service was momentarily lost, update imminent.";
            break;
            
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        case CBManagerStateUnsupported:
#else
        case CBCentralManagerStateUnsupported:
#endif
            state = @"unsupported";
            description = @"The platform doesn't support Bluetooth Low Energy.";
            break;
            
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        case CBManagerStateUnauthorized:
#else
        case CBCentralManagerStateUnauthorized:
#endif
            state = @"unauthorized";
            description = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
            
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        case CBManagerStatePoweredOff:
#else
        case CBCentralManagerStatePoweredOff:
#endif
            state = @"powered_off";
            description = @"Bluetooth is currently powered off.";
            break;
            
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        case CBManagerStatePoweredOn:
#else
        case CBCentralManagerStatePoweredOn:
#endif
            state = @"powered_on";
            description = @"Bluetooth is currently powered on and available to use.";
            break;
        default:
            state = UNKNOWN;
            description = @"State unknown, update imminent.";
            break;
    }
    [self logDebug:[NSString stringWithFormat:@"Bluetooth state changed: %@",description]];
    
    
    return state;
}

/********************************/
#pragma mark - CBCentralManagerDelegate
/********************************/

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSString* state = [self getBluetoothState];
    NSString* jsString = [NSString stringWithFormat:@"cordova.plugins.diagnostic._onBluetoothStateChange(\"%@\");", state];
    [self executeGlobalJavascript:jsString];
}

@end


