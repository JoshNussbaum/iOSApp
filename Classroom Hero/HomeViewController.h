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

@property (strong, nonatomic) IBOutlet UILabel *schoolNameLabel;

@property (strong, nonatomic) IBOutlet UIButton *classesButton;

@property (strong, nonatomic) IBOutlet UIButton *attendanceButton;

@property (weak, nonatomic) IBOutlet CircleProgressBar *classProgressBar;

@property (weak, nonatomic) IBOutlet CircleProgressBar *jarProgressBar;

@property (strong, nonatomic) IBOutlet UIImageView *classLevelIcon;

// Menu
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *awardButton;
@property (strong, nonatomic) IBOutlet UIButton *jarButton;
@property (strong, nonatomic) IBOutlet UIButton *marketButton;


// Class Stats
@property (strong, nonatomic) IBOutlet UILabel *classTotalStampsLabel;
@property (strong, nonatomic) IBOutlet UILabel *classAvgLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *classAvgPointsLabel;

@property (strong, nonatomic) IBOutlet UIView *classTotalStampsView;
@property (strong, nonatomic) IBOutlet UIView *classAvgLevelView;
@property (strong, nonatomic) IBOutlet UIView *classAvgPointsView;



- (void)setFlag:(NSInteger)flag_;

- (IBAction)classesClicked:(id)sender;

- (IBAction)awardClicked:(id)sender;

- (IBAction)classJarClicked:(id)sender;

- (IBAction)marketClicked:(id)sender;

- (IBAction)settingsClicked:(id)sender;

- (IBAction)studentListClicked:(id)sender;

- (IBAction)attendanceClicked:(id)sender;

@end
