/*
 *  Diagnostic_Notifications.h
 *  Diagnostic Plugin - Notifications Module
 *
 *  Copyright (c) 2018 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import "Diagnostic.h"
#import <UserNotifications/UserNotifications.h>

@interface Diagnostic_Notifications : CDVPlugin

- (void) isRemoteNotificationsEnabled: (CDVInvokedUrlCommand*)command;
- (void) getRemoteNotificationTypes: (CDVInvokedUrlCommand*)command;
- (void) isRegisteredForRemoteNotifications: (CDVInvokedUrlCommand*)command;
- (void) getRemoteNotificationsAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestRemoteNotificationsAuthorization: (CDVInvokedUrlCommand*)command;

@end
