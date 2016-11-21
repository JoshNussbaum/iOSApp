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
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.contentView layoutSubviews];
    if (IS_IPAD_PRO) {
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.pointsLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.levelLabel.frame = CGRectMake(700, 8, 105, 33);
        self.nameLabel.frame = CGRectMake(5, 8, 650, 33);

    }
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [super layoutSubviews];
    [self.contentView layoutSubviews]; if (IS_IPAD_PRO) {
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.pointsLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.levelLabel.frame = CGRectMake(700, 8, 105, 33);
        self.nameLabel.frame = CGRectMake(5, 8, 650, 33);
    }
}

@end
