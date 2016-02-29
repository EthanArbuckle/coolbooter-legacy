//
//  CBFirmwareDownloader.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/25/16.
//
//

#import "CBFirmwareDownloader.h"

@implementation CBFirmwareDownloader

- (id)initWithDelegate:(id)delegate {
    
    if ((self = [super init])) {
        
        if (delegate) {
            
            _delegate = delegate;
        }
    
    }
    
    return self;
}

- (void)downloadFileFromURL:(NSString *)urlString toLocation:(NSString *)fileLocation reportProgress:(BOOL)showProgress {
   
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fileLocation append:NO]];
    
    if (showProgress) {

        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {

            if (_delegate && [_delegate respondsToSelector:@selector(downloadProgressChanged:)]) {

                [_delegate downloadProgressChanged:(float)totalBytesRead / totalBytesExpectedToRead];
            }
        }];
    }
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

        if (_delegate && [_delegate respondsToSelector:@selector(downloadCompleted)]) {
            
            [_delegate downloadCompleted];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {

        if (_delegate && [_delegate respondsToSelector:@selector(downloadFailedWithError:)]) {
            
            [_delegate downloadFailedWithError:error];
        }
    }];
    
    [operation start];
    
    
}

@end
