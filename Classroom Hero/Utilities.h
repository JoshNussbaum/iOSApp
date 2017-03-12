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
extern NSInteger ADD_POINTS;
extern NSInteger ADD_POINTS_BULK;
extern NSInteger SUBTRACT_POINTS_BULK;

extern NSInteger menuItemFontSize;


/*                                                          Alert Views                           */


// Let's turn all of these into ONE

+ (UIAlertView *) alertViewWithTitle:(NSString *)title message:(NSString *)message cancel:(NSDictionary *)cancelButtonDictionary other:(NSArray *)otherButtonArray delete:(NSDictionary *)deleteButtonDictionary textfields:(NSDictionary *)textFieldsDictionary tag:(NSInteger)tag view:(UIViewController *)view;

+ (void) alertStatusNoConnection;


+ (void) alertStatusWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel otherTitles:(NSArray *)otherTitles tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) disappearingAlertView:(NSString *)title message:(NSString *)message otherTitles:(NSArray *)otherTitles tag:(NSInteger)tag view:(UIViewController *)view time:(double)delayInSeconds;


+ (void) editAlertEditStudentWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


+ (UIAlertView *) editAlertNumberWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done input:(NSString *)input tag:(NSInteger)tag view:(UIViewController *)view;


+ (UIAlertView *) editAlertTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete input:(NSString *)input tag:(NSInteger)tag view:(UIViewController *)view capitalizationType:(UITextAutocapitalizationType)type;


+ (void) editTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) editAlertTextWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


+ (void) editAlertAddStudentWithtitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel done:(NSString *)done delete:(bool)delete textfields:(NSArray *)textfields tag:(NSInteger)tag view:(UIViewController *)view;


/*                                                          Validation                           */

+ (BOOL)isNewDate:(NSString *)oldDate;


+ (NSString *) isNumeric:(NSString *)input;


+ (NSString *)isInputValid:(NSString *)input :(NSString *)inputName;


/*                                                          Animations                           */

+ (void) wiggleImage:(UIImageView *)image sound:(bool)sound vertically:(bool)vertically;


+ (void) failAnimation:(UIImageView *)image;



/*                                                          Setters                           */

+ (void) setTextFieldPlaceholder:(UITextField *)textField :(NSString *)placeholder :(UIColor *)color;


// LETS SEE ALL THESE MAKE ROUNDED LABELS TO ONE 


+ (void) makeRoundedButton:(UIButton *)button :(UIColor *)color;


+ (void) makeRoundedLabel:(UILabel *)label :(UIColor *)color;


+ (void) makeRounded:(CALayer *)layer color:(UIColor *)color borderWidth:(float)borderWidth cornerRadius:(float)cornerRadius;


+ (void) setFontSizeWithbuttons:(NSArray *)buttons font:(NSString *)font size:(float)size;



/*                                                          Getters                           */

//+ (NSMutableDictionary *)getStudentsDataDictionaryWithClassId:(NSInteger)classId studentIds:(NSMutableArray *)studentIds;


+ (NSString *) getCurrentDate;


+ (NSString *) getDate;


+ (NSString *) getConnectionTypeString:(NSInteger)connectionType;


+ (BOOL)isIPadPro;


+ (BOOL) isIPhone;


+ (long) getNavigationBarButtonSize;


+ (NSString *) getRandomCompliment;


+ (UIColor *)CHLightBlueColor;


+ (UIColor *)CHLightGreenColor;


+ (UIColor *) CHBlueColor;


+ (UIColor *) CHGreenColor;


+ (UIColor *) CHRedColor;


+ (UIColor *) CHGoldColor;


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


@end
