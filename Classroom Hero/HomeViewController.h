//
//  HomeViewController.h
//  Classroom Hero
//
//  Created by Josh on 8/22/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"


@interface HomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalClassPointsLabel;
@property (strong, nonatomic) IBOutlet UIView *registerStudentsView;
@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *registerStudentsButton;
@property (strong, nonatomic) IBOutlet UIButton *createClassButton;
@property (strong, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *classesButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIProgressView *classLevelProgressBar;
@property (strong, nonatomic) IBOutlet UIProgressView *jarProgressBar;


// Class Stats
@property (strong, nonatomic) IBOutlet UILabel *classTotalStampsLabel;
@property (strong, nonatomic) IBOutlet UILabel *classAvgLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *classAvgPointsLabel;

@property (strong, nonatomic) IBOutlet UILabel *schoolTotalStampsLabel;
@property (strong, nonatomic) IBOutlet UILabel *schoolAvgLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *schoolAvgPointsLabel;


@property (strong, nonatomic) IBOutlet UIView *classTotalStampsView;
@property (strong, nonatomic) IBOutlet UIView *classAvgLevelView;
@property (strong, nonatomic) IBOutlet UIView *classAvgPointsView;

@property (strong, nonatomic) IBOutlet UIView *schoolTotalStampsView;
@property (strong, nonatomic) IBOutlet UIView *schoolAvgLevelView;
@property (strong, nonatomic) IBOutlet UIView *schoolAvgPointsView;



- (void)setFlag:(NSInteger)flag_;
- (IBAction)swipeDown:(id)sender;
- (IBAction)tutorialClicked:(id)sender;
- (IBAction)registerStudentsClicked:(id)sender;
- (IBAction)classesClicked:(id)sender;
- (IBAction)awardClicked:(id)sender;
- (IBAction)classJarClicked:(id)sender;
- (IBAction)marketClicked:(id)sender;
- (IBAction)settingsClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *testbutton;

@end
