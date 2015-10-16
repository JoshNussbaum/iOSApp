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
#import "StudentsTableViewController.h"

@interface SettingsViewController (){
    user *currentUser;
    JSBadgeView *badgeView;
    JSBadgeView *badgeView2;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utilities makeRoundedButton:self.orderStampsButton :nil];
    [Utilities makeRoundedButton:self.registerTeacherStamp :nil];
    [Utilities makeRoundedButton:self.studentListButton :nil];
    

}

- (void)viewDidAppear:(BOOL)animated{
    currentUser = [user getInstance];
    [self checkAccountStatus];
}

- (void)checkAccountStatus{
    [currentUser printUser];
    if (!currentUser.serial){
        NSLog(@"IN HERE");
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        badgeView = [[JSBadgeView alloc] initWithParentView:self.registerTeacherStampView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = @"1";
        badgeView.badgeTextColor=[UIColor whiteColor];
        badgeView.badgeBackgroundColor = [UIColor redColor];
        
        badgeView2 = [[JSBadgeView alloc] initWithParentView:self.orderStampsView alignment:JSBadgeViewAlignmentTopRight];
        badgeView2.badgeText = @"1";
        badgeView2.badgeTextColor=[UIColor whiteColor];
        badgeView2.badgeBackgroundColor = [UIColor redColor];
        
    }
    else {
        [badgeView removeFromSuperview];
        [badgeView2 removeFromSuperview];
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

- (IBAction)studentListClicked:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    StudentsTableViewController *stvc = [storyboard instantiateViewControllerWithIdentifier:@"StudentsTableViewController"];
    [self.navigationController pushViewController:stvc animated:NO];
}

- (IBAction)editTeacherClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_edit_teacher" sender:self];
}

@end
