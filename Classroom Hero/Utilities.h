//
//  Utilities.h
//  Classroom Hero
//
//  Created by Josh on 8/4/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


static NSString * const snowshoe_app_key = @"d12276c2fac976865fdc";
static NSString * const snowshoe_app_secret = @"bf700a42149799b02641b2c2d93dbd3c4f995db8";



@interface Utilities : NSObject


extern NSInteger LOGIN;
extern NSInteger CREATE_ACCOUNT;
extern NSInteger ADD_CLASS;
extern NSInteger EDIT_CLASS;
extern NSInteger DELETE_CLASS;
extern NSInteger ADD_STUDENT;
extern NSInteger EDIT_STUDENT;
extern NSInteger DELETE_STUDENT;
extern NSInteger ADD_REINFORCER;
extern NSInteger EDIT_REINFORCER;
extern NSInteger DELETE_REINFORCER;
extern NSInteger ADD_ITEM;
extern NSInteger EDIT_ITEM;
extern NSInteger DELETE_ITEM;
extern NSInteger ADD_JAR;
extern NSInteger EDIT_JAR;
extern NSInteger DELETE_JAR;
extern NSInteger GET_SCHOOLS;
extern NSInteger REGISTER_STAMP;

+ (UIColor *) CHBlueColor;


+ (UIColor *) CHGreenColor;


+ (NSString *) getDate;


+ (NSString *) isNumeric:(NSString *)input;


+ (NSString *)isInputValid:(NSString *)input :(NSString *)inputName;


+ (bool)isValidClassroomHeroStamp:(NSString *)serial;


+ (void) editAlertText:(NSString *)title :(NSString *)message :(NSString *)cancel :(NSString *)done :(NSString *)input :
(NSInteger)tag;


+ (void) editAlertTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) setTextFieldPlaceholder:(UITextField *)textField :(NSString *)placeholder :(UIColor *)color;


+ (void) makeRoundedButton:(UIButton *)button :(UIColor *)color;

+ (void) alertStatusWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel otherTitles:(NSArray *)otherTitles tag:(NSInteger)tag view:(UIViewController *)view;

+ (void) alertStatusNoConnection;

+ (NSString *) getRandomCompliment;

+ (void) wiggleImage:(UIImageView *)image;

+ (void) failAnimation:(UIImageView *)image;

+ (SystemSoundID) getFailSound;

+ (SystemSoundID) getTheSoundOfSuccess;

+ (SystemSoundID) getAwardSound;




@end
