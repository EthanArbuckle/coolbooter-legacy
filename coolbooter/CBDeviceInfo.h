//
//  CBDeviceInfo.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/25/16.
//
//

#import <Foundation/Foundation.h>
#include <sys/sysctl.h>
#import <objc/runtime.h>
#include <dlfcn.h>

@interface SSDevice : NSObject
+ (id)currentDevice;
- (NSString *)_diskCapacityString;
@end

@interface CBDeviceInfo : NSObject

+ (NSString *)productType;
+ (NSString *)capacity;

@end
