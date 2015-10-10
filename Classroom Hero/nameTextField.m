//
//  nameTextField.m
//  Classroom Hero
//
//  Created by Josh on 7/25/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "nameTextField.h"
#import "Utilities.h"

@implementation nameTextField

- (NSString *)validate{
    // check if name has anything but letters
    if (self.text.length >= 1){
        NSString *classErrorMessage = [Utilities isInputValid:self.text :@"Name"];
        if (!classErrorMessage){
            return @"";
        }
        else {
            return classErrorMessage;
        }
    }
    else {
        return @"All fields are required";
    }
    return @"";
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
