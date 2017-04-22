//
//  StudentAttendanceTableViewCell.h
//  Classroom Hero
//
//  Created by Josh on 10/27/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "student.h"

@interface StudentAttendanceTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

- (void)initializeWithStudent:(student *)student;

@end
