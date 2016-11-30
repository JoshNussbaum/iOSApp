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
#import "student.h"

#define IS_IPAD_PRO ([[UIScreen mainScreen] bounds].size.height == 1366)
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

static NSString * const merchant_id = @"merchant.com.classroom-hero";

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
extern NSInteger REWARD_STUDENT;
extern NSInteger REWARD_STUDENT_BULK;
extern NSInteger REWARD_ALL_STUDENTS;
extern NSInteger ADD_TO_JAR;
extern NSInteger STUDENT_TRANSACTION;
extern NSInteger ORDER_RECRUIT;
extern NSInteger ORDER_EPIC;
extern NSInteger ORDER_LEGENDARY;
extern NSInteger ORDER_HERO;
extern NSInteger UNREGISTER_STAMP;
extern NSInteger EDIT_TEACHER_NAME;
extern NSInteger EDIT_TEACHER_PASSWORD;
extern NSInteger STAMP_TO_LOGIN;
extern NSInteger GET_CLASS_STATS;
extern NSInteger IDENTIFY_STAMP;
extern NSInteger UNREGISTER_ALL_STUDENTS;
extern NSInteger GET_STUDENT_BY_STAMP;
extern NSInteger IS_DIFFERENT_DAY;
extern NSInteger STUDENT_CHECK_IN;
extern NSInteger STUDENT_CHECK_OUT;
extern NSInteger ALL_STUDENT_CHECK_IN;
extern NSInteger ALL_STUDENT_CHECK_OUT;
extern NSInteger GET_USER_BY_STAMP;
extern NSInteger RESET_PASSWORD;
extern NSInteger SUBTRACT_POINTS;

extern NSInteger menuItemFontSize;


+ (NSString *) getConnectionTypeString:(NSInteger)connectionType;


+ (UIColor *) CHBlueColor;


+ (UIColor *) CHGreenColor;


+ (UIColor *) CHRedColor;


+ (UIColor *) CHGoldColor;


+ (NSString *) getDate;


+ (NSString *) isNumeric:(NSString *)input;


+ (NSString *)isInputValid:(NSString *)input :(NSString *)inputName;


+ (bool)isValidClassroomHeroStamp:(NSString *)serial;


+ (UIAlertView *) editAlertNumberWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done input:(NSString *)input tag:(NSInteger)tag view:(UIViewController *)view;


+ (UIAlertView *) editAlertTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete input:(NSString *)input tag:(NSInteger)tag view:(UIViewController *)view capitalizationType:(UITextAutocapitalizationType)type;


+ (void) editTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) editAlertTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) editAlertAddStudentWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) editAlertEditStudentWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) setTextFieldPlaceholder:(UITextField *)textField :(NSString *)placeholder :(UIColor *)color;


+ (void) makeRoundedButton:(UIButton *)button :(UIColor *)color;


+ (void) makeRoundedLabel:(UILabel *)label :(UIColor *)color;


+ (void) alertStatusWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel otherTitles:(NSArray *)otherTitles tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) alertStatusNoConnection;


+ (NSString *) getRandomCompliment;


+ (NSString *) getRandomLoadingMessage;


+ (void) wiggleImage:(UIImageView *)image sound:(bool)sound;


+ (void) sackWiggle:(UIImageView *)sack;


+ (void) failAnimation:(UIImageView *)image;


+ (SystemSoundID) getFailSound;


+ (SystemSoundID) getTheSoundOfSuccess;


+ (SystemSoundID) getAwardSound;


+ (SystemSoundID) getTeacherStampSound;


+ (SystemSoundID) getLevelUpSound;


+ (SystemSoundID) getCoinShakeSound;


+ (SystemSoundID) getAwardAllSound;


+ (SystemSoundID) getJarSuccessSound;


+ (SystemSoundID) getCorkSound;


+ (SystemSoundID) getAchievementSound;


+ (NSInteger) getRewardNumber;


+ (NSString *)getCurrentDate;


+ (BOOL)isNewDate:(NSString *)oldDate;


+ (BOOL)isIPadPro;


+ (id) getStudentWitharray:(NSMutableArray *)searchArray propertyName:(NSString *)propertyName searchString:(NSString *)searchString;

+ (NSString *)getPackageDescriptionWithpackageId:(NSInteger)packageId stamps:(NSInteger)stamps;

+ (long) getNavigationBarButtonSize;

+ (void) setFontSizeWithbuttons:(NSArray *)buttons font:(NSString *)font size:(float)size;

@end
