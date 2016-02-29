//
//  CBFirmwareProfile.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/29/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBFirmwareProfile : NSObject

@property (nonatomic, retain) NSMutableDictionary *firmwareProfile;

- (void)addObject:(id)settingObject forSetting:(NSString *)settingKey;
- (id)retrieveSetting:(NSString *)settingKey;

@end
