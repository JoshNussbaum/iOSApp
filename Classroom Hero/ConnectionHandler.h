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
    NSMutableData *responseData;
}

- (id)initWithDelegate:(id<ConnectionHandlerDelegate>)delegate;


+(ConnectionHandler *)getSharedInstance;


- (void)logIn:(NSString *)email :(NSString *)password :(double)date;


- (void)createAccount:(NSString *)email :(NSString *)password :(NSString *)fname :(NSString *)lname;


- (void)addClass:(NSInteger)id :(NSString *)name :(NSInteger)grade :(NSInteger)schoolId;


- (void)editClass:(NSInteger)id :(NSString *)name :(NSInteger)grade :(NSInteger)schoolId;


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


- (void)addStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname :(NSInteger)schoolId;


- (void)editStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname;


- (void)deleteStudent:(NSInteger)id;


- (void)getSchools;


- (void)registerStamp:(NSInteger)id :(NSString *)serial :(NSInteger)cid;


- (void)rewardStudentWithid:(NSInteger)id pointsEarned:(NSInteger)pointsEarned reinforcerId:(NSInteger)reinforcerId schoolId:(NSInteger)schoolId classId:(NSInteger)classId;


- (void)rewardStudentsWithids:(NSMutableArray *)ids pointsEarned:(NSInteger)pointsEarned reinforcerId:(NSInteger)reinforcerId schoolId:(NSInteger)schoolId classId:(NSInteger)classId;


- (void)rewardAllStudentsWithcid:(NSInteger)cid;


- (void)addToClassJar:(NSInteger)cjid :(NSInteger)points :(NSInteger)cid;


- (void)studentTransactionWithsid:(NSInteger)sid iid:(NSInteger)iid cost:(NSInteger)cost cid:(NSInteger)cid;


- (void)unregisterStampWithid:(NSInteger)id;


- (void)editTeacherNameWithid:(NSInteger)id firstName:(NSString *)firstName lastName:(NSString *)lastName;


- (void)editTeacherPasswordWithemail:(NSString *)email oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;


- (void)stampToLogin:(NSString *)stampSerial;


- (void)getClassStatsWithclassId:(NSInteger)classId schoolId:(NSInteger)schoolId;


- (void)identifyStampWithserial:(NSString *)serial;


- (void)unregisterAllStampsWithClassId:(NSInteger)classId;


- (void)getStudentBySerialwithserial:(NSString *)serial :(NSInteger)schoolId;


- (void)checkInStudentWithstudentId:(NSInteger)studentId classId:(NSInteger)classId stamp:(BOOL)stamp;


- (void)checkOutStudentWithstudentId:(NSInteger)studentId classId:(NSInteger)classId;


- (void)checkInAllStudentsWithclassId:(NSInteger)classId;


- (void)checkOutAllStudentsWithclassId:(NSInteger)classId;


- (void)getUserBySerialWithserial:(NSString *)serial;


- (void)resetPasswordWithemail:(NSString *)email;


@end
