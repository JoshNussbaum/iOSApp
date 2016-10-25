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
#import "NSString+FontAwesome.h"
#import "Flurry.h"

@interface SettingsViewController (){
    user *currentUser;
    JSBadgeView *badgeView;
    JSBadgeView *badgeView2;
    JSBadgeView *badgeView3;
    MBProgressHUD *hud;
    NSInteger flag;
    ConnectionHandler *webHandler;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    NSArray *buttons = @[self.orderStampsButton, self.registerStudentsButton, self.registerTeacherStamp, self.studentListButton, self.stampIdentifierButton, self.unregisterAllStampsButton, self.classTutorialButton, self.registerStudentsButton];
    
    NSArray *icons = @[self.registerTeacherIcon, self.registerTeacherIcon, self.studentListIcon, self.stampIdentifierIcon, self.unregisterAllStampsIcon, self.classTutorialIcon, self.registerStudentsIcon, self.orderStampsIcon];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImg1"]];

    
    for (UIButton *button in buttons){
        [Utilities makeRoundedButton:button :nil];
        button.exclusiveTouch = YES;
    }
    for (UILabel *icon in icons){
        icon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    }

    
    //self.studentListButton.titleLabel.text = [NSString stringWithFormat:@"Student List %@", [NSString fontAwesomeIconStringForEnum:FAList]];
    [self.studentListButton setTitle:@"Student List" forState:UIControlStateNormal ];
    self.studentListIcon.text = [NSString fontAwesomeIconStringForEnum:FAList];
    [self.classTutorialButton setTitle:@"Class Tutorial" forState:UIControlStateNormal];
    self.classTutorialIcon.text = [NSString fontAwesomeIconStringForEnum:FAQuestionCircle];
    [self.registerTeacherStamp setTitle:@"Manage Teacher Stamp" forState:UIControlStateNormal];
    self.registerTeacherIcon.text = [NSString fontAwesomeIconStringForEnum:FAStar];
    [self.unregisterAllStampsButton setTitle:@"Unregister All Students" forState:UIControlStateNormal];
    self.unregisterAllStampsIcon.text = [NSString fontAwesomeIconStringForEnum:FAExclamationTriangle];
    [self.stampIdentifierButton setTitle:@"Stamp Identifier" forState:UIControlStateNormal];
    self.stampIdentifierIcon.text = [NSString fontAwesomeIconStringForEnum:FALightbulbO];
    [self.registerStudentsButton setTitle:@"Register Students" forState:UIControlStateNormal];
    self.registerStudentsIcon.text = [NSString fontAwesomeIconStringForEnum:FAchild];
    [self.orderStampsButton setTitle:@"Order Stamps" forState:UIControlStateNormal];
    self.orderStampsIcon.text = [NSString fontAwesomeIconStringForEnum:FAShoppingCart];
    
}


- (void)viewDidAppear:(BOOL)animated{
    [self checkAccountStatus];
    
}


- (IBAction)classTutorialClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_tutorial" sender:self];
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)editTeacherClicked:(id)sender {
    [self performSegueWithIdentifier:@"settings_to_edit_teacher" sender:self];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    else{
        [self activityStart:@"Unregistering all stamps..."];
        [webHandler unregisterAllStampsWithClassId:[currentUser.currentClass getId]];
    }
}


- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    [hud hide:YES];

    if (data == nil){
        [Utilities alertStatusNoConnection];
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    NSString *message = [data objectForKey:@"message"];
    
    if([successNumber boolValue] == YES)
    {
        if (type == UNREGISTER_ALL_STUDENTS){
            [[DatabaseHandler getSharedInstance]unregisterAllStudentsInClassWithid:[currentUser.currentClass getId]];
            [Utilities alertStatusWithTitle:@"Successfully unregistered all students" message:message cancel:nil otherTitles:nil tag:0 view:self];
            [self checkAccountStatus];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Unregister All Students" withParameters:params];
        }
        
    }
    
    else {
        NSString *message = [data objectForKey:@"message"];
        NSString *errorMessage;
        if (type == UNREGISTER_ALL_STUDENTS){
            errorMessage = @"Error unregistering all students";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:nil];
    }
}


- (void)checkAccountStatus{
    currentUser = [user getInstance];
    [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
    if (currentUser.serial == nil){
        badgeView = [[JSBadgeView alloc] initWithParentView:self.registerTeacherStampView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = @"!";
        badgeView.badgeTextColor=[UIColor whiteColor];
        badgeView.badgeBackgroundColor = [UIColor redColor];
    }
    else {
        [badgeView removeFromSuperview];
    }
    NSInteger unregisteredStudents = [[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]];
    if (unregisteredStudents > 0){
        badgeView3 = [[JSBadgeView alloc] initWithParentView:self.registerStudentsView alignment:JSBadgeViewAlignmentTopRight];
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        badgeView3.badgeText = [NSString stringWithFormat:@"%ld", (long)unregisteredStudents];
        badgeView3.badgeTextColor=[UIColor whiteColor];
        badgeView3.badgeBackgroundColor = [UIColor redColor];
    }
    else {
        [badgeView3 removeFromSuperview];
    }
    
}


- (void)activityStart :(NSString *)message {
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
    else if ([segue.identifier isEqualToString:@"settings_unwind_to_register_students"]){
        RegisterStudentsViewController *vc = [segue destinationViewController];
        [vc setFlag:3];
    }
}


@end
