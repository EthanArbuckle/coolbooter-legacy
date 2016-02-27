//
//  CBDeviceInfo.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/25/16.
//
//

#import "CBDeviceInfo.h"

@implementation CBDeviceInfo

+ (NSString *)productType {
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    return [NSString stringWithFormat:@"%s", machine];
}

+ (NSString *)capacity {
    
    dlopen("/System/Library/PrivateFrameworks/StoreServices.framework/StoreServices", 9);
    if (objc_getClass("SSDevice")) {
        return [[objc_getClass("SSDevice") currentDevice] _diskCapacityString];
    }
    
    return 0;
}

@end