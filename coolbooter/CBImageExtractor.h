//
//  CBImageExtractor.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/26/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "dmg.h"
#include "filevault.h"
#include "libxpwn.h"

@interface CBImageExtractor : NSObject

+ (void)extractImage:(NSString *)inFile toPath:(NSString *)outFile withKey:(NSString *)key;

@end
