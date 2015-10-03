/*
 *  Diagnostic.h
 *  Plugin diagnostic
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import "Diagnostic.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK



@implementation Diagnostic

- (void)pluginInitialize {
    
    [super pluginInitialize];
    
    self.bluetoothManager = [[CBCentralManager alloc]
                             initWithDelegate:self
                             queue:dispatch_get_main_queue()
                             options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
}

/*************
 * Plugin API
 *************/

// Location
- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if([CLLocationManager locationServicesEnabled] && [self isLocationAuthorized]) {   
        NSLog(@"Location is enabled.");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];   
    }
    else {
        NSLog(@"Location is disabled.");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (void) isLocationEnabledSetting: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if([CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location Services is enabled");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    }
    else {
        NSLog(@"Location Services is disabled");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    
    if([self isLocationAuthorized]) {
        NSLog(@"This app is authorized to use location.");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    } else {
        NSLog(@"This app is not authorized to use location.");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    NSString* status = @"unknown";
    int locationAuthorization = [CLLocationManager authorizationStatus];
    
    if(locationAuthorization == kCLAuthorizationStatusDenied || locationAuthorization == kCLAuthorizationStatusRestricted){
        status = @"denied";
    }else if(locationAuthorization == kCLAuthorizationStatusNotDetermined){
        status = @"not_determined";
    }else if(locationAuthorization == kCLAuthorizationStatusAuthorizedAlways){
        status = @"authorized_always";
    }else if(locationAuthorization == kCLAuthorizationStatusAuthorizedWhenInUse){
        status = @"authorized_when_in_use";
    }
    NSLog([NSString stringWithFormat:@"Location authorization status is: %@", status]);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


// Camera
- (void) isCameraEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if([self isCameraPresent] && [self isCameraAuthorized]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) isCameraPresent: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if([self isCameraPresent]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if([self isCameraAuthorized]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    NSString* status = @"unknown";
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        status = @"not_determined";
    }else if(authStatus == AVAuthorizationStatusAuthorized){
        status = @"authorized";
    }
    NSLog([NSString stringWithFormat:@"Camera authorization status is: %@", status]);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
   
}

- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if([self getCameraRollAuthorizationStatus] == @"authorized") {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    NSString* status = [self getCameraRollAuthorizationStatus];

    NSLog([NSString stringWithFormat:@"Camera Roll authorization status is: %@", status]);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
   
}

// Wifi
- (void) isWifiEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if([self connectedToWifi]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Bluetooth
- (void) isBluetoothEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if(self.bluetoothEnabled) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];    
}

- (void) switchToSettings: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if (UIApplicationOpenSettingsURLString != nil){
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not supported below iOS 8"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/*********************
 * Internal functions
 *********************/
 
- (BOOL) isLocationAuthorized
{
     if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
         return true;
     } else {
         return false;
     }
}

- (BOOL) isCameraPresent
{
    BOOL cameraAvailable = 
    [UIImagePickerController 
     isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(cameraAvailable) {
        NSLog(@"Camera available");
        return true;
    }
    else {
        NSLog(@"Camera unavailable");
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
    CDVPluginResult* pluginResult;
    NSString* status = @"unknown";
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    
    if(authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == PHAuthorizationStatusNotDetermined ){
        status = @"not_determined";
    }else if(authStatus == PHAuthorizationStatusAuthorized){
        status = @"authorized";
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
                
                NSLog(@"Wifi ON");
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    freeifaddrs(addresses);
    return wiFiAvailable;
}


#pragma mark - CBCentralManagerDelegate

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"Bluetooth enabled");
        self.bluetoothEnabled = true;
    }
    else {
        NSLog(@"Bluetooth disabled or unavailable");
        self.bluetoothEnabled = false;
    }
}

@end
