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
#import "AwardViewController.h"
#import "ClassJarViewController.h"
#import "MarketViewController.h"
#import "StudentsTableViewController.h"
#import <Google/Analytics.h>

@interface HomeViewController (){
    user *currentUser;
    NSArray *statsViews;
}

@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title  = @"Home Screen";
    currentUser = [user getInstance];
    NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
    self.teacherNameLabel.text = name;
    self.classNameLabel.text = [currentUser.currentClass getName];
    [self configureProgressBars];

    NSArray *buttons = @[self.classesButton, self.attendanceButton];
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

- (void)viewDidLayoutSubviews{
    if (IS_IPAD_PRO) {
        NSArray *menuButtons = @[self.homeButton, self.jarButton, self.marketButton, self.awardButton];
        
        [Utilities setFontSizeWithbuttons:menuButtons font:@"GillSans-Bold" size:menuItemFontSize];
        
        NSArray *statsLabels = @[self.classTotalStampsLabel, self.classAvgLevelLabel, self.classAvgPointsLabel, self.classTotalAwardsTitleLabel, self.studentAvgLevelTitleLabel, self.studentAvgPointsTitleLabel];
        for (UILabel *label in statsLabels){
            label.font = [UIFont fontWithName:@"GillSans-Bold" size:23.0];
        }
        
        self.classLevelLabel.frame = CGRectMake(13, 387, 233, 54);
        self.classLevelLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:28.0];
        self.jarProgressLabel.frame = CGRectMake(573, 387, 209, 54);
        self.jarProgressLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:28.0];
        
        self.classNameLabel.frame = CGRectMake(4.5, 40, 803, 115);
        self.classNameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:54];
        
        self.separatorView.frame = CGRectMake(0, 190, 812, 5.5);
        
        self.teacherNameLabel.frame = CGRectMake(4, 250, 801, 80);
        self.teacherNameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:44];
        
        self.attendanceButton.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:32.0];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    currentUser = [user getInstance];
    NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
    self.teacherNameLabel.text = name;
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

    NSMutableDictionary *classStats = [[DatabaseHandler getSharedInstance]getClassStats:[currentUser.currentClass getId]];
    NSInteger totalStamps = 0;
    NSInteger partialProgress = 0;
    NSInteger n = [currentUser.currentClass getLevel];
    if (n > 1){
        for (int i = 1; i < n; i++){
            partialProgress += (30 + (5 * (n-2)));
        }
    }

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
    [self.classProgressBar setProgressBarTrackColor:[UIColor blackColor]];
    [self.classProgressBar setStartAngle:-90.0];

    [self.classProgressBar setProgressBarWidth:(5.0f)];
    [self.classProgressBar  setProgressBarProgressColor:[Utilities CHGoldColor]];
    [self.classProgressBar setBackgroundColor:[UIColor clearColor]];

    [self.classProgressBar  setHintViewSpacing:(customized ? 10.0f : 0)];
    [self.classProgressBar  setHintViewBackgroundColor:[UIColor clearColor]];
    [self.classProgressBar  setHintTextFont:[UIFont fontWithName:@"GillSans-Bold" size:25.0f]];
    [self.classProgressBar  setHintTextColor:[UIColor blackColor]];
    [self.classProgressBar  setHintTextGenerationBlock:(customized ? ^NSString *(CGFloat progress) {
        return [NSString stringWithFormat:@"%.0f / 255", progress * 255];
    } : nil)];

    [self.jarProgressBar setProgressBarTrackColor:[UIColor blackColor]];
    [self.jarProgressBar setStartAngle:-90.0];

    [self.jarProgressBar setProgressBarWidth:(5.0f)];
    [self.jarProgressBar  setProgressBarProgressColor:[Utilities CHGoldColor]];
    [self.jarProgressBar setBackgroundColor:[UIColor clearColor]];

    [self.jarProgressBar  setHintViewSpacing:(customized ? 10.0f : 0)];
    [self.jarProgressBar  setHintViewBackgroundColor:[UIColor clearColor]];
    [self.jarProgressBar  setHintTextFont:[UIFont fontWithName:@"GillSans-Bold" size:25.0f]];

    [self.jarProgressBar  setHintTextColor:[UIColor blackColor]];
    [self.jarProgressBar  setHintTextGenerationBlock:(customized ? ^NSString *(CGFloat progress) {
        return [NSString stringWithFormat:@"%.0f / 255", progress * 255];
    } : nil)];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"home_to_tutorial"]){
        TutorialViewController *vc = [segue destinationViewController];
        [vc setFlag:2];
    }

}


- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue {

}



@end
