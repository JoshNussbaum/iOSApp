//
//  StudentAttendanceTableViewCell.m
//  Classroom Hero
//
//  Created by Josh on 10/27/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import "StudentAttendanceTableViewCell.h"
#import "Utilities.h"

@implementation StudentAttendanceTableViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)initializeWithStudent:(student *)student{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [student getFirstName], [student getLastName]];
    if ([student getCheckedIn]){
        self.backgroundColor = [Utilities CHBlueColor];
    }else self.backgroundColor = [Utilities CHRedColor];
}

@end
