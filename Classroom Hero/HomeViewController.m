//
//  HomeViewController.m
//  Classroom Hero
//
//  Created by Josh on 8/22/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "HomeViewController.h"
#import "user.h"
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "TutorialViewController.h"
#import "RegisterStudentsViewController.h"


@interface HomeViewController (){
    user *currentUser;
    NSInteger flag;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    [Utilities makeRoundedButton:self.registerStudentsButton :nil];
    [Utilities makeRoundedButton:self.createClassButton :nil];
    NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
    self.teacherNameLabel.text = name;
    self.classNameLabel.text = [currentUser.currentClass getName];
    self.schoolNameLabel.text = [[DatabaseHandler getSharedInstance] getSchoolName:[currentUser.currentClass getSchoolId]];
    self.title  = @"Home Screen";
}

-(void)viewDidAppear:(BOOL)animated{
    NSInteger unregisteredStudents = [[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]];
    if (unregisteredStudents > 0){
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.registerStudentsView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = [NSString stringWithFormat:@"%ld", (long)unregisteredStudents];
        badgeView.badgeTextColor=[UIColor whiteColor];
        badgeView.badgeBackgroundColor = [UIColor redColor];
        badgeView.badgeStrokeColor = [UIColor whiteColor];
    }
}


- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
}

- (IBAction)tutorialClicked:(id)sender {
    [self performSegueWithIdentifier:@"home_to_tutorial" sender:nil];
}

- (IBAction)registerStudentsClicked:(id)sender {
    if (flag == 1){
        if ([[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]] != 0){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (flag == 2){
        if ([[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]] != 0){
            [self performSegueWithIdentifier:@"home_to_register_students" sender:nil];
        }
    }
  
}

- (IBAction)classesClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"home_to_tutorial"]){
        TutorialViewController *vc = [segue destinationViewController];
        [vc setFlag:2];
    }
    else if ([segue.identifier isEqualToString:@"home_to_register_students"]){
        RegisterStudentsViewController *vc = [segue destinationViewController];
        [vc setFlag:2];
    }
    
}



@end
