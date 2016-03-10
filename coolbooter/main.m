//
//  main.m
//  coolbooter
//
//  Created by Ethan Arbuckle on 2/26/16.
//  Copyright © 2016 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBAppDelegate.h"

int main(int argc, char * argv[]) {
    
    if (!(setuid(0) == 0 && setgid(0) == 0))
    {
        NSLog(@"Failed");
    }
    else
        NSLog(@"root ");
    
    @autoreleasepool {

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CBAppDelegate class]));
    }
}
