//
//  AwardViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "ConnectionHandler.h"
#import "YLProgressBar.h"


@interface AwardViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *reinforcerLabel;
@property (strong, nonatomic) IBOutlet UILabel *reinforcerValue;
@property (strong, nonatomic) IBOutlet UIButton *editReinforcerButton;
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
@property (strong, nonatomic) IBOutlet UIImageView *coinImage;
@property (strong, nonatomic) IBOutlet UILabel *coinPointsLabel;
@property (strong, nonatomic) YLProgressBar *progressView;

// Menu
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *awardButton;
@property (strong, nonatomic) IBOutlet UIButton *jarButton;
@property (strong, nonatomic) IBOutlet UIButton *marketButton;

@property (strong, nonatomic) IBOutlet UIButton *homeIconButton;
@property (strong, nonatomic) IBOutlet UIButton *classJarIconButton;
@property (strong, nonatomic) IBOutlet UIButton *marketIconButton;

@property (weak, nonatomic) IBOutlet UITableView *studentsTableView;


@property (strong, nonatomic) IBOutlet UIButton *chestButton;
@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;
@property (strong, nonatomic) IBOutlet UIButton *openStudentTableViewButton;


- (IBAction)openStudentTableViewClicked:(id)sender;

- (IBAction)chestClicked:(id)sender;

- (IBAction)addReinforcerClicked:(id)sender;
- (IBAction)editReinforcerClicked:(id)sender;
- (IBAction)studentListClicked:(id)sender;

- (IBAction)homeClicked:(id)sender;
- (IBAction)classJarClicked:(id)sender;
- (IBAction)marketClicked:(id)sender;

@end
