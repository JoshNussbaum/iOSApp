//
//  MarketViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/3/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@interface MarketViewController : UIViewController <ConnectionHandlerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *itemNameLabel;

@property (strong, nonatomic) IBOutlet UIButton *editItemButton;

@property (strong, nonatomic) IBOutlet UIImageView *stampImage;

@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@property (strong, nonatomic) IBOutlet UILabel *studentPointsLabel;

@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel;

@property (strong, nonatomic) IBOutlet UIButton *purchaseButton;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sackImage;

// Menu
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *awardButton;
@property (strong, nonatomic) IBOutlet UIButton *jarButton;
@property (strong, nonatomic) IBOutlet UIButton *marketButton;

@property (strong, nonatomic) IBOutlet UIButton *classJarIconButton;
@property (strong, nonatomic) IBOutlet UIButton *awardIconButton;
@property (strong, nonatomic) IBOutlet UIButton *homeIconButton;

@property (strong, nonatomic) IBOutlet UITableView *studentsTableView;

@property (strong, nonatomic) IBOutlet UIView *divider1;
@property (strong, nonatomic) IBOutlet UIView *divider2;

- (IBAction)homeClicked:(id)sender;

- (IBAction)awardClicked:(id)sender;

- (IBAction)classJarClicked:(id)sender;

- (IBAction)editItemClicked:(id)sender;

- (IBAction)studentListClicked:(id)sender;

- (IBAction)purchaseClicked:(id)sender;

@end
