//
//  CBImageDecrypter.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/26/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "CBImageDecrypter.h"

@implementation CBImageDecrypter

+ (void)decryptImageAtLocation:(NSString *)file key:(NSString *)key iv:(NSString *)iv toFile:(NSString *)outFile {

    unsigned int* uKey;
    unsigned int* uIV;
    size_t bytes;
    
    init_libxpwn(NULL, NULL);

    hexToInts([key UTF8String], &uKey, &bytes);
    hexToInts([iv UTF8String], &uIV, &bytes);
    
    AbstractFile* template = createAbstractFileFromFile(fopen([file UTF8String], "rb"));
    AbstractFile* inFile = openAbstractFile3(createAbstractFileFromFile(fopen([file UTF8String], "rb")), uKey, uIV, 0);
    AbstractFile* outfile_ = createAbstractFileFromFile(fopen([outFile UTF8String], "wb"));
    AbstractFile* newFile = duplicateAbstractFile2(template, outfile_, NULL, NULL, NULL);
    
    size_t inDataSize = (size_t) inFile->getLength(inFile);
    char* inData = (char*) malloc(inDataSize);
    inFile->read(inFile, inData, inDataSize);
    inFile->close(inFile);
    
    newFile->write(newFile, inData, inDataSize);
    newFile->close(newFile);
    
    free(inData);
    free(uKey);
    free(uIV);
}

@end
