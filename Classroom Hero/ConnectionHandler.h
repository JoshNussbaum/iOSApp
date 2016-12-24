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
    NSString *token_;
    NSMutableData *responseData;
}

- (id)initWithDelegate:(id<ConnectionHandlerDelegate>)delegate token:(NSString *)token;


+(ConnectionHandler *)getSharedInstance;


- (void)logIn:(NSString *)email :(NSString *)password;


- (void)createAccount:(NSString *)email :(NSString *)password :(NSString *)fname :(NSString *)lname;


- (void)addClass:(NSInteger)id :(NSString *)name :(NSInteger)grade;


- (void)editClass:(NSInteger)id :(NSString *)name :(NSInteger)grade;


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


- (void)getSchools;


- (void)rewardStudentWithid:(NSInteger)id pointsEarned:(NSInteger)pointsEarned reinforcerId:(NSInteger)reinforcerId classId:(NSInteger)classId;


- (void)rewardStudentsWithids:(NSMutableArray *)ids pointsEarned:(NSInteger)pointsEarned reinforcerId:(NSInteger)reinforcerId classId:(NSInteger)classId;


- (void)rewardAllStudentsWithcid:(NSInteger)cid;


- (void)subtractPointsWithStudentId:(NSInteger)id points:(NSInteger)points;


- (void)addPointsWithStudentId:(NSInteger)id points:(NSInteger)points;


- (void)addToClassJar:(NSInteger)cjid :(NSInteger)points :(NSInteger)cid;


- (void)studentTransactionWithsid:(NSInteger)sid iid:(NSInteger)iid cost:(NSInteger)cost cid:(NSInteger)cid;


- (void)editTeacherNameWithid:(NSInteger)id firstName:(NSString *)firstName lastName:(NSString *)lastName;


- (void)editTeacherPasswordWithemail:(NSString *)email oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;


- (void)getClassStatsWithclassId:(NSInteger)classId;


- (void)checkInStudentWithstudentId:(NSInteger)studentId classId:(NSInteger)classId;


- (void)checkOutStudentWithstudentId:(NSInteger)studentId classId:(NSInteger)classId;


- (void)checkInAllStudentsWithclassId:(NSInteger)classId;


- (void)checkOutAllStudentsWithclassId:(NSInteger)classId;


- (void)resetPasswordWithemail:(NSString *)email;


@end
