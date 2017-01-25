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
#import "CircleProgressBar.h"

@interface StudentViewController : UIViewController <ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *levelLabel;

@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

@property (strong, nonatomic) IBOutlet UILabel *classHashLabel;

@property (strong, nonatomic) IBOutlet UILabel *studentHashLabel;

@property (weak, nonatomic) IBOutlet CircleProgressBar *progressView;

@property (strong, nonatomic) IBOutlet UIImageView *heroImage;

@property (strong, nonatomic) IBOutlet UIButton *addPointsButton;

@property (strong, nonatomic) IBOutlet UIButton *subtractPointsButton;

- (IBAction)addPointsClicked:(id)sender;

- (IBAction)subtractPointsClicked:(id)sender;

- (IBAction)backClicked:(id)sender;

- (IBAction)editStudentClicked:(id)sender;

- (void)setStudent:(student *)currentStudent_;


@end
