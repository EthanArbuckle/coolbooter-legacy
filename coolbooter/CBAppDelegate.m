#import "CBAppDelegate.h"

@implementation CBAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[CBMainViewController alloc] init]];
    [_window setRootViewController:_rootViewController];
	[_window makeKeyAndVisible];
    
}

@end
