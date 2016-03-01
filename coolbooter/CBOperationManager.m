//
//  CBOperationManager.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/29/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import "CBOperationManager.h"

@implementation CBOperationManager

- (id)initWithProfile:(CBFirmwareProfile *)profile {
    
    if ((self = [super init])) {
        
        _firmwareProfile = profile;
    }
    
    return self;
}

- (id)init {
    
    NSLog(@"use initWithProfile:");
    return nil;
}

- (void)beginFresh {
    
    //check if firmware isnt already present
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/firmware_stuff/stock_firmware.zip", [_firmwareProfile retrieveSetting:@"tempFolder"]]]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/firmware_stuff", [_firmwareProfile retrieveSetting:@"tempFolder"]] withIntermediateDirectories:NO attributes:nil error:nil];
        
        //download it
        CBFirmwareDownloader *fw = [[CBFirmwareDownloader alloc] initWithDelegate:self];
        [fw downloadFileFromURL:[_firmwareProfile retrieveSetting:@"firmwareURL"] toLocation:[NSString stringWithFormat:@"%@/firmware_stuff/stock_firmware.zip", [_firmwareProfile retrieveSetting:@"tempFolder"]] reportProgress:YES];
        
    } else {
        
        //already downloaded, move on to unzipping
        NSLog(@"firmware already exists");
        [self beginUnzippingFirmware];
    }
}

#pragma mark FirmwareDownloader delegates
- (void)downloadProgressChanged:(CGFloat)progress {
    NSLog(@"progress %.2f%%", progress * 100);
}

- (void)downloadFailedWithError:(NSError *)error {
    NSLog(@"failed to download with error (%@)", error);
}

- (void)downloadCompleted {
    
    NSLog(@"finished download");
    [self beginUnzippingFirmware];
}

#pragma mark - unzipping
- (void)beginUnzippingFirmware {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/firmware_stuff/stock_firmware.zip", [_firmwareProfile retrieveSetting:@"tempFolder"]]]) {
        
        NSLog(@"firmware file doesnt exist");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [SSZipArchive unzipFileAtPath:[NSString stringWithFormat:@"%@/firmware_stuff/stock_firmware.zip", [_firmwareProfile retrieveSetting:@"tempFolder"]] toDestination:[NSString stringWithFormat:@"%@/firmware_stuff/expanded_firmware", [_firmwareProfile retrieveSetting:@"tempFolder"]] progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self unzipProgressChanged:(float)entryNumber / total];
            });
            
        } completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
            
            if (!succeeded) {
                NSLog(@"unzipping failed with error (%@)", error);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self unzipOperationFinished];
            });
            
        }];
        
    });
}

- (void)unzipProgressChanged:(CGFloat)progress {
    NSLog(@"unzip progress %f", progress);
}

- (void)unzipOperationFinished {
    
    NSLog(@"decrypting files");
    
    NSLog(@"restore ramdisk...");
    [CBImageDecrypter decryptImageAtLocation:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"restoreRamdisk"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] key:[_firmwareProfile retrieveSetting:@"restoreRamdisk"][@"key"] iv:[_firmwareProfile retrieveSetting:@"restoreRamdisk"][@"iv"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/expanded_firmware/dec.restoreramdisk.dmg", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"applelogo...");
    [CBImageDecrypter decryptImageAtLocation:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"appleLogo"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] key:[_firmwareProfile retrieveSetting:@"appleLogo"][@"key"] iv:[_firmwareProfile retrieveSetting:@"appleLogo"][@"iv"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.applelogo.img3", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"devicetree...");
    [CBImageDecrypter decryptImageAtLocation:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"deviceTree"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] key:[_firmwareProfile retrieveSetting:@"deviceTree"][@"key"] iv:[_firmwareProfile retrieveSetting:@"deviceTree"][@"iv"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.devicetree.img3", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"iboot...");
    [CBImageDecrypter decryptImageAtLocation:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"iBoot"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] key:[_firmwareProfile retrieveSetting:@"iBoot"][@"key"] iv:[_firmwareProfile retrieveSetting:@"iBoot"][@"iv"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.iboot.img3", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"llb...");
    [CBImageDecrypter decryptImageAtLocation:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"LLB"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] key:[_firmwareProfile retrieveSetting:@"LLB"][@"key"] iv:[_firmwareProfile retrieveSetting:@"LLB"][@"iv"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.llb.img3", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"kernelcache...");
    [CBImageDecrypter decryptImageAtLocation:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"kernelCache"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] key:[_firmwareProfile retrieveSetting:@"kernelCache"][@"key"] iv:[_firmwareProfile retrieveSetting:@"kernelCache"][@"iv"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.kernelcache", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"ibec...");
    [CBImageDecrypter decryptImageAtLocation:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"iBEC"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] key:[_firmwareProfile retrieveSetting:@"iBEC"][@"key"] iv:[_firmwareProfile retrieveSetting:@"iBEC"][@"iv"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.ibec.dfu", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"ibss...");
    [CBImageDecrypter decryptImageAtLocation:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"iBSS"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] key:[_firmwareProfile retrieveSetting:@"iBSS"][@"key"] iv:[_firmwareProfile retrieveSetting:@"iBSS"][@"iv"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.ibss.dfu", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"applying patches");
    [CBImagePatcher applyPatchAtURL:[_firmwareProfile retrieveSetting:@"iBECPatchURL"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.ibec.dfu", [_firmwareProfile retrieveSetting:@"tempFolder"]] saveLocation:[NSString stringWithFormat:@"%@/firmware_stuff/patched.dec.ibec.dfu", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    [CBImagePatcher applyPatchAtURL:[_firmwareProfile retrieveSetting:@"kernelPatchURL"] toFile:[NSString stringWithFormat:@"%@/firmware_stuff/dec.kernelcache", [_firmwareProfile retrieveSetting:@"tempFolder"]] saveLocation:[NSString stringWithFormat:@"%@/firmware_stuff/patched.dec.kernelcache", [_firmwareProfile retrieveSetting:@"tempFolder"]]];
    
    NSLog(@"decrypting rootfs");
    [CBImageExtractor extractImage:[NSString stringWithFormat:[_firmwareProfile retrieveSetting:@"rootfs"][@"pathLocation"], [_firmwareProfile retrieveSetting:@"tempFolder"]] toPath:[NSString stringWithFormat:@"%@/firmware_stuff/rootfs.dmg", [_firmwareProfile retrieveSetting:@"tempFolder"]] withKey:[_firmwareProfile retrieveSetting:@"rootfs"][@"key"]];
    
}

@end
