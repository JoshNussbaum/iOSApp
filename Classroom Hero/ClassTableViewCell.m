//
//  ClassTableViewCell.m
//  Classroom Hero
//
//  Created by Josh on 8/19/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "ClassTableViewCell.h"

@implementation ClassTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)initializeCellWithClass:(class*)class_ :(NSInteger)classCount :(NSString *)schoolName{
    self.nameLabel.text = [class_ getName];
    self.schoolName.text = schoolName;
    self.totalPointsLabel.text = [NSString stringWithFormat:@"%ld  Points", (long)[class_ getProgress]];
    float barProgress = (float)[class_ getProgress] / (float)[class_ getNextLevel];
    if ([class_ getProgress] == 0) {
        barProgress = 0.0;
    }
    self.gradeLabel.text = [NSString stringWithFormat:@"%ld", (long)[class_ getGradeNumber]];
    //self.progressBar.progress = barProgress;
    self.levelLabel.text = [NSString stringWithFormat:@"%ld", (long)[class_ getLevel]];
    self.numberOfStudentsLabel.text = [NSString stringWithFormat:@"%ld  Students", (long)classCount];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
