//
//  SettingsViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/27/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *orderStampsButton;

@property (strong, nonatomic) IBOutlet UIButton *registerTeacherStamp;

@property (strong, nonatomic) IBOutlet UIButton *activityMonitorButton;

@property (strong, nonatomic) IBOutlet UIView *registerTeacherStampView;

@property (strong, nonatomic) IBOutlet UIView *orderStampsView;


- (IBAction)orderStampsClicked:(id)sender;

- (IBAction)registerTeacherStampClicked:(id)sender;

- (IBAction)editTeacherClicked:(id)sender;

- (IBAction)backClicked:(id)sender;


@end
