//
//  AwardViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnowShoeViewController.h"
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "ConnectionHandler.h"


@interface AwardViewController : SnowShoeViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ConnectionHandlerDelegate>


- (IBAction)homeClicked:(id)sender;
- (IBAction)classJarClicked:(id)sender;
- (IBAction)marketClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *reinforcerLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *levelView;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *levelBar;
@property (strong, nonatomic) IBOutlet UILabel *levelUpLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sackImage;
@property (strong, nonatomic) IBOutlet UIImageView *stampImage;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *categoryPicker;

@property (strong, nonatomic) IBOutlet UIImageView *aOne;
@property (strong, nonatomic) IBOutlet UIImageView *aTwo;
@property (strong, nonatomic) IBOutlet UIImageView *aThree;
@property (strong, nonatomic) IBOutlet UIImageView *bOne;
@property (strong, nonatomic) IBOutlet UIImageView *bTwo;
@property (strong, nonatomic) IBOutlet UIImageView *cOne;

- (IBAction)addReinforcerClicked:(id)sender;
- (IBAction)editReinforcerClicked:(id)sender;


@end
