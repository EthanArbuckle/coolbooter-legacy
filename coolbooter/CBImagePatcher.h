//
//  CBImagePatcher.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/26/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bspatch.h"
#include <bzlib.h>

@interface CBImagePatcher : NSObject

+ (void)applyPatchAtURL:(NSString *)stringURL toFile:(NSString *)file saveLocation:(NSString *)saveLocation;

@end
