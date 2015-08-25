//
//  numberTextField.m
//  Classroom Hero
//
//  Created by Josh on 8/22/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "numberTextField.h"
#import "Utilities.h"

@implementation numberTextField


- (NSString *)validate{
    // check if name has anything but letters
    if (self.text.length >= 1){
        NSString *classErrorMessage = [Utilities isNumeric:self.text];
        if ([classErrorMessage isEqualToString:@""]){
            return @"";
        }
        else {
            return classErrorMessage;
        }
    }
    else {
        return @"All fields are required";
    }
}

@end
