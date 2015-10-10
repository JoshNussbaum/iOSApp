//
//  MarketViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/3/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"
#import "SnowShoeViewController.h"

@interface MarketViewController : SnowShoeViewController <ConnectionHandlerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *itemNameLabel;

@property (strong, nonatomic) IBOutlet UIImageView *stampImage;


- (IBAction)homeClicked:(id)sender;
- (IBAction)awardClicked:(id)sender;
- (IBAction)classJarClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIImageView *sackImage;
@property (strong, nonatomic) IBOutlet UILabel *studentPointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
- (IBAction)addItemClicked:(id)sender;
- (IBAction)editItemClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *editItemButton;
- (IBAction)studentListClicked:(id)sender;

@end
