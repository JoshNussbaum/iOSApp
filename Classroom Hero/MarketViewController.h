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

@property (strong, nonatomic) IBOutlet UIButton *editItemButton;

@property (strong, nonatomic) IBOutlet UIImageView *stampImage;

@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@property (strong, nonatomic) IBOutlet UIImageView *sackImage;

@property (strong, nonatomic) IBOutlet UILabel *studentPointsLabel;

@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

// Menu
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *awardButton;
@property (strong, nonatomic) IBOutlet UIButton *jarButton;
@property (strong, nonatomic) IBOutlet UIButton *marketButton;

@property (strong, nonatomic) IBOutlet UIButton *classJarIconButton;
@property (strong, nonatomic) IBOutlet UIButton *awardIconButton;
@property (strong, nonatomic) IBOutlet UIButton *homeIconButton;


- (IBAction)homeClicked:(id)sender;

- (IBAction)awardClicked:(id)sender;

- (IBAction)classJarClicked:(id)sender;

- (IBAction)addItemClicked:(id)sender;

- (IBAction)editItemClicked:(id)sender;

- (IBAction)studentListClicked:(id)sender;

@end
