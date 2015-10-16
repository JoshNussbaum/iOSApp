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
NSInteger REGISTER_STAMP = 19;
NSInteger REWARD_STUDENT = 20;
NSInteger REWARD_ALL_STUDENTS = 21;
NSInteger ADD_TO_JAR = 22;
NSInteger STUDENT_TRANSACTION = 23;
NSInteger ORDER_RECRUIT = 24;
NSInteger ORDER_EPIC = 25;
NSInteger ORDER_LEGENDARY = 26;
NSInteger ORDER_HERO = 27;
NSInteger UNREGISTER_STAMP = 28;
NSInteger EDIT_TEACHER_NAME = 29;
NSInteger EDIT_TEACHER_PASSWORD = 29;
NSInteger STAMP_TO_LOGIN = 30;
NSInteger GET_CLASS_STATS = 31;



+ (UIColor *)CHBlueColor{
    UIColor *CHBlueColor = [UIColor colorWithRed:116.0/255.0 green:209.0/255.0 blue:246.0/255.0 alpha:1.0] ;

    return CHBlueColor;
}


+ (UIColor *) CHGreenColor{
    UIColor *CHGreenColor = [UIColor colorWithRed:96.0/255.0 green:166.0/255.0 blue:84.0/255.0 alpha:1.0] ;
    
    return CHGreenColor;
}


+ (UIColor *) CHRedColor{
    UIColor *CHRedColor = [UIColor colorWithRed:243.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:0.75];
    
    return CHRedColor;
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
        else return nil;
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
    return nil;
}


+ (bool)isValidClassroomHeroStamp:(NSString *)serial{
    if([serial hasPrefix:@"ClassroomHero"]){
        return YES;
    }
    else {
        return NO;
    }
}


+ (void) editAlertTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete input:(NSString *)input tag:(NSInteger)tag view:(UIViewController *)view{
    if (!cancel) cancel = @"Close";
    if (!done) done = @"Done";
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:view
                                             cancelButtonTitle:cancel
                                             otherButtonTitles:done, delete ? @"Delete" : nil, nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [[alertView textFieldAtIndex:0] setDelegate:(id)view];
    [[alertView textFieldAtIndex:0]setPlaceholder:input];
    [[alertView textFieldAtIndex:0]setReturnKeyType:UIReturnKeyDone];

    alertView.tag = tag;
    [alertView show];
}


+ (void) editAlertTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view{
    if (!cancel) cancel = @"Close";
    if (!done) done = @"Done";
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:view
                                             cancelButtonTitle:cancel
                                             otherButtonTitles:done, delete ? @"Delete" : nil, nil];
    
    [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[alertView textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeNumberPad];
    [[alertView textFieldAtIndex:1] setSecureTextEntry:NO];
    [[alertView textFieldAtIndex:1]setReturnKeyType:UIReturnKeyDone];
    [[alertView textFieldAtIndex:0]setReturnKeyType:UIReturnKeyNext];
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [[alertView textFieldAtIndex:0] setDelegate:(id)view];
    [[alertView textFieldAtIndex:1] setDelegate:(id)view];

    for (NSInteger i = 0; i < textfields.count; i++){
        NSString *placeholder = [textfields objectAtIndex:i];
        [[alertView textFieldAtIndex:i] setPlaceholder:placeholder];
        
    }
    alertView.tag = tag;
    [alertView show];
}


