//
//  CBImageDecrypter.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/26/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libxpwn.h"
#include "nor_files.h"

@interface CBImageDecrypter : NSObject

+ (void)decryptImageAtLocation:(NSString *)file key:(NSString *)key iv:(NSString *)iv toFile:(NSString *)outFile;

@end
