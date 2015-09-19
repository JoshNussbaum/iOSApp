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

- (IBAction)tutorialClicked:(id)sender;

- (IBAction)registerStudentsClicked:(id)sender;
- (IBAction)classesClicked:(id)sender;
- (IBAction)orderStampsClicked:(id)sender;

- (void)setFlag:(NSInteger)flag_;


- (IBAction)awardClicked:(id)sender;
- (IBAction)classJarClicked:(id)sender;
- (IBAction)marketClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *avgPointsView;
@property (strong, nonatomic) IBOutlet UIView *highestLvlView;
@property (strong, nonatomic) IBOutlet UIView *mostUsedCategoryView;
@property (strong, nonatomic) IBOutlet UIView *loewstLevelView;
@property (strong, nonatomic) IBOutlet UIView *mostSoldItemView;
@property (strong, nonatomic) IBOutlet UIView *biggestSpenderView;
@property (strong, nonatomic) IBOutlet UIButton *orderStampsButton;
@property (strong, nonatomic) IBOutlet UILabel *classStatsLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *classLevelProgressBar;
@property (strong, nonatomic) IBOutlet UIProgressView *jarProgressBar;

@end