+ (void) editAlertAddStudentWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view{
    if (!cancel) cancel = @"Close";
    if (!done) done = @"Done";
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:view
                                             cancelButtonTitle:cancel
                                             otherButtonTitles:done, delete ? @"Delete" : nil, nil];
    
    [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[alertView textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeDefault];
    [[alertView textFieldAtIndex:1] setSecureTextEntry:NO];
    [[alertView textFieldAtIndex:1]setReturnKeyType:UIReturnKeyDone];
    [[alertView textFieldAtIndex:0]setReturnKeyType:UIReturnKeyNext];
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [[alertView textFieldAtIndex:0] setDelegate:(id)view];
    [[alertView textFieldAtIndex:1] setDelegate:(id)view];
    
    for (NSInteger i = 0; i < textfields.count; i++){
        NSString *placeholder = [textfields objectAtIndex:i];
        [[alertView textFieldAtIndex:i] setPlaceholder:placeholder];
        
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
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = .8;
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
        cancel = @"Close";
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


+ (NSString *) getRandomCompliment{
    NSArray *compliments = @[@"Outstanding!",@"Splendid!",@"Marvelous!",@"Amazing!",@"Impressive!",@"Great!",@"Good   work!",@"Fine   job!",@"Magnificent!",@"Brilliant!",@"Exquisite!",@"Beautiful!",@"Incredible!",@"Wonderful!",@"Awesome!",@"Fantastic!",@"Tremendous!",@"Excellent!",@"Remarkable!",@"Astonishing!",@"Phenomenal!",@"Terrific!",@"Stupendous!",@"Peachy!",];
    
    NSInteger randomInteger = arc4random() % (compliments.count-1);
    
    return compliments[randomInteger];
}


+ (NSString *) getRandomLoadingMessage{
    return @"poop";
}


+ (void) wiggleImage:(UIImageView *)image sound:(bool)sound{
    if (sound){
        AudioServicesPlaySystemSound([self getTheSoundOfSuccess]);
    }
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([image center].x , [image center].y - 3)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([image center].x , [image center].y + 3)]];
    [[image layer] addAnimation:animation forKey:@"position"];
}



+ (void) sackWiggle:(UIImageView *)sack{
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.07];
    [animation setBeginTime:CACurrentMediaTime()];
    [animation setRepeatCount:2];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([sack center].x, [sack center].y+5)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([sack center].x, [sack center].y-5)]];
    [[sack layer] addAnimation:animation forKey:@"position"];
}


+ (void) failAnimation:(UIImageView *)image{
    AudioServicesPlaySystemSound([self getFailSound]);

    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:8];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([image center].x - 15, [image center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([image center].x + 15, [image center].y)]];
    [[image layer] addAnimation:animation forKey:@"position"];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });
}


+ (SystemSoundID) getFailSound{
    SystemSoundID failSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"register_fail" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &failSound);
    return failSound;
}


+ (SystemSoundID) getTheSoundOfSuccess{
    SystemSoundID soundOfSuccess;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"correct" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &soundOfSuccess);
    return soundOfSuccess;
}


+ (SystemSoundID) getAwardSound{
    SystemSoundID awardSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"award" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &awardSound);
    return awardSound;
}


+ (SystemSoundID) getTeacherStampSound{
    SystemSoundID teacherStampSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"teacherstamp" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &teacherStampSound);
    return teacherStampSound;
}


+ (SystemSoundID) getLevelUpSound{
    SystemSoundID levelUpSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"achievement" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &levelUpSound);
    return levelUpSound;
}


+ (SystemSoundID) getCoinShakeSound{
    SystemSoundID coinShakeSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"coin_shake" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &coinShakeSound);
    return coinShakeSound;
}


+ (SystemSoundID) getAwardAllSound {
    SystemSoundID awardAllSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"sale" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &awardAllSound);
    return awardAllSound;
}


+ (SystemSoundID) getJarSuccessSound{
    SystemSoundID jarSuccessSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"jarsuccess" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &jarSuccessSound);
    return jarSuccessSound;
}


+ (SystemSoundID) getCorkSound{
    SystemSoundID corkSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"bloop" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &corkSound);
    return corkSound;
}


+ (SystemSoundID) getAchievementSound{
    SystemSoundID achievementSound;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"achievement" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &achievementSound);
    return achievementSound;

}


+ (NSInteger) getRewardNumber{
    NSInteger random = arc4random() % 100;
    
    if (random >= 95){
        return 3;
    }
    else if (random > 70){
        return 2;
    }
    else {
        return 1;
    }
    
}




@end
