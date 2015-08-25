//
//  Utilities.m
//  Classroom Hero
//
//  Created by Josh on 8/4/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

NSInteger LOGIN = 1;
NSInteger CREATE_ACCOUNT = 2;
NSInteger ADD_CLASS = 3;
NSInteger EDIT_CLASS = 4;
NSInteger DELETE_CLASS = 5;
NSInteger ADD_STUDENT = 6;
NSInteger EDIT_STUDENT = 7;
NSInteger DELETE_STUDENT = 8;
NSInteger ADD_REINFORCER = 9;
NSInteger EDIT_REINFORCER = 10;
NSInteger DELETE_REINFORCER = 11;
NSInteger ADD_ITEM = 12;
NSInteger EDIT_ITEM = 13;
NSInteger DELETE_ITEM = 14;
NSInteger ADD_JAR = 15;
NSInteger EDIT_JAR = 16;
NSInteger DELETE_JAR = 17;
NSInteger GET_SCHOOLS = 18;

+ (UIColor *)CHBlueColor{
    UIColor *CHBlueColor = [UIColor colorWithRed:116.0/255.0 green:209.0/255.0 blue:246.0/255.0 alpha:1.0] ;

    return CHBlueColor;
}

+ (UIColor *) CHGreenColor{
    UIColor *CHGreenColor = [UIColor colorWithRed:96.0/255.0 green:166.0/255.0 blue:84.0/255.0 alpha:1.0] ;
    
    return CHGreenColor;
}



+ (NSString *) getDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateAsString = [formatter stringFromDate:[NSDate date]];
    return dateAsString;
}


+ (NSString *) isNumeric:(NSString *)input{
    NSScanner *sc = [NSScanner scannerWithString: input];
    
    if ( [sc scanFloat:NULL] && input.integerValue >= 0)
    {
        bool numeric = [sc isAtEnd];
        if (!numeric){
            return [NSString stringWithFormat:@"\"%@\" is not a positive number", input];
        }
        else return @"";
    }
    else{
        return [NSString stringWithFormat:@"\"%@\" is not a positive number", input];
    }

}


+ (NSString *)isInputValid:(NSString *)input :(NSString *)inputName{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&'*+-/=?^_`{|}~] "];
    for (NSUInteger i = 0; i < [input length]; ++i) {
        unichar uchar = [input characterAtIndex:i] ;
        if (![characterSet characterIsMember:uchar]) {
            return [NSString stringWithFormat:@"%@ may not contain the character \"%c\"", inputName, uchar];
        }
    }
    if (input.length < 1){
        return [NSString stringWithFormat:@"%@ must contain at least 1 character", inputName];
    }
    return @"";
}


+ (bool)isValidClassroomHeroStamp:(NSString *)serial{
    if([serial hasPrefix:@"ClassroomHero"]){
        return YES;
    }
    else {
        return NO;
    }
}


+ (void) editAlertText:(NSString *)title :(NSString *)message :(NSString *)cancel :(NSString *)done :(NSString *)input :(NSInteger)tag{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:cancel
                                             otherButtonTitles:done, nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0]setText:input];
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    alertView.tag = tag;
    [alertView show];
}


+ (void) editAlertTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:view
                                             cancelButtonTitle:cancel
                                             otherButtonTitles:done, nil];
    
    [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[alertView textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeNumberPad];
    [[alertView textFieldAtIndex:1] setSecureTextEntry:NO];
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    for (NSInteger i = 0; i < textfields.count; i++){
        NSString *placeholder = [textfields objectAtIndex:i];
        [[alertView textFieldAtIndex:i] setText:placeholder];
        
    }
    alertView.tag = tag;
    [alertView show];
}

+ (void) setTextFieldPlaceholder:(UITextField *)textField :(NSString *)placeholder :(UIColor *)color{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
                                                                                                  NSForegroundColorAttributeName : color,
                                                                                                  NSFontAttributeName : [UIFont fontWithName:@"Gill Sans" size:23.0]
                                                                                                  }];
    
    textField.attributedPlaceholder = str;
}

+ (void) makeRoundedButton:(UIButton *)button :(UIColor *)color{
    button.layer.cornerRadius = 10	;
    button.layer.borderWidth = 2;
    button.clipsToBounds = YES;
    if (color != nil){
        button.layer.borderColor = color.CGColor;
    }
    else {
        button.layer.borderColor = [UIColor clearColor].CGColor;

    }
}

+ (void) alertStatusWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel otherTitles:(NSArray *)otherTitles tag:(NSInteger)tag view:(UIViewController *)view{
    if (cancel == nil){
        cancel = @"Cancel";
    }
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:view
                                             cancelButtonTitle:cancel
                                             otherButtonTitles:nil];
    for (NSString *title in otherTitles){
        [alertView addButtonWithTitle:title];
    }
    alertView.tag = tag;
    [alertView show];
}


+ (void) alertStatusNoConnection{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                       message:@"Please check your internet connection and try again"
                                                      delegate:nil
                                             cancelButtonTitle:@"Close"
                                             otherButtonTitles:nil];
    alertView.tag = 0;
    [alertView show];
}



@end
