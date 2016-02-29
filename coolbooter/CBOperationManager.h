//
//  CBOperationManager.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/29/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBFirmwareDownloader.h"
#import "SSZipArchive.h"
#import "CBImageDecrypter.h"
#import "CBImagePatcher.h"
#import "CBImageExtractor.h"
#import "CBFirmwareProfile.h"

@interface CBOperationManager : NSObject <CBFirmwareDownloaderDelegate>

@property (nonatomic, retain) CBFirmwareProfile *firmwareProfile;

- (id)initWithProfile:(CBFirmwareProfile *)profile;
- (void)beginFresh;
- (void)beginUnzippingFirmware;
- (void)unzipProgressChanged:(CGFloat)progress;
- (void)unzipOperationFinished;

@end
