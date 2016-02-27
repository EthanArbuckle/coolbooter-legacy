//
//  CBImageExtractor.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/26/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "CBImageExtractor.h"

@implementation CBImageExtractor

+ (void)extractImage:(NSString *)inFile toPath:(NSString *)outFile withKey:(NSString *)key {
    
    AbstractFile* filein;
    AbstractFile* fileout;
    
    TestByteOrder();
    
    if(!buildInOut([inFile UTF8String], [outFile UTF8String], &filein, &fileout)) {
        NSLog(@"failed to populate in/out files");
    }

    filein = createAbstractFileFromFileVault(filein, [key UTF8String]);

    extractDmg(filein, fileout, -1);
    
    NSLog(@"finished writing %@", outFile);
    
}

@end
