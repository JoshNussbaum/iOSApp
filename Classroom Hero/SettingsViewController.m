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
    if (currentUser.accountStatus < 2){
        self.registerTeacherStamp.backgroundColor = [Utilities CHRedColor];
    }
    else {
        self.registerTeacherStamp.backgroundColor = [Utilities CHBlueColor];
        
    }
}

/* MAKE REGISTER STUDENTS HAVE THE JSVIEW BADGE */


- (IBAction)orderStampsClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_order_stamps" sender:self];
}

- (IBAction)registerTeacherStampClicked:(id)sender {
}

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editTeacherClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_edit_teacher" sender:self];
}

@end
