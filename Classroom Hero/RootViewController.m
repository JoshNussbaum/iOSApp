//
//  RootViewController.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 2/28/17.
//  Copyright © 2017 Josh Nussbaum. All rights reserved.
//

#import "RootViewController.h"
#import "HomeLeftViewController.h"
#import "HomeRightViewController.h"
#import "HomeMainViewController.h"
#import "HomeNavigationController.h"
#import "Utilities.h"

@interface RootViewController ()

@end

@implementation RootViewController


- (void)initialize{
    HomeLeftViewController *leftVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeLeftViewController"];
    HomeLeftViewController *rightVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeRightViewController"];

    //UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
    //[nc setViewControllers:@[rootVC]];
    UIColor *greenCoverColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.0 alpha:0.3];
    UIColor *purpleCoverColor = [UIColor colorWithRed:0.1 green:0.0 blue:0.1 alpha:0.3];
    UIBlurEffectStyle regularStyle;
    
    if (UIDevice.currentDevice.systemVersion.floatValue >= 10.0) {
        regularStyle = UIBlurEffectStyleRegular;
    }
    else {
        regularStyle = UIBlurEffectStyleLight;
    }
    
    self.leftViewPresentationStyle = LGSideMenuPresentationStyleSlideBelow;
    self.leftViewBackgroundBlurEffect = [UIBlurEffect effectWithStyle:regularStyle];
    self.leftViewBackgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.05];
    self.rootViewCoverColorForLeftView = greenCoverColor;
    
    self.rightViewPresentationStyle = LGSideMenuPresentationStyleSlideBelow;
    self.rightViewBackgroundBlurEffect = [UIBlurEffect effectWithStyle:regularStyle];
    self.rightViewBackgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.05];
    self.rootViewCoverColorForRightView = purpleCoverColor;
    
    
    self.leftViewController = leftVC;
    self.rightViewController = rightVC;
    
    
    
}
- (void) viewWillAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];
    self.navigationController.navigationBar.translucent = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    HomeLeftViewController *leftVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeLeftViewController"];
    HomeLeftViewController *rightVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeRightViewController"];
    HomeMainViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    //UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
    //[nc setViewControllers:@[rootVC]];
    UIColor *greenCoverColor = [UIColor colorWithRed:0.0 green:0.1 blue:0.0 alpha:0.3];
    UIColor *purpleCoverColor = [UIColor colorWithRed:0.1 green:0.0 blue:0.1 alpha:0.3];
    UIBlurEffectStyle regularStyle;
    
    if (UIDevice.currentDevice.systemVersion.floatValue >= 10.0) {
        regularStyle = UIBlurEffectStyleRegular;
    }
    else {
        regularStyle = UIBlurEffectStyleLight;
    }
    
    self.leftViewPresentationStyle = LGSideMenuPresentationStyleSlideAbove;
    self.leftViewBackgroundBlurEffect = [UIBlurEffect effectWithStyle:regularStyle];
    self.leftViewBackgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.05];
    self.rootViewCoverColorForLeftView = greenCoverColor;
    
    self.rightViewPresentationStyle = LGSideMenuPresentationStyleSlideAbove;
    self.rightViewBackgroundBlurEffect = [UIBlurEffect effectWithStyle:regularStyle];
    self.rightViewBackgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.05];
    self.rootViewCoverColorForRightView = purpleCoverColor;
    
    
    self.leftViewController = leftVC;
    self.rightViewController = rightVC;
    
    self.rootViewController = navController;
    
//    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];
//    self.navigationController.navigationBar.translucent = YES;
    // Do any additional setup after loading the view.
}

-(void)backClicked{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super leftViewWillLayoutSubviewsWithSize:size];
    
    if (!self.isLeftViewStatusBarHidden) {
        self.leftView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
    }
}

- (void)rightViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super rightViewWillLayoutSubviewsWithSize:size];
    
    if (!self.isRightViewStatusBarHidden ||
        (self.rightViewAlwaysVisibleOptions & LGSideMenuAlwaysVisibleOnPadLandscape &&
         UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
         UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation))) {
            self.rightView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
        }
}

- (BOOL)isLeftViewStatusBarHidden {
    return NO;
    
    return super.isLeftViewStatusBarHidden;
}

- (BOOL)isRightViewStatusBarHidden {
    return NO;
}

@end
