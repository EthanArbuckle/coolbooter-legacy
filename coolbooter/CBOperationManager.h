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

@interface CBMainViewController_ <NSObject>

- (void)updateProgress:(CGFloat)prog;
- (void)updateText:(NSString *)stat;
- (void)createButton;

@end

@interface CBOperationManager : NSObject <CBFirmwareDownloaderDelegate>

@property (nonatomic, retain) CBFirmwareProfile *firmwareProfile;
@property (nonatomic, retain) CBMainViewController_ *delegate;

- (id)initWithProfile:(CBFirmwareProfile *)profile progressCallbacks:(CBMainViewController_ *)vc;
- (void)beginFresh;
- (void)beginUnzippingFirmware;
- (void)unzipProgressChanged:(CGFloat)progress;
- (void)unzipOperationFinished;

@end
