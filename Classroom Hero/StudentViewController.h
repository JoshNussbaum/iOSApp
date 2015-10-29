//
//  StudentViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/23/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHandler.h"
#import "ConnectionHandler.h"
#import "SnowShoeViewController.h"

@interface StudentViewController : SnowShoeViewController <ConnectionHandlerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *levelBar;
@property (strong, nonatomic) IBOutlet UIButton *studentButton;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet UILabel *stampToRegisterLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stampImage;

- (IBAction)backClicked:(id)sender;

- (void)setStudent:(student *)currentStudent_;

- (IBAction)editStudentClicked:(id)sender;

- (IBAction)studentButtonClicked:(id)sender;

@end