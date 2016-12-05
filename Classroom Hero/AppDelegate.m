//
//  AppDelegate.m
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "AppDelegate.h"
#import "Utilities.h"
#import <Google/Analytics.h>


@interface AppDelegate ()

@end


@implementation AppDelegate

- (int)checkOSVersion {
    
    NSArray *ver = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    int osVerson = [[ver objectAtIndex:0] intValue];
    return osVerson;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    if ([self checkOSVersion] >= 7) {
        if ([Utilities isIPadPro]){
            [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                    NSFontAttributeName: [UIFont fontWithName:@"GillSans-Bold" size:44.0f],
                                                                    NSShadowAttributeName: shadow
                                                                    }];
        }
        else{
            [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                    NSFontAttributeName: [UIFont fontWithName:@"GillSans-Bold" size:32.0f],
                                                                    NSShadowAttributeName: shadow
                                                                    }];
        }
    } else {
        [[UINavigationBar appearance] setTintColor:[Utilities CHBlueColor]];
    }
    [[UITextField appearance] setTintColor:[Utilities CHBlueColor]];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
