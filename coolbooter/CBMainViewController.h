//
//  CBMainViewController.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/25/16.
//
//

#import <UIKit/UIKit.h>
#import "CBDeviceInfo.h"
#import "CBOperationManager.h"
#import "CBFirmwareProfile.h"
#import <AVFoundation/AVFoundation.h>

@interface CBMainViewController : UIViewController

@property (nonatomic, strong) CBOperationManager *manager;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UILabel *status;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end
