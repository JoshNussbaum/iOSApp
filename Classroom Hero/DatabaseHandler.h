//
//  DatabaseHandler.h
//  Classroom Hero
//
//  Created by Josh on 7/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "user.h"
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
-(BOOL)createDatabase;

-(void)addClass:(class *)cl;

-(void)addStudent:(student *)ss;

-(void)addStudentToClass:(NSInteger)studentId :(NSInteger)classId;

-(void)addReinforcer:(reinforcer *)rr;

-(void)addItem:(item *)ii;

-(void)addClassJar:(classjar *)cj;

// Read Functions
-(NSMutableArray *)getStudents:(NSInteger)cid;

-(NSMutableArray *)getUnregisteredStudents:(NSInteger)cid;

-(NSMutableArray *)getReinforcers:(NSInteger)cid;

-(NSMutableArray *)getItems:(NSInteger)cid;

-(classjar *)getClassJar:(NSInteger)cid;

-(student *)getStudentWithSerial:(NSString *)serial;

-(student *)getStudentWithID:(NSInteger)sid;



// Misc Functions
-(bool)doesClassNameExist:(NSString *)className;



@end
