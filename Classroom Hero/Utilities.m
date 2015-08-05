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

+(NSString *) getDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateAsString = [formatter stringFromDate:[NSDate date]];
    return dateAsString;
}

+(NSString *) isNumeric:(NSString *)input;
{
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

+(NSString *)isInputValid:(NSString *)input{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&'*+-/=?^_`{|}~] "];
    for (NSUInteger i = 0; i < [input length]; ++i) {
        unichar uchar = [input characterAtIndex:i] ;
        if (![characterSet characterIsMember:uchar]) {
            return [NSString stringWithFormat:@"\"%c\" is an invalid character", uchar];
        }
    }
    if (input.length < 1){
        return [NSString stringWithFormat:@"\"%@\" is invalid input - must contain at least 1 character", input];
    }
    return @"";
}

+(bool)isValidClassroomHeroStamp:(NSString *)serial{
    if([serial hasPrefix:@"ClassroomHero"]){
        return YES;
    }
    else {
        return NO;
    }
}

// Make other button titles an array
- (UIAlertView *) constructAlertView:(NSString *)title :(NSString *)message :(NSString *)cancel :(NSMutableArray *)otherTitles :(NSInteger)tag ;
{
    NSString *otherTitle1 = nil;
    NSString *otherTitle2 = nil;

    if ([otherTitles count] > 0){
        otherTitle1 = [otherTitles objectAtIndex:0];
        if ([otherTitles count] > 1){
            otherTitle2 = [otherTitles objectAtIndex:1];
        }
    }
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:cancel
                                             otherButtonTitles:otherTitle1 ,otherTitle2];
    alertView.tag = tag;
    return alertView;
}

@end
