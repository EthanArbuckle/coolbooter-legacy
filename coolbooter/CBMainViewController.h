//
//  CBMainViewController.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/25/16.
//
//

#import <UIKit/UIKit.h>
#import "CBDeviceInfo.h"
#import "CBFirmwareDownloader.h"
#import "SSZipArchive.h"
#import "CBImageDecrypter.h"
#import "CBImagePatcher.h"

@interface CBMainViewController : UIViewController <CBFirmwareDownloaderDelegate>

@end
