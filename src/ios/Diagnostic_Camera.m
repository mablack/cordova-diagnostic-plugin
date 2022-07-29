/*
 *  Diagnostic_Camera.m
 *  Diagnostic Plugin - Camera Module
 *
 *  Copyright (c) 2018 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import "Diagnostic_Camera.h"


@implementation Diagnostic_Camera

// Internal reference to Diagnostic singleton instance
static Diagnostic* diagnostic;

// Internal constants
static NSString*const LOG_TAG = @"Diagnostic_Camera[native]";

static NSString*const PHOTOLIBRARY_ACCESS_LEVEL_ADD_ONLY = @"add_only";
static NSString*const PHOTOLIBRARY_ACCESS_LEVEL_READ_WRITE = @"read_write";

- (void)pluginInitialize {
    
    [super pluginInitialize];

    diagnostic = [Diagnostic getInstance];
}

/********************************/
#pragma mark - Plugin API
/********************************/

- (void) isCameraAvailable: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [diagnostic sendPluginResultBool:[self isCameraPresent] && [self isCameraAuthorized] :command];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) isCameraPresent: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [diagnostic sendPluginResultBool:[self isCameraPresent] :command];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [diagnostic sendPluginResultBool:[self isCameraAuthorized] :command];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
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
            [diagnostic logDebug:[NSString stringWithFormat:@"Camera authorization status is: %@", status]];
            [diagnostic sendPluginResultString:status:command];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                [diagnostic sendPluginResultBool:granted :command];
            }];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            bool isAuthorized = [[self resolveCameraRollAuthorizationStatusFromCommand:command]  isEqual: AUTHORIZATION_GRANTED] || [[self resolveCameraRollAuthorizationStatusFromCommand:command]  isEqual: AUTHORIZATION_LIMITED];
            [diagnostic sendPluginResultBool:isAuthorized:command];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status = [self resolveCameraRollAuthorizationStatusFromCommand:command];
            [diagnostic logDebug:[NSString stringWithFormat:@"Camera Roll authorization status is: %@", status]];
            [diagnostic sendPluginResultString:status:command];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) requestCameraRollAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            if (@available(iOS 14.0, *)){
                PHAccessLevel ph_accessLevel = [self resolveAccessLevelFromArgument:[command.arguments objectAtIndex:0]];
                
                [PHPhotoLibrary requestAuthorizationForAccessLevel:ph_accessLevel handler:^(PHAuthorizationStatus authStatus) {
                    NSString* status = [self getCameraRollAuthorizationStatusAsString:authStatus];
                    [diagnostic sendPluginResultString:status:command];
                }];
                
            }else{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authStatus) {
                    NSString* status = [self getCameraRollAuthorizationStatusAsString:authStatus];
                    [diagnostic sendPluginResultString:status:command];
                }];
            }
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) presentLimitedLibraryPicker: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* authStatus = [self resolveCameraRollAuthorizationStatusFromString:PHOTOLIBRARY_ACCESS_LEVEL_ADD_ONLY];
            if(![authStatus isEqualToString:AUTHORIZATION_LIMITED]){
                [diagnostic sendPluginError:[NSString stringWithFormat:@"Limited photo library access UI can only be shown when auth status is AUTHORIZATION_LIMITED but auth status is %@", authStatus]:command];
            }
            else if (@available(iOS 15.0, *)){
                [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:self.viewController completionHandler:^(NSArray<NSString *> * _Nonnull identifiers) {
                    NSString* jsonArray = [diagnostic arrayToJsonString:identifiers];
                    [diagnostic sendPluginResultString:jsonArray :command];
                }];
                [diagnostic sendPluginNoResultAndKeepCallback:command];
            }
            else if (@available(iOS 14.0, *)){
                [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:self.viewController];
                [diagnostic sendPluginResultSuccess:command];
            }else{
                [diagnostic sendPluginError:@"Limited photo library access UI is not supported on iOS < 14" :command];
            }
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}


/********************************/
#pragma mark - Internals
/********************************/

- (BOOL) isCameraPresent
{
    BOOL cameraAvailable =
    [UIImagePickerController
     isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(cameraAvailable) {
        [diagnostic logDebug:@"Camera available"];
        return true;
    }
    else {
        [diagnostic logDebug:@"Camera unavailable"];
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

- (NSString*) resolveCameraRollAuthorizationStatusFromCommand: (CDVInvokedUrlCommand*)command{
    return [self resolveCameraRollAuthorizationStatusFromString:[command.arguments objectAtIndex:0]];
}

- (NSString*) resolveCameraRollAuthorizationStatusFromString: (NSString*)s_accessLevel{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (@available(iOS 14.0, *)){
        PHAccessLevel ph_accessLevel = [self resolveAccessLevelFromArgument:s_accessLevel];
        authStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:ph_accessLevel];
    }else{
        authStatus = [PHPhotoLibrary authorizationStatus];
    }
    return [self getCameraRollAuthorizationStatusAsString:authStatus];
}

- (NSString*) getCameraRollAuthorizationStatusAsString: (PHAuthorizationStatus)authStatus
{
    NSString* status = UNKNOWN;
    if (@available(iOS 14.0, *)){
        if(authStatus == PHAuthorizationStatusLimited ){
            status = AUTHORIZATION_LIMITED;
        }
    }
    
    if([status isEqualToString:UNKNOWN]){
        if(authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted){
            status = AUTHORIZATION_DENIED;
        }else if(authStatus == PHAuthorizationStatusNotDetermined ){
            status = AUTHORIZATION_NOT_DETERMINED;
        }else if(authStatus == PHAuthorizationStatusAuthorized){
            status = AUTHORIZATION_GRANTED;
        }
    }
    
    return status;
}

- (PHAccessLevel) resolveAccessLevelFromArgument:(NSString*) s_accessLevel API_AVAILABLE(ios(14)){
    PHAccessLevel ph_accessLevel;
    if([s_accessLevel isEqualToString:PHOTOLIBRARY_ACCESS_LEVEL_READ_WRITE]){
        ph_accessLevel = PHAccessLevelReadWrite;
    }else{
        ph_accessLevel = PHAccessLevelAddOnly;
    }
    return ph_accessLevel;
}

@end
