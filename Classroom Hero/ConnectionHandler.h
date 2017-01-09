//
//  ConnectionHandler.h
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "user.h"

@protocol ConnectionHandlerDelegate

- (void)dataReady:(NSDictionary*)data :(NSInteger)type;

@end

@interface ConnectionHandler : NSObject
{
    user *currentUser;
    id delegate_;
    NSInteger classId_;
    NSString *token_;
    NSMutableData *responseData;
}

- (id)initWithDelegate:(id<ConnectionHandlerDelegate>)delegate token:(NSString *)token classId:(NSInteger)classId;


+(ConnectionHandler *)getSharedInstance;


- (void)logIn:(NSString *)email :(NSString *)password;


- (void)createAccount:(NSString *)email :(NSString *)password :(NSString *)fname :(NSString *)lname;


- (void)addClass:(NSInteger)id :(NSString *)name :(NSString *)grade;


- (void)editClass:(NSInteger)id :(NSString *)name :(NSString *)grade;


- (void)deleteClass:(NSInteger)id;


- (void)addReinforcer:(NSInteger)id :(NSString *)name :(NSInteger)value;


- (void)editReinforcer:(NSInteger)id :(NSString *)name :(NSInteger)value;


- (void)deleteReinforcer:(NSInteger)id;


- (void)addItem:(NSInteger)id :(NSString *)name :(NSInteger)cost;


- (void)editItem:(NSInteger)id :(NSString *)name :(NSInteger)cost;


- (void)deleteItem:(NSInteger)id;


- (void)addJar:(NSInteger)id :(NSString *)name :(NSInteger)goal;


- (void)editJar:(NSInteger)id :(NSString *)name :(NSInteger)goal :(NSInteger)progress;


- (void)deleteJar:(NSInteger)id;


- (void)addStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname;


- (void)editStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname;


- (void)deleteStudent:(NSInteger)id;


- (void)rewardStudentWithid:(NSInteger)id reinforcerId:(NSInteger)reinforcerId;


- (void)rewardStudentsWithids:(NSMutableArray *)ids reinforcerId:(NSInteger)reinforcerId;


- (void)subtractPointsWithStudentId:(NSInteger)id points:(NSInteger)points;


- (void)addPointsWithStudentId:(NSInteger)id points:(NSInteger)points;


- (void)addToClassJar:(NSInteger)cjid :(NSInteger)points;


- (void)studentTransactionWithsid:(NSInteger)sid iid:(NSInteger)iid;


- (void)editTeacherNameWithid:(NSInteger)id firstName:(NSString *)firstName lastName:(NSString *)lastName;


- (void)editTeacherPasswordWithid:(NSInteger)id password:(NSString *)password;


- (void)checkInStudentWithstudentId:(NSInteger)studentId :(BOOL)manual;


- (void)checkOutStudentWithstudentId:(NSInteger)studentId;


- (void)checkInAllStudents;


- (void)checkOutAllStudents;


- (void)resetPasswordWithemail:(NSString *)email;


@end
