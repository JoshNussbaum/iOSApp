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

@property (strong, nonatomic) IBOutlet UIButton *classesButton;

@property (strong, nonatomic) IBOutlet UIButton *attendanceButton;


@property (strong, nonatomic) IBOutlet UIButton *classHashButton;

@property (weak, nonatomic) IBOutlet CircleProgressBar *classProgressBar;

@property (strong, nonatomic) IBOutlet UILabel *jarProgressLabel;

@property (weak, nonatomic) IBOutlet CircleProgressBar *jarProgressBar;

@property (strong, nonatomic) IBOutlet UIImageView *classLevelIcon;
@property (strong, nonatomic) IBOutlet UIView *separatorView;

// Menu
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *awardButton;
@property (strong, nonatomic) IBOutlet UIButton *jarButton;
@property (strong, nonatomic) IBOutlet UIButton *marketButton;


// Class Stats
@property (strong, nonatomic) IBOutlet UILabel *classTotalAwardsTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *studentAvgLevelTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *studentAvgPointsTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *classTotalStampsLabel;
@property (strong, nonatomic) IBOutlet UILabel *classAvgLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *classAvgPointsLabel;

@property (strong, nonatomic) IBOutlet UIView *classTotalStampsView;
@property (strong, nonatomic) IBOutlet UIView *classAvgLevelView;
@property (strong, nonatomic) IBOutlet UIView *classAvgPointsView;



- (IBAction)classesClicked:(id)sender;

- (IBAction)awardClicked:(id)sender;

- (IBAction)classJarClicked:(id)sender;

- (IBAction)marketClicked:(id)sender;

- (IBAction)settingsClicked:(id)sender;

- (IBAction)studentListClicked:(id)sender;

- (IBAction)attendanceClicked:(id)sender;

- (IBAction)clashHashButtonClicked:(id)sender;

@end
