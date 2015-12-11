//
//  StudentTableViewCell.m
//  Classroom Hero
//
//  Created by Josh on 9/23/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "StudentTableViewCell.h"
#import "Utilities.h"

@implementation StudentTableViewCell



- (void)initializeWithStudent:(student *)currentStudent{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
    if ([[currentStudent getSerial] isEqualToString:@""]){
        self.backgroundColor = [Utilities CHRedColor];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
