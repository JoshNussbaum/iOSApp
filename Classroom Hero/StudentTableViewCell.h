//
//  StudentTableViewCell.h
//  Classroom Hero
//
//  Created by Josh on 9/23/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "student.h"

@interface StudentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *levelLabel;

@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;


- (void)initializeWithStudent:(student *)currentStudent;


@end
