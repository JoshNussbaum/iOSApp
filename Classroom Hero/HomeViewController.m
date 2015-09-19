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


@interface HomeViewController (){
    user *currentUser;
    NSInteger flag;
    NSArray *statsViews;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    statsViews = @[self.avgPointsView, self.highestLvlView, self.mostUsedCategoryView, self.loewstLevelView, self.mostSoldItemView, self.biggestSpenderView];
    
    currentUser = [user getInstance];
    [Utilities makeRoundedButton:self.registerStudentsButton :nil];
    [Utilities makeRoundedButton:self.createClassButton :nil];
    [Utilities makeRoundedButton:self.orderStampsButton :nil];
    [Utilities makeRoundedButton:self.classesButton :nil];
    [Utilities makeRoundedButton:self.settingsButton :nil];
    NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
    self.teacherNameLabel.text = name;
    self.classNameLabel.text = [currentUser.currentClass getName];
    self.schoolNameLabel.text = [[DatabaseHandler getSharedInstance] getSchoolName:[currentUser.currentClass getSchoolId]];
    self.title  = @"Home Screen";
    
    if (currentUser.accountStatus <= 1){
        for (UIView *view in statsViews){
            view.hidden = YES;
        }
        self.orderStampsButton.hidden = NO;
        self.orderStampsButton.enabled = YES;
        self.classStatsLabel.hidden = YES;
        
    }
    else{
        for (UIView *view in statsViews){
            view.hidden = NO;
        }
        self.orderStampsButton.hidden = YES;
        self.orderStampsButton.enabled = NO;
        self.classStatsLabel.hidden = NO;
    }
}


-(void)viewDidAppear:(BOOL)animated{
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
    

}


- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
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


- (IBAction)orderStampsClicked:(id)sender {
    [self performSegueWithIdentifier:@"home_to_order_stamps" sender:nil];
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
