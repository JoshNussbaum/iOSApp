//
//  CreditCardTableViewCell.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 12/12/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import "CreditCardTableViewCell.h"

@implementation CreditCardTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeCellWithname:(NSString*)name placeholder:(NSString *)placeHolder protected:(BOOL)protected{
    self.nameLabel.text = name;
    self.inputTextField.placeholder = placeHolder;
    if (protected){
        self.inputTextField.secureTextEntry = YES;
    } else self.inputTextField.secureTextEntry = NO;
    self.inputTextField.tintColor = [UIColor lightGrayColor];
}

@end
