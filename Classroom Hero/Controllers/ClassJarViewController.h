//
//  ClassJarViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@interface ClassJarViewController : UIViewController <ConnectionHandlerDelegate>


@property (strong, nonatomic) IBOutlet UILabel *classJarName;

@property (strong, nonatomic) IBOutlet UILabel *classJarProgressLabel;

@property (strong, nonatomic) IBOutlet UIImageView *jarImage;

@property (strong, nonatomic) IBOutlet UIImageView *backLidImage;

@property (strong, nonatomic) IBOutlet UIImageView *corkImage;

@property (strong, nonatomic) IBOutlet UIImageView *coinImage;

@property (strong, nonatomic) IBOutlet UIImageView *jarCoinsImage;

@property (strong, nonatomic) IBOutlet UIStepper *stepper;

@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

@property (strong, nonatomic) IBOutlet UIButton *addJarButton;

@property (strong, nonatomic) IBOutlet UIButton *addPointsButton;

// Menu
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *awardButton;
@property (strong, nonatomic) IBOutlet UIButton *jarButton;
@property (strong, nonatomic) IBOutlet UIButton *marketButton;

@property (strong, nonatomic) IBOutlet UIButton *homeIconButton;
@property (strong, nonatomic) IBOutlet UIButton *awardIconButton;
@property (strong, nonatomic) IBOutlet UIButton *marketIconButton;


- (IBAction)valueChanged:(id)sender;

- (IBAction)addJarClicked:(id)sender;

- (IBAction)addPointsClicked:(id)sender;

- (IBAction)homeClicked:(id)sender;

- (IBAction)awardClicked:(id)sender;

- (IBAction)marketClicked:(id)sender;

- (IBAction)studentListClicked:(id)sender;


@end
