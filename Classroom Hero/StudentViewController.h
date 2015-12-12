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
#import "CircleProgressBar.h"

@interface StudentViewController : SnowShoeViewController <ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *levelLabel;

@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

@property (strong, nonatomic) IBOutlet UIButton *studentButton;

@property (weak, nonatomic) IBOutlet CircleProgressBar *progressView;

@property (strong, nonatomic) IBOutlet UILabel *stampToRegisterLabel;

@property (strong, nonatomic) IBOutlet UIImageView *stampImage;


- (IBAction)backClicked:(id)sender;

- (IBAction)editStudentClicked:(id)sender;

- (IBAction)studentButtonClicked:(id)sender;

- (void)setStudent:(student *)currentStudent_;


@end
