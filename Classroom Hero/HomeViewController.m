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
#import "SettingsViewController.h"


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
    NSArray *buttons = @[self.settingsButton, self.classesButton, self.settingsButton, self.attendanceButton];
    for (UIButton *button in buttons){
        [Utilities makeRoundedButton:button :nil];
    }
    NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
    self.teacherNameLabel.text = name;
    self.classNameLabel.text = [currentUser.currentClass getName];
    self.schoolNameLabel.text = [[DatabaseHandler getSharedInstance] getSchoolName:[currentUser.currentClass getSchoolId]];
    self.title  = @"Home Screen";
}


-(void)viewDidAppear:(BOOL)animated{
    currentUser = [user getInstance];
    
    classjar *jar = [[DatabaseHandler getSharedInstance] getClassJar:[currentUser.currentClass getId]];
    
    
    self.jarProgressBar.progress = (float)[jar getProgress] / (float)[jar getTotal];
    
    self.classLevelProgressBar.progress = (float)[currentUser.currentClass getProgress] / (float)[currentUser.currentClass getNextLevel];
    NSInteger unregisteredStudents = [[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]];
    
    if (!currentUser.serial || unregisteredStudents > 0){
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.settingsView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = @"!";
        badgeView.badgeTextColor=[UIColor whiteColor];
        badgeView.badgeBackgroundColor = [UIColor redColor];
    }
    
    NSMutableDictionary *classStats = [[DatabaseHandler getSharedInstance]getClassStats:[currentUser.currentClass getId]];
    
    self.classAvgLevelLabel.text = [NSString stringWithFormat:@"%d", [[classStats objectForKey:@"averageLevel"] integerValue]];
    self.classAvgPointsLabel.text = [NSString stringWithFormat:@"%d", [[classStats objectForKey:@"averagePoints"] integerValue]];


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

- (IBAction)settingsClicked:(id)sender {
    [self performSegueWithIdentifier:@"home_to_settings" sender:self];
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

- (IBAction)attendanceClicked:(id)sender {
    [self performSegueWithIdentifier:@"home_to_attendance" sender:self];
}


- (IBAction)classesClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"home_to_settings"]){
        SettingsViewController *vc = [segue destinationViewController];
        [vc setFlag:flag];
    }
    
}


- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue {
    
}


@end
