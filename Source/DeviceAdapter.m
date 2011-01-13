//
//  DeviceAdapter.m
//  mobileDeviceManager
//
//  Created by Taras Kalapun on 12.01.11.
//  Copyright 2011 Ciklum. All rights reserved.
//

#import "DeviceAdapter.h"


@implementation DeviceAdapter

@synthesize iosDevice;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        [[MobileDeviceAccess singleton] setListener:self];
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    self.iosDevice = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark MobileDeviceAccessListener

- (void)deviceConnected:(AMDevice*)device
{
	
    self.iosDevice = device;
    
    /*
	AFCApplicationDirectory *appDir = [device newAFCApplicationDirectory:@"com.lexcycle.stanza"];
	NSLog(@"app dir : %@", appDir);
	
	NSArray *files = [appDir directoryContents:@"/Documents"];
	NSLog(@"app dir files: %@", files);
	
	[appDir copyLocalFile:@"/desktop.p12" toRemoteDir:@"/Documents"];
	
	files = [appDir directoryContents:@"/Documents"];
	NSLog(@"app dir files: %@", files);
    */
}

- (void)deviceDisconnected:(AMDevice*)device
{
    self.iosDevice = nil;
}


- (BOOL)isDeviceConnected {
    
    if (self.iosDevice) return YES;
    
    return NO;
}

- (NSString *)getAppIdForName:(NSString *)appName
{
    NSArray *appList = [self.iosDevice installedApplications];
    for (AMApplication *app in appList) {
        if ([[app appname] isEqualToString:appName]) {
            return [app bundleid];
        }
        
    }
    return nil;
}

@end
