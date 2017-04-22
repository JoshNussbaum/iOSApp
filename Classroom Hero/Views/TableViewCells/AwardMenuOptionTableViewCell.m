//
//  AwardMenuOptionTableViewCell.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 11/21/16.
//  Copyright © 2016 Josh Nussbaum. All rights reserved.
//

#import "AwardMenuOptionTableViewCell.h"

@implementation AwardMenuOptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeWithTitle:(NSString *)title;
{
    self.titleLabel.text = title;
    self.backgroundColor = [UIColor clearColor];
}

@end
