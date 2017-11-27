//
//  main.m
//  mobileDeviceManager
//
//  Created by Taras Kalapun on 12.01.11.
//  Copyright 2011 Ciklum. All rights reserved.
//  SVN: http://slim@svn.dev.iccoss.com/repos/trunk/Mac/mobile_device_manager/
//

#import <Foundation/Foundation.h>
#import "DeviceAdapter.h"
#import "MobileDeviceAccess.h"

int main (int argc, const char * argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    
    //get arguments
	NSUserDefaults *arguments = [NSUserDefaults standardUserDefaults];
	NSString *option = [arguments stringForKey:@"o"];
    
    if	(!option) {
        printf("\n\
The script usage:\n\n\
Copy file from desktop to device (App Documents) or specify path with filename:\n\
    mobileDeviceManager -o push -app \"Application_ID\" -from \"from file\" [-to \"to file\"]\n\
Copy file from device to desktop (Current folder) or specify path with filename:\n\
    mobileDeviceManager -o pull -app \"Application_ID\" -from \"from file\" [-to \"to file\"]\n\
List Applications:\n\
    mobileDeviceManager -o list\n\
List Files in Application Documents (path):\n\
    mobileDeviceManager -o listFiles -app Appliction_ID [-path /Documents]\n\
Delete Files in Application Documents (path):\n\
    mobileDeviceManager -o delete -app Appliction_ID [-path /Documents]\n\
Get appId for application name:\n\
    mobileDeviceManager -o getAppId -name Application_Name\n\
Show device info:\n\
    mobileDeviceManager -o info\n");
        return 1001;
	}
    
    DeviceAdapter *adapter = [[DeviceAdapter alloc] init];
	
    
    while(!adapter.iosDevice && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        // Here you can perform other checks, like making sure the method isn't running forever (with a timeout variable)
        // Just set callComplete to YES when done
    }
    
    AMDevice *device = adapter.iosDevice;
    
    
    if ([option isEqualToString:@"copy"] || [option isEqualToString:@"push"]) {
        NSLog(@"Will copy to Device: %@", device);
        
        NSString *fromFile = [arguments stringForKey:@"from"];
        NSString *toFile = [arguments stringForKey:@"to"];
        NSString *appId = [arguments stringForKey:@"app"];
        
        if (!fromFile || !appId) {
            NSLog(@"no fromFile | no appId");
            return 1001;
        }
        
        AFCApplicationDirectory *appDir = [device newAFCApplicationDirectory:appId];
        
        NSArray *files = [appDir directoryContents:@"/Documents"];
        NSLog(@"app Documents files: %@", files);
        
        if (!toFile) {
            [appDir copyLocalFile:fromFile toRemoteDir:@"/Documents"];
        } else {
            [appDir copyLocalFile:fromFile toRemoteFile:toFile];
        }
        
        files = [appDir directoryContents:@"/Documents"];
        NSLog(@"app Documents files: %@", files);
        
    } else if ([option isEqualToString:@"pull"]) {
        NSLog(@"Will copy from Device: %@", device);

        NSString *fromFile = [arguments stringForKey:@"from"];
        NSString *toFile = [arguments stringForKey:@"to"];
        NSString *appId = [arguments stringForKey:@"app"];

        if (!fromFile || !appId) {
            NSLog(@"no fromFile | no appId");
            return 1001;
        }

        AFCApplicationDirectory *appDir = [device newAFCApplicationDirectory:appId];

        NSArray *files = [appDir directoryContents:@"/Documents"];
        NSLog(@"app Documents files: %@", files);

        NSDictionary *finfo =[appDir getFileInfo:fromFile];
        NSString *iftm = [finfo valueForKey:@"st_ifmt"];
        BOOL isDir = [iftm compare:@"S_IFDIR"] == NSOrderedSame;
        if (isDir) {
            NSArray *files = [appDir directoryContents:fromFile];
            for (NSString *fname in files) {
                NSLog(@"Copy %@", fname);
                NSString *src = [fromFile stringByAppendingPathComponent:fname];
                [appDir copyRemoteFile:src toLocalDir:(toFile ? toFile : @".")];
            }
        } else {
            if (!toFile) {
                [appDir copyRemoteFile:fromFile toLocalDir:@"."];
            } else {
                [appDir copyRemoteFile:fromFile toLocalFile:toFile];
            }
        }
    } else if ([option isEqualToString:@"delete"]) {

        NSString *path = [arguments stringForKey:@"path"];
        NSString *appId = [arguments stringForKey:@"app"];

        if (!appId) {
            NSLog(@"no appId");
            return 1001;
        }

        AFCApplicationDirectory *appDir = [device newAFCApplicationDirectory:appId];

        if (!path) path = @"/Documents";

        NSDictionary *finfo =[appDir getFileInfo:path];
        NSString *iftm = [finfo valueForKey:@"st_ifmt"];
        BOOL isDir = [iftm compare:@"S_IFDIR"] == NSOrderedSame;
        if (isDir) {
            NSArray *files = [appDir directoryContents:path];
            for (NSString *fname in files) {
                NSLog(@"Delete %@", fname);
                NSString *dest = [path stringByAppendingPathComponent:fname];
                [appDir unlink:dest];
            }
        } else {
            NSLog(@"Delete %@", path);
            [appDir unlink:path];
        }
    } else if ([option isEqualToString:@"listFiles"]) {
        
        NSString *path = [arguments stringForKey:@"path"];
        NSString *appId = [arguments stringForKey:@"app"];
        
        if (!appId) {
            NSLog(@"no appId");
            return 1001;
        }
        
        AFCApplicationDirectory *appDir = [device newAFCApplicationDirectory:appId];
        
        if (!path) path = @"/Documents";

        NSArray *files = [appDir directoryContents:path];
        
        NSLog(@"Files in %@ : %@", path, files);
        
    } else if ([option isEqualToString:@"list"]) {
        NSArray *apps = [device installedApplications];
        NSLog(@"Installed Applications: %@", apps);

    } else if ([option isEqualToString:@"info"]) {
        NSLog(@"Device connected: %@", device);
    } else if ([option isEqualToString:@"getAppId"]) {
        NSString *appName = [arguments stringForKey:@"name"];
        NSString *appId = [adapter getAppIdForName:appName];
        printf("%s\n", [appId UTF8String]);
    }
    
    [pool drain];
    return 0;
}

