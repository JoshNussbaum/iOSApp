//
//  TutorialViewController.h
//  Classroom Hero
//
//  Created by Josh on 7/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "user.h"
#import "TutorialContentViewController.h"
#import "DatabaseHandler.h"


@interface TutorialViewController : UIViewController <UIPageViewControllerDataSource>

- (IBAction)startTutorial:(id)sender;

@property (strong, nonatomic) NSArray *pageTitles;

@property (strong, nonatomic) UIPageViewController *pageViewController;


- (IBAction)backClicked:(id)sender;

- (IBAction)skipClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet UIButton *startOverButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;


@end