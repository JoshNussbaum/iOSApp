//
//  CheckoutInputTableViewCell.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 12/12/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import "CheckoutInputTableViewCell.h"

@implementation CheckoutInputTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeCellWithname:(NSString*)name placeholder:(NSString *)placeHolder protected:(BOOL)protected inputType:(NSString *)inputType;{
    self.nameLabel.text = name;
    self.inputTextField.placeholder = placeHolder;
    if (protected){
        self.inputTextField.secureTextEntry = YES;
    } else self.inputTextField.secureTextEntry = NO;
    if ([inputType isEqualToString:@"Text"]){
        self.inputTextField.keyboardType = UIKeyboardTypeAlphabet;
    }
    else if ([inputType isEqualToString:@"Number"]){
        self.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    self.inputTextField.tintColor = [UIColor lightGrayColor];
}

@end
