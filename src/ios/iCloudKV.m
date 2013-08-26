//
//  iCloudKV.m
//  Cordova iCloud key-value storage cloud
//  Copyright (c) by Alex Drel 2012

#import "iCloudKV.h"

@interface iCloudKV (private)
- (void) cloudNotification:(NSNotification *)receivedNotification;
@end

@implementation iCloudKV

-(void)sync:(CDVInvokedUrlCommand *)command  
{
    [self.commandDelegate runInBackground:^{
        BOOL success = [[NSUbiquitousKeyValueStore defaultStore] synchronize];

        if (success)
        {
            NSDictionary    *dict = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            NSLog(@"iCloudKV synchronized.");
        }
        else
        {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"synchronize failed"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            NSLog(@"iCloudKV synchronize failed.");
        }
    }];
}

-(void)save:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *key = [command.arguments objectAtIndex:0];
        NSString *value = [command.arguments objectAtIndex:1];
    
        [[NSUbiquitousKeyValueStore defaultStore] setString:value forKey:key];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


-(void)load:(CDVInvokedUrlCommand *)command  
{
    [self.commandDelegate runInBackground:^{
        NSString *key = [command.arguments objectAtIndex:0];
        NSString *value = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:key];
        if (value) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            NSLog(@"iCloudKV loaded string: %@", key);
        }
        else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"key is missing"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            NSLog(@"iCloudKV load string failed: %@", key);
        }
    }];
}

-(void)remove:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *key = [command.arguments objectAtIndex:0];
    
        [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:key];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)monitor:(CDVInvokedUrlCommand *)command  
{
    //The first argument in the arguments parameter is the callbackId.
    //We use this to send data back to the successCallback or failureCallback
    //through CDVPluginResult.
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(cloudNotification:)
                                             name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification 
                                             object:[NSUbiquitousKeyValueStore defaultStore]];
            
    NSLog(@"iCloudKV registered for notification");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)cloudNotification:(NSNotification *)receivedNotification
{
    NSLog(@"iCloudKV: cloudData notification");

    int cause=[[[receivedNotification userInfo] valueForKey:NSUbiquitousKeyValueStoreChangeReasonKey] intValue];
    
    switch(cause) {
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            NSLog(@"iCloudKV storage quota exceeded.");
            break;
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            NSLog(@"iCloudKV initial sync notification.");
            break;
        case NSUbiquitousKeyValueStoreServerChange:
            NSLog(@"iCloudKV server change notification.");
            NSDictionary    *changedKeys   = [[receivedNotification userInfo] valueForKey:NSUbiquitousKeyValueStoreChangedKeysKey];

            NSString *jsStatement = [NSString stringWithFormat:@"iCloudKV.onChange(%@);", [NSJSONSerialization dataWithJSONObject:changedKeys options:NSJSONWritingPrettyPrinted error:nil]];
            [self writeJavascript:jsStatement];
            break;
    }
}


@end