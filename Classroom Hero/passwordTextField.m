//
//  passwordTextField.m
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "passwordTextField.h"

@implementation passwordTextField

- (NSString *)validate{
    if (self.text.length >= 3){
        NSString *errorMessage = [self isPasswordValid:self.text];
        if (!errorMessage){
            return @"";
        }
        else return errorMessage;
    }
    else {
        return @"Password length must be at least three characters long";
    }
}

- (NSString *)isPasswordValid:(NSString *)password
{
    NSCharacterSet * characterSet = [NSCharacterSet uppercaseLetterCharacterSet] ;
    
    characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&'*+-/=?^_`{|}~]"];
    for (NSUInteger i = 0; i < [password length]; ++i) {
        unichar uchar = [password characterAtIndex:i] ;
        if (![characterSet characterIsMember:uchar]) {
            return [NSString stringWithFormat:@"Password may not contain the character \"%c\"", uchar] ;
        }
    }
    return nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
