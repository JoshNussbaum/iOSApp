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

- (void)initializeWithStudent:(student *)student;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
