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

- (IBAction)tutorialClicked:(id)sender;

- (IBAction)registerStudentsClicked:(id)sender;
- (IBAction)classesClicked:(id)sender;

- (void)setFlag:(NSInteger)flag_;


@end
