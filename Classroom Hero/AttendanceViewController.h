//
//  AttendanceViewController.h
//  Classroom Hero
//
//  Created by Josh on 10/11/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@interface AttendanceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIImageView *stampImage;

@property (strong, nonatomic) IBOutlet UIButton *studentsButton;

@property (strong, nonatomic) IBOutlet UITableView *studentsTableView;

@property (weak, nonatomic) IBOutlet UILabel *studentNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *studentPointsLabel;

@property (strong, nonatomic) IBOutlet UIImageView *coinImage;

@property (strong, nonatomic) IBOutlet UIImageView *sackImage;

@property (strong, nonatomic) IBOutlet UIPickerView *studentsPicker;

@property (strong, nonatomic) IBOutlet UILabel *studentNamePreStampLabel;


- (IBAction)attendanceClicked:(id)sender;

- (IBAction)studentsClicked:(id)sender;

- (IBAction)backClicked:(id)sender;

- (IBAction)resetClicked:(id)sender;

- (IBAction)checkInAllClicked:(id)sender;

@end
