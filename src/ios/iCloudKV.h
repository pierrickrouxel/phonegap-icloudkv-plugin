//  iCloudKV.h
//  Copyright (c) by Alex Drel 2012

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface iCloudKV : CDVPlugin 
{    
}

- (void)sync:(CDVInvokedUrlCommand *)command;
- (void)save:(CDVInvokedUrlCommand *)command;
- (void)load:(CDVInvokedUrlCommand *)command;
- (void)remove:(CDVInvokedUrlCommand *)command;
- (void)monitor:(CDVInvokedUrlCommand *)command;
- (void)writeJavascript:(CDVInvokedUrlCommand *)command;

@end
