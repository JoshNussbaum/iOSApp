//
//  SettingsViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/27/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "SettingsViewController.h"
#import "Utilities.h"
#import "user.h"
#import "JSBadgeView.h"

@interface SettingsViewController (){
    user *currentUser;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self checkAccountStatus];
    [Utilities makeRoundedButton:self.orderStampsButton :nil];
    [Utilities makeRoundedButton:self.registerTeacherStamp :nil];
    [Utilities makeRoundedButton:self.activityMonitorButton :nil];
    

}

- (void)viewDidAppear:(BOOL)animated{
    currentUser = [user getInstance];
    [self checkAccountStatus];
}

- (void)checkAccountStatus{
    if (!currentUser.serial){
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.registerTeacherStampView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = @"1";
        badgeView.badgeTextColor=[UIColor whiteColor];
        badgeView.badgeBackgroundColor = [UIColor redColor];
        
        JSBadgeView *badgeView2 = [[JSBadgeView alloc] initWithParentView:self.orderStampsView alignment:JSBadgeViewAlignmentTopRight];
        badgeView2.badgeText = @"1";
        badgeView2.badgeTextColor=[UIColor whiteColor];
        badgeView2.badgeBackgroundColor = [UIColor redColor];
        
    }
}


- (IBAction)orderStampsClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_order_stamps" sender:self];
}

- (IBAction)registerTeacherStampClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_register_teacher_stamp" sender:self];
}

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editTeacherClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_edit_teacher" sender:self];
}

@end
