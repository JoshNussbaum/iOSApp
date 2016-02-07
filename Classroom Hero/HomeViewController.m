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
    
    self.title  = @"Home Screen";
    currentUser = [user getInstance];
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
    self.teacherNameLabel.text = name;
    self.classNameLabel.text = [currentUser.currentClass getName];
    self.schoolNameLabel.text = [[DatabaseHandler getSharedInstance] getSchoolName:[currentUser.currentClass getSchoolId]];
    [self configureProgressBars];
    
    NSArray *buttons = @[self.settingsButton, self.classesButton, self.settingsButton, self.attendanceButton];
    for (UIButton *button in buttons){
        [Utilities makeRoundedButton:button :nil];
        button.exclusiveTouch = YES;
    }
    NSArray *menuButtons = @[self.homeButton, self.awardButton, self.jarButton, self.marketButton];
    for (UIButton *button in menuButtons){
        button.exclusiveTouch = YES;
    }
    
    NSArray *statsViews = @[self.classAvgLevelView, self.classAvgPointsView, self.classTotalStampsView];
    
    for (UIView *view in statsViews){
        [view.layer setCornerRadius:30.0f];
    }
    
}


- (void)viewDidAppear:(BOOL)animated{
    currentUser = [user getInstance];
    
    classjar *jar = [[DatabaseHandler getSharedInstance] getClassJar:[currentUser.currentClass getId]];
    
    if (jar != nil){
        [self.jarProgressBar setProgress:((float)[jar getProgress] / (float)[jar getTotal]) animated:YES ];
        
    }
    else {
        [self.jarProgressBar setProgress:0.0f animated:YES ];
    }
    self.classLevelLabel.text = [NSString stringWithFormat:@"Class  Level:  %ld", [currentUser.currentClass getLevel]];
    [self.classProgressBar setProgress:(float)[currentUser.currentClass getProgress] / (float)[currentUser.currentClass getNextLevel] animated:YES];

    NSInteger unregisteredStudents = [[DatabaseHandler getSharedInstance]getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]];
    
    if (!currentUser.serial || unregisteredStudents > 0){
        [[JSBadgeView appearance] setBadgeBackgroundColor:UIColor.blackColor];
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.settingsView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = @"!";
        badgeView.badgeTextColor=[UIColor whiteColor];
        badgeView.badgeBackgroundColor = [UIColor redColor];
    }
    
    NSMutableDictionary *classStats = [[DatabaseHandler getSharedInstance]getClassStats:[currentUser.currentClass getId]];
    NSInteger totalStamps = 0;
    NSInteger partialProgress = 3 + (([currentUser.currentClass getLevel] - 2) * 2);
    totalStamps = partialProgress + [currentUser.currentClass getProgress];
    self.classAvgLevelLabel.text = [NSString stringWithFormat:@"%ld", [[classStats objectForKey:@"averageLevel"] integerValue]];
    self.classAvgPointsLabel.text = [NSString stringWithFormat:@"%ld", [[classStats objectForKey:@"averagePoints"] integerValue]];
    self.classTotalStampsLabel.text = [NSString stringWithFormat:@"%ld", (long)totalStamps];
}


- (IBAction)classesClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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


- (void)configureProgressBars{
    self.classLevelLabel.text = [NSString stringWithFormat:@"Class  Level:  %ld", [currentUser.currentClass getLevel]];
    
    BOOL customized = NO;
    [self.classProgressBar setProgressBarTrackColor:[Utilities CHGreenColor]];
    [self.classProgressBar setProgressBarWidth:(5.0f)];
    [self.classProgressBar  setProgressBarProgressColor:[UIColor colorWithRed:233.0/255.0 green:195/255.0 blue:56.0/255.0 alpha:1.0]];
    [self.classProgressBar setBackgroundColor:[UIColor clearColor]];
    
    [self.classProgressBar  setHintViewSpacing:(customized ? 10.0f : 0)];
    [self.classProgressBar  setHintViewBackgroundColor:[UIColor clearColor]];
    [self.classProgressBar  setHintTextFont:[UIFont fontWithName:@"Gil Sans" size:12.0f]];
    [self.classProgressBar  setHintTextColor:[UIColor blackColor]];
    [self.classProgressBar  setHintTextGenerationBlock:(customized ? ^NSString *(CGFloat progress) {
        return [NSString stringWithFormat:@"%.0f / 255", progress * 255];
    } : nil)];
    
    
    [self.jarProgressBar setProgressBarTrackColor:[Utilities CHGreenColor]];
    [self.jarProgressBar setProgressBarWidth:(5.0f)];
    [self.jarProgressBar  setProgressBarProgressColor:[UIColor colorWithRed:233.0/255.0 green:195/255.0 blue:56.0/255.0 alpha:1.0]];
    [self.jarProgressBar setBackgroundColor:[UIColor clearColor]];
    
    
    [self.jarProgressBar  setHintViewSpacing:(customized ? 10.0f : 0)];
    [self.jarProgressBar  setHintViewBackgroundColor:[UIColor clearColor]];
    [self.jarProgressBar  setHintTextFont:[UIFont fontWithName:@"Gil Sans" size:12.0f]];
    [self.jarProgressBar  setHintTextColor:[UIColor blackColor]];
    [self.jarProgressBar  setHintTextGenerationBlock:(customized ? ^NSString *(CGFloat progress) {
        return [NSString stringWithFormat:@"%.0f / 255", progress * 255];
    } : nil)];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"home_to_settings"]){
        SettingsViewController *vc = [segue destinationViewController];
        [vc setFlag:flag];
    }
    
}


- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue {
    
}


- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
}



@end
