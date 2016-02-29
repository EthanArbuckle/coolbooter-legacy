//
//  CBFirmwareProfile.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/29/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "CBFirmwareProfile.h"

@implementation CBFirmwareProfile

- (id)init {
    
    if ((self = [super init])) {
        
        /*
         * tempFolder
         * firmwareURL
         * iBECPatchURL
         * kernelPatchURL
         * rootfs @{ pathLocation, iv, key }
         * restoreRamdisk @{ pathLocation, iv, key }
         * appleLogo @{ pathLocation, iv, key }
         * deviceTree @{ pathLocation, iv, key }
         * iBoot @{ pathLocation, iv, key }
         * LLB @{ pathLocation, iv, key }
         * kernelCache @{ pathLocation, iv, key }
         * iBEC @{ pathLocation, iv, key }
         * iBSS @{ pathLocation, iv, key }
         */
        _firmwareProfile = [[NSMutableDictionary alloc] initWithCapacity:12];
        
    }
                 
    return self;
}

- (void)addObject:(id)settingObject forSetting:(NSString *)settingKey {
    
    if (settingKey && settingObject) {
        
        if (_firmwareProfile) {
            
            if ([_firmwareProfile valueForKey:settingKey]) {
                
                NSLog(@"overwriting %@", [_firmwareProfile valueForKey:settingKey]);
            }
            
            [_firmwareProfile setValue:settingObject forKey:settingKey];
        }
    }
}

- (id)retrieveSetting:(NSString *)settingKey {
    
    if (_firmwareProfile && [_firmwareProfile valueForKey:settingKey]) {
        
        return [_firmwareProfile valueForKey:settingKey];
    }
    
    NSLog(@"failed to find setting %@", settingKey);
    
    //return an actual object as to not cause crashes
    return @"";
}

@end
