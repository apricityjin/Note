//
//  AppDelegate.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "ViewController.h"

@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    
    ViewController * vc = [[ViewController alloc] init];
    NavigationController * nav = [[NavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
