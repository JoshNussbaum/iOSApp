//
//  SettingsViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/27/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@interface SettingsViewController : UIViewController <ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *orderStampsButton;

@property (strong, nonatomic) IBOutlet UIButton *classTutorialButton;

@property (strong, nonatomic) IBOutlet UIView *registerStudentsView;

@property (strong, nonatomic) IBOutlet UIButton *registerStudentsButton;

@property (strong, nonatomic) IBOutlet UIButton *registerTeacherStamp;

@property (strong, nonatomic) IBOutlet UIButton *studentListButton;

@property (strong, nonatomic) IBOutlet UIView *registerTeacherStampView;

@property (strong, nonatomic) IBOutlet UIView *orderStampsView;

@property (strong, nonatomic) IBOutlet UIButton *stampIdentifierButton;

@property (strong, nonatomic) IBOutlet UIButton *unregisterAllStampsButton;


- (IBAction)orderStampsClicked:(id)sender;

- (IBAction)classTutorialClicked:(id)sender;

- (IBAction)registerStudentsClicked:(id)sender;

- (IBAction)registerTeacherStampClicked:(id)sender;

- (IBAction)editTeacherClicked:(id)sender;

- (IBAction)backClicked:(id)sender;

- (IBAction)studentListClicked:(id)sender;

- (IBAction)stampIdentifierClicked:(id)sender;

- (IBAction)unregisterAllStampsClicked:(id)sender;

- (void)setFlag:(NSInteger)flag_;
@end
