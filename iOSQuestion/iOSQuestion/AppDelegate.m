//
//  AppDelegate.m
//  iOSQuestion
//
//  Created by zhangshumeng on 2020/8/29.
//  Copyright © 2020 zhangshumeng. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.windown = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.windown.backgroundColor = [UIColor whiteColor];
    self.windown.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    [self.windown makeKeyAndVisible];
    
    return YES;
}

@end
