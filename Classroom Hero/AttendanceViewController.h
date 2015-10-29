//
//  AttendanceViewController.h
//  Classroom Hero
//
//  Created by Josh on 10/11/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendanceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UIImageView *stampImage;
@property (strong, nonatomic) IBOutlet UIButton *studentsButton;

@property (strong, nonatomic) IBOutlet UITableView *studentsTableView;


- (IBAction)studentsClicked:(id)sender;
- (IBAction)backClicked:(id)sender;

@end
