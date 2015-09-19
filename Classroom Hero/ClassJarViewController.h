//
//  ClassJarViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"
#import "SnowShoeViewController.h"

@interface ClassJarViewController : SnowShoeViewController <ConnectionHandlerDelegate>

- (IBAction)homeClicked:(id)sender;
- (IBAction)awardClicked:(id)sender;
- (IBAction)marketClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *classJarName;
@property (strong, nonatomic) IBOutlet UIImageView *jarImage;
@property (strong, nonatomic) IBOutlet UIImageView *corkImage;
@property (strong, nonatomic) IBOutlet UIImageView *lidImage;
@property (strong, nonatomic) IBOutlet UIImageView *coinImage;
@property (strong, nonatomic) IBOutlet UIStepper *stepper;
- (IBAction)valueChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
- (IBAction)editJarClicked:(id)sender;
- (IBAction)addJarClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *addJarButton;

@end
