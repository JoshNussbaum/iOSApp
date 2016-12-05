//
//  AboutViewController.m
//  Classroom Hero
//
//  Created by Josh on 8/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "AboutViewController.h"
#import "Utilities.h"
#import <Google/Analytics.h>

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"About"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];
    
    // Do any additional setup after loading the view.
    [Utilities makeRoundedButton:self.backButton :nil];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"Gill Sans" size:[Utilities getNavigationBarButtonSize]];
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:40];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
