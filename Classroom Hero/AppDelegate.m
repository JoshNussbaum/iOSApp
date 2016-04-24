//
//  AppDelegate.m
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "AppDelegate.h"
#import "Utilities.h"
#import "Stripe.h"
#import "Flurry.h"

@interface AppDelegate ()

@end

NSString * const StripePublishableKey = @" pk_test_0k5cvVSHQihOyTbRCUHXm9T2 ";

@implementation AppDelegate

- (int)checkOSVersion {
    
    NSArray *ver = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    int osVerson = [[ver objectAtIndex:0] intValue];
    return osVerson;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Stripe setDefaultPublishableKey:StripePublishableKey];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    if ([self checkOSVersion] >= 7) {
        if ([Utilities isIPadPro]){
            [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                    NSFontAttributeName: [UIFont fontWithName:@"Gill Sans" size:44.0f],
                                                                    NSShadowAttributeName: shadow
                                                                    }];
        }
        else{
            [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                    NSFontAttributeName: [UIFont fontWithName:@"Gill Sans" size:38.0f],
                                                                    NSShadowAttributeName: shadow
                                                                    }];
        }
    } else {
        [[UINavigationBar appearance] setTintColor:[Utilities CHBlueColor]];
    }
    
    [Flurry startSession:@"646YZ8K3TTSHHSK43QKZ"];
    [Flurry setDebugLogEnabled:YES];
    
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
