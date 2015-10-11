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
#import "AwardViewController.h"
#import "ClassJarViewController.h"
#import "MarketViewController.h"
#import "StudentsTableViewController.h"
#import "BBBadgeBarButtonItem.h"


@interface HomeViewController (){
    user *currentUser;
    NSInteger flag;
    NSArray *statsViews;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentUser = [user getInstance];
    [currentUser printUser];
    
    [Utilities makeRoundedButton:self.registerStudentsButton :nil];
    [Utilities makeRoundedButton:self.createClassButton :nil];
    [Utilities makeRoundedButton:self.classesButton :nil];
    [Utilities makeRoundedButton:self.settingsButton :nil];
    NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
    self.teacherNameLabel.text = name;
    self.classNameLabel.text = [currentUser.currentClass getName];
    self.schoolNameLabel.text = [[DatabaseHandler getSharedInstance] getSchoolName:[currentUser.currentClass getSchoolId]];
    self.title  = @"Home Screen";
}


-(void)viewDidAppear:(BOOL)animated{
    currentUser = [user getInstance];

    NSInteger unregisteredStudents = [[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]];
    if (unregisteredStudents > 0){
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.registerStudentsView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = [NSString stringWithFormat:@"%ld", (long)unregisteredStudents];
        badgeView.badgeTextColor=[UIColor whiteColor];
        badgeView.badgeBackgroundColor = [UIColor redColor];
  
    }
    
    classjar *jar = [[DatabaseHandler getSharedInstance] getClassJar:[currentUser.currentClass getId]];
    
    [jar printJar];
    
    self.jarProgressBar.progress = (float)[jar getProgress] / (float)[jar getTotal];
    
    self.classLevelProgressBar.progress = (float)[currentUser.currentClass getProgress] / (float)[currentUser.currentClass getNextLevel];
    
    
    if (!currentUser.serial){
        NSLog(@"In here, serials %@", currentUser.serial);
        BBBadgeBarButtonItem *barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:self.settingsButton];
        barButton.badgeValue = @"2";
        NSInteger size = self.view.frame.size.width/4 - 28;
        barButton.badgeOriginX = size;
        barButton.badgeOriginY = -5;
        barButton.shouldHideBadgeAtZero = YES;
        barButton.shouldAnimateBadge = YES;
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    NSMutableDictionary *classStats = [[DatabaseHandler getSharedInstance]getClassStats:[currentUser.currentClass getId]];
    
    self.classAvgLevelLabel.text = [NSString stringWithFormat:@"%d", [[classStats objectForKey:@"averageLevel"] integerValue]];
    self.classAvgPointsLabel.text = [NSString stringWithFormat:@"%d", [[classStats objectForKey:@"averagePoints"] integerValue]];


}


- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
}


- (IBAction)swipeDown:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionFromTop;    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    StudentsTableViewController *stvc = [storyboard instantiateViewControllerWithIdentifier:@"StudentsTableViewController"];
    [self.navigationController pushViewController:stvc animated:NO];
}


- (IBAction)awardClicked:(id)sender {
    [self performSegueWithIdentifier:@"home_to_award" sender:nil];
}


- (IBAction)classJarClicked:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    AwardViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"AwardViewController"];
    ClassJarViewController *cjvc = [storyboard instantiateViewControllerWithIdentifier:@"ClassJarViewController"];
    [self.navigationController pushViewController:avc animated:NO];
    [self.navigationController pushViewController:cjvc animated:NO];
    
}


- (IBAction)marketClicked:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    AwardViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"AwardViewController"];
    ClassJarViewController *cjvc = [storyboard instantiateViewControllerWithIdentifier:@"ClassJarViewController"];
    MarketViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"MarketViewController"];
    [self.navigationController pushViewController:avc animated:NO];
    [self.navigationController pushViewController:cjvc animated:NO];
    [self.navigationController pushViewController:mvc animated:NO];

}

- (IBAction)settingsClicked:(id)sender {
    [self performSegueWithIdentifier:@"home_to_settings" sender:self];
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


- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue {
    
}


@end
