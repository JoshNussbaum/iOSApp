//
//  HomeViewController.h
//  Classroom Hero
//
//  Created by Josh on 8/22/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"
#import "CircleProgressBar.h"


@interface HomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *teacherNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *classLevelLabel;

@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;

@property (strong, nonatomic) IBOutlet UIView *settingsView;

@property (strong, nonatomic) IBOutlet UIButton *settingsButton;

@property (strong, nonatomic) IBOutlet UILabel *schoolNameLabel;

@property (strong, nonatomic) IBOutlet UIButton *classesButton;

@property (strong, nonatomic) IBOutlet UIButton *attendanceButton;

@property (weak, nonatomic) IBOutlet CircleProgressBar *classProgressBar;

@property (weak, nonatomic) IBOutlet CircleProgressBar *jarProgressBar;


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

- (IBAction)classesClicked:(id)sender;

- (IBAction)awardClicked:(id)sender;

- (IBAction)classJarClicked:(id)sender;

- (IBAction)marketClicked:(id)sender;

- (IBAction)settingsClicked:(id)sender;

- (IBAction)studentListClicked:(id)sender;

- (IBAction)attendanceClicked:(id)sender;

@end
