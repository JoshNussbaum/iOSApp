//
//  DatabaseHandler.h
//  Classroom Hero
//
//  Created by Josh on 7/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "user.h"
#import "school.h"
#import "class.h"
#import "student.h"
#import "reinforcer.h"
#import "item.h"
#import "classjar.h"

@interface DatabaseHandler : NSObject{
    NSString *databasePath;
    NSString *ClassroomHeroDB;
    user *currentUser;
    NSMutableData *_responseData;
}

+(DatabaseHandler *)getSharedInstance;


// Create Functions
- (BOOL)createDatabase;


- (void)addClass:(class *)cl;


- (void)addStudent:(student *)ss :(NSInteger)cid;


- (void)addStudentToClass:(NSInteger)studentId :(NSInteger)classId;


- (void)addReinforcer:(reinforcer *)rr;


- (void)addItem:(item *)ii;


- (void)addClassJar:(classjar *)cj;


- (void)addSchools:(NSMutableArray *)schools;


- (void)login:(NSDictionary *)loginInfo;


// Read Functions
- (NSMutableArray *)getClasses;


- (NSMutableArray *)getStudents:(NSInteger)cid;


- (NSMutableArray *)getReinforcers:(NSInteger)cid;


- (NSMutableArray *)getItems:(NSInteger)cid;


- (classjar *)getClassJar:(NSInteger)cid;


- (student *)getStudentWithSerial:(NSString *)serial;


- (student *)getStudentWithID:(NSInteger)sid;


- (NSMutableArray *)getSchools;


- (NSString *)getSchoolName:(NSInteger)sid;


- (NSInteger)getNumberOfStudentsInClass:(NSInteger)cid;


- (NSMutableDictionary *)getNumberOfStudentsInClasses:(NSMutableArray *)classIds;


-(NSMutableArray *)getUnregisteredStudents:(NSInteger)cid;


- (NSInteger)getNumberOfUnregisteredStudentsInClass:(NSInteger)cid;


// Update Functions

- (void)editClass:(class *)updatedClass;

- (void)registerStudent:(NSInteger)sid :(NSString *)serial;


// Delete Functions

- (void)deleteClass:(NSInteger)cid;

- (void)resetDatabase;



// Misc Functions
-(bool) isSerialRegistered:(NSString *)serial;

- (bool)doesClassNameExist:(NSString *)className;



@end
