//
//  CBMainViewController.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/25/16.
//
//

#import "CBMainViewController.h"

@implementation CBMainViewController

- (id)init {
    
    if ((self = [super init])) {
        
        [[self navigationItem] setTitle:[CBDeviceInfo productType]];
        [[self view] setBackgroundColor:[UIColor whiteColor]];
        
        [self beginFresh];
        
    }
    
    return self;
}

- (void)beginFresh {
    
    //check if firmware isnt already present
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Users/ethanarbuckle/Desktop/firmware_stuff/stock_firmware.zip"]) {
        
        //download it
        CBFirmwareDownloader *fw = [[CBFirmwareDownloader alloc] initWithDelegate:self];
        [fw downloadFileFromURL:@"http://localhost/iPhone3,3_6.1.3_10B329_Restore.ipsw" toLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/stock_firmware.zip" reportProgress:YES];
        
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
    [self unzipOperationFinished];return;
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Users/ethanarbuckle/Desktop/firmware_stuff/stock_firmware.zip"]) {
        
        NSLog(@"firmware file doesnt exist");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [SSZipArchive unzipFileAtPath:@"/Users/ethanarbuckle/Desktop/firmware_stuff/stock_firmware.zip" toDestination:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/" progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
            
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
    [CBImageDecrypter decryptImageAtLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/048-2441-007.dmg" key:@"6328b0e17dd264f5eaa21ce9b135119924407cce39f7d396e631f5e7ee3e6087" iv:@"e7c082ad98b5fe0ed45bc95531db50e6" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.restoreramdisk.dmg"];
    
    NSLog(@"applelogo...");
    [CBImageDecrypter decryptImageAtLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/Firmware/all_flash/all_flash.n92ap.production/applelogo@2x.s5l8930x.img3" key:@"ac48545272fa0c0bd806d9e9e9f3d923e650f5d114b1f9aeef4dd2da326e680c" iv:@"02c61d93a817034d49edb0ad1ef4e77e" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.applelogo.img3"];
    
    NSLog(@"devicetree...");
    [CBImageDecrypter decryptImageAtLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/Firmware/all_flash/all_flash.n92ap.production/DeviceTree.n92ap.img3" key:@"7c11ffa50c2eb5d5e02712f2698d9245662b91a1da2b0acfe1804df8aec2013e" iv:@"1cb06e4050a72fca0b6884f0be6468d4" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.devicetree.img3"];
    
    NSLog(@"iboot...");
    [CBImageDecrypter decryptImageAtLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/Firmware/all_flash/all_flash.n92ap.production/iBoot.n92ap.RELEASE.img3" key:@"18d3f8be91cb921bbb0253678d277b71a53594613715e842eb1eedc20aa29165" iv:@"f4d653e506183d11e4119c1bc26f2f72" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.iboot.img3"];
    
    NSLog(@"llb...");
    [CBImageDecrypter decryptImageAtLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/Firmware/all_flash/all_flash.n92ap.production/LLB.n92ap.RELEASE.img3" key:@"c4922f622095cda348ad00c0149e9ff609c68459d085d932b09c5cf5a83e6419" iv:@"5f00cd0c7fa0014010889426d4df2b34" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.llb.img3"];
    
    NSLog(@"kernelcache...");
    [CBImageDecrypter decryptImageAtLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/kernelcache.release.n92" key:@"c68c527fad5b101bf6f3342548d434425f0e1370f05fbaf4ff2cd57f1d9a16c9" iv:@"98c715c105cde8aad13dcde4d6164c69" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.kernelcache"];
    
    NSLog(@"ibec...");
    [CBImageDecrypter decryptImageAtLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/Firmware/dfu/iBEC.n92ap.RELEASE.dfu" key:@"6e8292914a5597610f7d76fdc25ee88ad5240c19591f071f4993cbdefa902019" iv:@"da1a960590726a66f23d6418602d6e63" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.ibec.dfu"];
    
    NSLog(@"applying patches");
    [CBImagePatcher applyPatchAtURL:@"http://localhost/iBEC.patch" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.ibec.dfu" saveLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/patched.dec.ibec.dfu"];
    [CBImagePatcher applyPatchAtURL:@"http://localhost/kern.patch" toFile:@"/Users/ethanarbuckle/Desktop/firmware_stuff/dec.kernelcache" saveLocation:@"/Users/ethanarbuckle/Desktop/firmware_stuff/patched.dec.kernelcache"];
    
    NSLog(@"decrypting rootfs");
    [CBImageExtractor extractImage:@"/Users/ethanarbuckle/Desktop/firmware_stuff/expanded_firmware/048-2443-005.dmg" toPath:@"/Users/ethanarbuckle/Desktop/firmware_stuff/rootfs.dmg" withKey:@"3ad3f6163e6d6307f7149ae980df922725718f32f28554d8969cbdb92349e3c79de9b623"];
    
}

@end
