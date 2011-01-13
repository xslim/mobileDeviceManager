//
//  DeviceAdapter.h
//  mobileDeviceManager
//
//  Created by Taras Kalapun on 12.01.11.
//  Copyright 2011 Ciklum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileDeviceAccess.h"

@class DeviceAdapter;

/*
@protocol
@optional
- (void)deviceConnected:(AMDevice *)device;
@end
*/

@interface DeviceAdapter : NSObject 
<MobileDeviceAccessListener>
{
    AMDevice *iosDevice;
}

@property (nonatomic, retain) AMDevice *iosDevice;

- (BOOL)isDeviceConnected;

- (NSString *)getAppIdForName:(NSString *)appName;

@end
