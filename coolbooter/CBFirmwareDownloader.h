//
//  CBFirmwareDownloader.h
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/25/16.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@protocol CBFirmwareDownloaderDelegate <NSObject>
- (void)downloadProgressChanged:(CGFloat)progress;
- (void)downloadFailedWithError:(NSError *)error;
- (void)downloadCompleted;
@end

@interface CBFirmwareDownloader : NSObject

- (id)initWithDelegate:(id)delegate;
- (void)downloadFileFromURL:(NSString *)urlString toLocation:(NSString *)fileLocation reportProgress:(BOOL)showProgress;

@property (nonatomic, weak) id <CBFirmwareDownloaderDelegate> delegate;

@end
