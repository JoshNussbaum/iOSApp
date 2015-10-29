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
#import "MBProgressHUD.h"
#import "DatabaseHandler.h"
#import "RegisterStudentsViewController.h"
#import "TutorialViewController.h"

@interface SettingsViewController (){
    user *currentUser;
    JSBadgeView *badgeView;
    JSBadgeView *badgeView2;
    MBProgressHUD *hud;
    NSInteger flag;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *buttons = @[self.orderStampsButton, self.registerStudentsButton, self.registerTeacherStamp, self.studentListButton, self.stampIdentifierButton, self.unregisterAllStampsButton, self.classTutorialButton, self.registerStudentsButton];
    
    for (UIButton *button in buttons){
        [Utilities makeRoundedButton:button :nil];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    currentUser = [user getInstance];
    [self checkAccountStatus];
    
    
    NSInteger unregisteredStudents = [[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]];
    if (unregisteredStudents > 0){
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        JSBadgeView *badgeView3 = [[JSBadgeView alloc] initWithParentView:self.registerStudentsView alignment:JSBadgeViewAlignmentTopRight];
        badgeView3.badgeText = [NSString stringWithFormat:@"%ld", (long)unregisteredStudents];
        badgeView3.badgeTextColor=[UIColor whiteColor];
        badgeView3.badgeBackgroundColor = [UIColor redColor];
    }
}

- (void)checkAccountStatus{
    [currentUser printUser];
    if (!currentUser.serial){
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        badgeView = [[JSBadgeView alloc] initWithParentView:self.registerTeacherStampView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = @"!";
        badgeView.badgeTextColor=[UIColor whiteColor];
        badgeView.badgeBackgroundColor = [UIColor redColor];
        
        badgeView2 = [[JSBadgeView alloc] initWithParentView:self.orderStampsView alignment:JSBadgeViewAlignmentTopRight];
        badgeView2.badgeText = @"!";
        badgeView2.badgeTextColor=[UIColor whiteColor];
        badgeView2.badgeBackgroundColor = [UIColor redColor];
        
    }
    else {
        [badgeView removeFromSuperview];
        [badgeView2 removeFromSuperview];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    else{
        //[self activityStart:@"Unregistering all stamps..."];
        
    }
}

- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    NSLog(@"In Settings and here is the data =>\n %@", data);
    if (data == nil){
        [Utilities alertStatusNoConnection];
    }
    if (type == UNREGISTER_ALL_STUDENTS){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
        
        if([successNumber boolValue] == YES)
        {
      
            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error unregistering all students" message:message cancel:nil otherTitles:nil tag:0 view:nil];
        }
    }
    [hud hide:YES];
}


- (IBAction)orderStampsClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_order_stamps" sender:self];
}

- (IBAction)classTutorialClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_tutorial" sender:self];
}

- (IBAction)registerStudentsClicked:(id)sender {
    if (flag == 1){
        if ([[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]] != 0){
            [self performSegueWithIdentifier:@"settings_unwind_to_register_students" sender:self];
        }
    }
    else if (flag == 2){
        if ([[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]] != 0){
            [self performSegueWithIdentifier:@"settings_to_register_students" sender:nil];
        }
    }
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

- (IBAction)stampIdentifierClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_stamp_identifier" sender:self];
}

- (IBAction)unregisterAllStampsClicked:(id)sender {
    [Utilities alertStatusWithTitle:@"Confirm unregister" message:@"Unregister all stamps from your class?" cancel:@"Cancel" otherTitles:@[@"Unregister"] tag:1 view:self];
}

- (IBAction)editTeacherClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_edit_teacher" sender:self];
}

- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}

- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settings_to_tutorial"]){
        TutorialViewController *vc = [segue destinationViewController];
        [vc setFlag:2];
    }
    else if ([segue.identifier isEqualToString:@"settings_to_register_students"]){
        RegisterStudentsViewController *vc = [segue destinationViewController];
        [vc setFlag:2];
    }
    
}


@end
