    //
//  ClassTableViewCell.m
//  Classroom Hero
//
//  Created by Josh on 8/19/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "ClassTableViewCell.h"
#import "Utilities.h"

@implementation ClassTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.contentView layoutSubviews];
    if (IS_IPAD_PRO) {
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:36];
        self.totalPointsLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:21.0];
        
        self.gradeLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:28.0];
        self.gradeLabel.frame = CGRectMake(665, 51, 80, 38);
        
        self.gradeTitleLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:26.0];
        self.gradeTitleLabel.frame = CGRectMake(657, 13, 95, 38);
        
        self.numberOfStudentsLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:27];
        self.numberOfStudentsLabel.frame = CGRectMake(721, 97, 192, 33);
        
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:28.0];
        self.levelTitleLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:26.0];
    }
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [super layoutSubviews];
    [self.contentView layoutSubviews];

    if (IS_IPAD_PRO) {
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:35];
        self.totalPointsLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:21.0];
        
        self.gradeLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:28.0];
        self.gradeLabel.frame = CGRectMake(665, 51, 80, 38);
        
        self.gradeTitleLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:26.0];
        self.gradeTitleLabel.frame = CGRectMake(657, 13, 95, 38);
        
        self.numberOfStudentsLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:27];
        self.numberOfStudentsLabel.frame = CGRectMake(721, 97, 192, 33);
        
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:28.0];
        self.levelTitleLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:26.0];
    }
}


- (void)initializeCellWithClass:(class*)class_ :(NSInteger)classCount{
    self.backgroundColor = [UIColor clearColor];
    self.nameLabel.text = [class_ getName];
    self.totalPointsLabel.text = [NSString stringWithFormat:@"%ld  Points", (long)[class_ getProgress]];
    float barProgress = (float)[class_ getProgress] / (float)[class_ getNextLevel];
    if ([class_ getProgress] == 0) {
        barProgress = 0.0;
    }
    self.gradeLabel.text = [class_ getGradeNumber];
    self.levelLabel.text = [NSString stringWithFormat:@"%ld", (long)[class_ getLevel]];
    self.numberOfStudentsLabel.text = [NSString stringWithFormat:@"%ld  Students", (long)classCount];
    
            
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}



@end
