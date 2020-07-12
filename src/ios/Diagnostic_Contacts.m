/*
 *  Diagnostic_Contacts.m
 *  Diagnostic Plugin - Contacts Module
 *
 *  Copyright (c) 2018 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import "Diagnostic_Contacts.h"

@implementation Diagnostic_Contacts

// Internal reference to Diagnostic singleton instance
static Diagnostic* diagnostic;


// Internal constants
static NSString*const LOG_TAG = @"Diagnostic_Contacts[native]";

- (void)pluginInitialize {
    
    [super pluginInitialize];

    diagnostic = [Diagnostic getInstance];

    self.contactStore = [[CNContactStore alloc] init];
}

/********************************/
#pragma mark - Plugin API
/********************************/


- (void) getAddressBookAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            NSString* status;

            CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if(authStatus == CNAuthorizationStatusDenied || authStatus == CNAuthorizationStatusRestricted){
                status = AUTHORIZATION_DENIED;
            }else if(authStatus == CNAuthorizationStatusNotDetermined){
                status = AUTHORIZATION_NOT_DETERMINED;
            }else if(authStatus == CNAuthorizationStatusAuthorized){
                status = AUTHORIZATION_GRANTED;
            }

            [diagnostic logDebug:[NSString stringWithFormat:@"Address book authorization status is: %@", status]];
            [diagnostic sendPluginResultString:status:command];

        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) isAddressBookAuthorized: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            [diagnostic sendPluginResultBool:authStatus == CNAuthorizationStatusAuthorized :command];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}

- (void) requestAddressBookAuthorization: (CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        @try {
            [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(error == nil) {
                    [diagnostic logDebug:[NSString stringWithFormat:@"Access request to address book: %d", granted]];
                    [diagnostic sendPluginResultBool:granted :command];
                }
                else {
                    [diagnostic sendPluginResultBool:FALSE :command];
                }
            }];
        }
        @catch (NSException *exception) {
            [diagnostic handlePluginException:exception :command];
        }
    }];
}


@end
