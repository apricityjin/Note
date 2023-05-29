//
//  AppDelegate.m
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import "AppDelegate.h"
#import "VlogsViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    VlogsViewController * vc = [[VlogsViewController alloc] init];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = nc;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
