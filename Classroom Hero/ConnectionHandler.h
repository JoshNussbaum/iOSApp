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

- (void)logIn:(NSString *)email :(NSString *)password;


- (void)createAccount:(NSString *)email :(NSString *)password :(NSString *)fname :(NSString *)lname;


- (void)addClass:(NSInteger)id :(NSString *)name :(NSInteger)grade :(NSInteger)schoolId;


- (void)editClass:(NSInteger)id :(NSString *)name :(NSInteger)grade :(NSInteger)schoolId;


- (void)deleteClass:(NSInteger)id;


- (void)addReinforcer:(NSInteger)id :(NSString *)name;


- (void)editCategory:(NSInteger)id :(NSString *)name;


- (void)deleteCategory:(NSInteger)id;


- (void)addItem:(NSInteger)id :(NSString *)name :(NSInteger)cost;


- (void)editItem:(NSInteger)id :(NSString *)name :(NSInteger)cost;


- (void)deleteItem:(NSInteger)id;


- (void)addJar:(NSInteger)id :(NSString *)name :(NSInteger)goal;


- (void)editJar:(NSInteger)id :(NSString *)name :(NSInteger)goal;


- (void)deleteJar:(NSInteger)id;


- (void)addStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname;


- (void)editStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname :(NSString *)serial;


- (void)deleteStudent:(NSInteger)id;


- (void)getSchools;


- (void)registerStamp:(NSInteger)id :(NSString *)serial;


- (void)rewardStudentWithid:(NSInteger)id pointsEarned:(NSInteger)pointsEarned categoryId:(NSInteger)categoryId;


- (void)rewardAllStudentsWithcid:(NSInteger)cid;


- (void)addToClassJar:(NSInteger)cjid :(NSInteger)points;


- (void)studentTransactionWithsid:(NSInteger)sid iid:(NSInteger)iid cost:(NSInteger)cost;


- (void)orderStampsWithid:(NSInteger)id packageId:(NSInteger)packageId :(NSInteger)stamps :(NSInteger)schoolId;


- (void)unregisterStampWithid:(NSInteger)id;


@end
