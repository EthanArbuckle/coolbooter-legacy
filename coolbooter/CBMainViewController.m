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
        
        CBFirmwareProfile *currentProfile = [[CBFirmwareProfile alloc] init];
        [currentProfile addObject:@"/Users/ethanarbuckle/Desktop" forSetting:@"tempFolder"];
        [currentProfile addObject:@"http://192.168.1.80/iPhone3,3_6.1.3_10B329_Restore.ipsw" forSetting:@"firmwareURL"];
        [currentProfile addObject:@"http://192.168.1.80/iBEC.patch" forSetting:@"iBECPatchURL"];
        [currentProfile addObject:@"http://192.168.1.80/kern.patch" forSetting:@"kernelPatchURL"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/048-2443-005.dmg", @"iv" : @"", @"key" : @"3ad3f6163e6d6307f7149ae980df922725718f32f28554d8969cbdb92349e3c79de9b623" } forSetting:@"rootfs"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/048-2441-007.dmg", @"iv" : @"e7c082ad98b5fe0ed45bc95531db50e6", @"key" : @"6328b0e17dd264f5eaa21ce9b135119924407cce39f7d396e631f5e7ee3e6087" } forSetting:@"restoreRamdisk"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/Firmware/all_flash/all_flash.n92ap.production/applelogo@2x.s5l8930x.img3", @"iv" : @"02c61d93a817034d49edb0ad1ef4e77e", @"key" : @"ac48545272fa0c0bd806d9e9e9f3d923e650f5d114b1f9aeef4dd2da326e680c" } forSetting:@"appleLogo"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/Firmware/all_flash/all_flash.n92ap.production/DeviceTree.n92ap.img3", @"iv" : @"1cb06e4050a72fca0b6884f0be6468d4", @"key" : @"7c11ffa50c2eb5d5e02712f2698d9245662b91a1da2b0acfe1804df8aec2013e" } forSetting:@"deviceTree"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/Firmware/all_flash/all_flash.n92ap.production/iBoot.n92ap.RELEASE.img3", @"iv" : @"f4d653e506183d11e4119c1bc26f2f72", @"key" : @"18d3f8be91cb921bbb0253678d277b71a53594613715e842eb1eedc20aa29165" } forSetting:@"iBoot"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/Firmware/all_flash/all_flash.n92ap.production/LLB.n92ap.RELEASE.img3", @"iv" : @"5f00cd0c7fa0014010889426d4df2b34", @"key" : @"c4922f622095cda348ad00c0149e9ff609c68459d085d932b09c5cf5a83e6419" } forSetting:@"LLB"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/kernelcache.release.n92", @"iv" : @"98c715c105cde8aad13dcde4d6164c69", @"key" : @"c68c527fad5b101bf6f3342548d434425f0e1370f05fbaf4ff2cd57f1d9a16c9" } forSetting:@"kernelCache"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/Firmware/dfu/iBEC.n92ap.RELEASE.dfu", @"iv" : @"da1a960590726a66f23d6418602d6e63", @"key" : @"6e8292914a5597610f7d76fdc25ee88ad5240c19591f071f4993cbdefa902019" } forSetting:@"iBEC"];
        
        [currentProfile addObject:@{ @"pathLocation" : @"%@/firmware_stuff/expanded_firmware/Firmware/dfu/iBSS.n92ap.RELEASE.dfu", @"iv" : @"293cc706282984db11e1d4e44d9d5709", @"key" : @"a383c3055d8a6f5350226cb2af458e29aa38abda3672c38d8d63dfa1118988c8" } forSetting:@"iBSS"];
        
        _manager = [[CBOperationManager alloc] initWithProfile:currentProfile];
                
        [_manager beginFresh];
        
    }
    
    return self;
}


@end
