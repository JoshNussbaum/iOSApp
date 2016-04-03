//
//  AttendanceViewController.h
//  Classroom Hero
//
//  Created by Josh on 10/11/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnowShoeViewController.h"
#import "ConnectionHandler.h"

@interface AttendanceViewController : SnowShoeViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, ConnectionHandlerDelegate>


@property (strong, nonatomic) IBOutlet UIImageView *stampImage;

@property (strong, nonatomic) IBOutlet UIButton *studentsButton;

@property (strong, nonatomic) IBOutlet UITableView *studentsTableView;

@property (weak, nonatomic) IBOutlet UILabel *studentNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *studentPointsLabel;

@property (strong, nonatomic) IBOutlet UIImageView *coinImage;

@property (strong, nonatomic) IBOutlet UIImageView *sackImage;


- (IBAction)studentsClicked:(id)sender;

- (IBAction)backClicked:(id)sender;

- (IBAction)resetClicked:(id)sender;

- (IBAction)checkInAllClicked:(id)sender;

@end
