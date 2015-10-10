//
//  DatabaseHandler.m
//  Classroom Hero
//
//  Created by Josh on 7/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "DatabaseHandler.h"
#import <sqlite3.h>
#import "Utilities.h"


static DatabaseHandler *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DatabaseHandler


+(DatabaseHandler *)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDatabase];
    }
    return sharedInstance;
}


- (BOOL)createDatabase{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"ClassroomHeroDB.db"]];
    BOOL isSuccess = YES;
    //Create filemanager and use it to check if database file already exists
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == YES)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            //Create Tables
            char *errMsg;
            const char *create_tables =
            "DROP TABLE IF EXISTS School;"
            "DROP TABLE IF EXISTS Class;"
            "DROP TABLE IF EXISTS Student;"
            "DROP TABLE IF EXISTS Reinforcer;"
            "DROP TABLE IF EXISTS Item;"
            "DROP TABLE IF EXISTS ClassJar;"
            "DROP TABLE IF EXISTS Point;"
            "DROP TABLE IF EXISTS Transactions;"
            "DROP TABLE IF EXISTS StudentClassMatch;"
            "CREATE TABLE School (id integer primary key, name text);"
            "CREATE TABLE Class (id integer primary key, name text, grade integer, schoolid integer, level integer, progress integer, nextlevel integer);"
            "CREATE TABLE Student (id integer primary key, firstname text, lastname text, serial text, lvl integer, progress integer, lvlupamount integer, points integer, totalpoints integer);"
            "CREATE TABLE Reinforcer (id integer primary key, cid integer, name text, value integer);"
            "CREATE TABLE Item (id integer primary key, cid integer, name text, cost integer);"
            "CREATE TABLE ClassJar (id integer primary key, cid integer, name text, progress integer, total integer);"
            "CREATE TABLE Point (id integer, cid integer, timestamp text);"
            "CREATE TABLE Transactions (id integer, iid integer, timestamp text);"
            "CREATE TABLE StudentClassMatch (sid integer, cid integer);"
            "CREATE TABLE StudentSchoolMatch (studentId integer, schoolId integer);";
            
            if (sqlite3_exec(database, create_tables, NULL, NULL, &errMsg) == SQLITE_OK)
            {
                NSLog(@"Created DB");
                sqlite3_close(database);
                return  isSuccess;
            }
            else
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    sqlite3_close(database);
    return isSuccess;
}


#pragma mark - Create


- (void) addClass:(class *)cl{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Class (id, name, grade, schoolid, level, progress, nextlevel) VALUES (%ld, \"%@\", %ld, %ld, %ld, %ld, %ld)", (long)[cl getId], [cl getName], (long)[cl getGradeNumber], (long)[cl getSchoolId], (long)[cl getLevel], (long)[cl getProgress], (long)[cl getNextLevel]];
        NSLog(@"Add class query -> %@", querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_DONE) NSLog(@"we added a class");
            sqlite3_finalize(statement);
        }
        
    }
    sqlite3_close(database);
}


- (void) addStudent:(student *)ss :(NSInteger)cid :(NSInteger)schoolId{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //            "CREATE TABLE Student (id integer primary key, firstname text, lastname text, serial text, lvl integer, progress integer, lvlupamount integer, points integer, totalpoints integer);"

        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Student (id, firstname, lastname, serial, lvl, progress, lvlupamount, points, totalpoints) VALUES (%ld, \"%@\", \"%@\", \"%@\", %ld, %ld, %ld, %ld, %ld)", (long)[ss getId], [ss getFirstName], [ss getLastName], [ss getSerial], (long)[ss getLvl], (long)[ss getProgress], (long)[ss getLvlUpAmount], (long)[ss getPoints], (long)[ss getTotalPoints]];
        
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
        NSString *querySQL2 = [NSString stringWithFormat:
                               @"INSERT INTO StudentClassMatch (sid, cid) VALUES (%ld, %ld)", (long)[ss getId], (long)cid];
        
        const char *query_stmt2 = [querySQL2 UTF8String];
        sqlite3_prepare_v2(database, query_stmt2,-1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
        NSString *querySQL3 = [NSString stringWithFormat:
                               @"INSERT INTO StudentSchoolMatch (studentId, schoolId) VALUES (%ld, %ld)", (long)[ss getId], (long)schoolId];
        const char *query_stmt3 = [querySQL3 UTF8String];
        sqlite3_prepare_v2(database, query_stmt3,-1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}


- (void) addStudentToClass:(NSInteger)studentId :(NSInteger)classId{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO StudentClassMatch (sid, cid) VALUES (%ld, %ld)", (long)studentId, (long)classId];
        
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}


- (void) addReinforcer:(reinforcer *)rr{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Reinforcer (id, cid, name, value) VALUES (%ld, %ld, \"%@\", %ld)", (long)[rr getId], (long)[rr getCid], [rr getName], (long)[rr getValue]];
        
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}


- (void) addItem:(item *)ii{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Item (id, cid, name, cost) VALUES (%ld, %ld, \"%@\", %ld)", (long)[ii getId], (long)[ii getCid], [ii getName], (long)[ii getCost]];
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}


- (void) addClassJar:(classjar *)cj{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO ClassJar (id, cid, name, progress, total) VALUES (%ld, %ld, \"%@\", %ld, %ld)", (long)[cj getId], (long)[cj getCid], [cj getName], (long)[cj getProgress], (long)[cj getTotal]];
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}


- (void) addSchools:(NSMutableArray *)schools{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        for (NSDictionary *school in schools)
        {
            NSInteger schoolId = [school[@"id"] intValue];
            NSString *schoolName = school[@"name"];
            
            NSString *querySQL = [NSString stringWithFormat:
                                  @"Insert INTO School (id, name) VALUES (%ld,\"%@\")", (long)schoolId, schoolName];
            const char *query_stmt = [querySQL UTF8String];
            sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            
        }
    }
    sqlite3_close(database);
}


- (void) login:(NSDictionary *)loginInfo{
    currentUser = [user getInstance];
    NSMutableArray *classes = [loginInfo objectForKey:@"classes"];
    NSMutableArray *schools = [loginInfo objectForKey:@"schools"];
    
    if (classes.count == 0){
        currentUser.currentClass = [[class alloc]init];
        [currentUser.currentClass setId:0];
    }
    
    [self addSchools:schools];
        
    for (NSInteger i=0; i< classes.count; i++){
        NSDictionary *classDictionary = [classes objectAtIndex:i];
        NSInteger cid = [classDictionary[@"cid"]integerValue];
        NSString *className = classDictionary[@"name"];
        NSInteger progress = [classDictionary[@"classProgress"]integerValue];
        NSInteger grade = [classDictionary[@"grade"]integerValue];
        NSInteger nextLevel = [classDictionary[@"nextLvl"]integerValue];
        NSInteger level = [classDictionary[@"classLvl"]integerValue];
        NSInteger schoolId = [classDictionary[@"schoolId"]integerValue];
        
        class *newClass = [[class alloc] init:cid :className :grade :schoolId :level :progress :nextLevel];
        if (i == 0) currentUser.currentClass = newClass;
        [self addClass:newClass];
        
        
        NSMutableArray *students = [classDictionary objectForKey:@"students"];
        for (NSDictionary *studentDictionary in students){
            NSInteger sid = [[studentDictionary objectForKey:@"uid"]integerValue];
            NSString *fname = [studentDictionary objectForKey:@"fname"];
            NSString *lname = [studentDictionary objectForKey:@"lname"];
            NSString *serial = [studentDictionary objectForKey:@"stamp"];
        
            if (!serial){
                serial = @"";
            }
            
            NSInteger currentCoins = [[studentDictionary objectForKey:@"currentCoins"]integerValue];
            NSInteger lvl = [[studentDictionary objectForKey:@"lvl"]integerValue];
            NSInteger lvlUpAmount = 2 + (2*(lvl-1));
            NSInteger progress = [[studentDictionary objectForKey:@"progress"]integerValue];
            NSInteger totalCoins = [[studentDictionary objectForKey:@"totalCoins"]integerValue];
            
            student *newStudent = [[student alloc] initWithid:sid firstName:fname lastName:lname serial:serial lvl:lvl progress:progress lvlupamount:lvlUpAmount points:currentCoins totalpoints:totalCoins];
            [self addStudent:newStudent :cid :schoolId];
            
        }
        NSMutableArray *reinforcers = [classDictionary objectForKey:@"categories"];

        for (NSDictionary *reinforcerDictionary in reinforcers){
            NSInteger rid = [[reinforcerDictionary objectForKey:@"id"]integerValue ];
            NSString *name = [reinforcerDictionary objectForKey:@"name"];
            NSInteger value = [[reinforcerDictionary objectForKey:@"value"]integerValue ];

            reinforcer *newReinforcer = [[reinforcer alloc] init:rid :cid :name :value];
            [self addReinforcer:newReinforcer];
        }
       
        NSMutableArray *items = [classDictionary objectForKey:@"items"];
        for (NSDictionary *itemDictionary in items){
            NSInteger iid = [[itemDictionary objectForKey:@"id"]integerValue ];
            NSString *name = [itemDictionary objectForKey:@"name"];
            NSInteger cost = [[itemDictionary objectForKey:@"cost"]integerValue ];
            item *newItem = [[item alloc] init:iid :cid :name :cost];
            [self addItem:newItem];
        }
        NSMutableArray *jars = [classDictionary objectForKey:@"jars"];
        for (NSDictionary *classJarDictionary in jars){
            NSInteger jid = [[classJarDictionary objectForKey:@"jid"]integerValue];
            NSString *name = [classJarDictionary objectForKey:@"name"];
            NSInteger jarProgress = [[classJarDictionary objectForKey:@"progress"]integerValue];
            NSInteger total = [[classJarDictionary objectForKey:@"total"]integerValue ];
            
            classjar *newJar = [[classjar alloc] initWithid:jid cid:cid name:name progress:jarProgress total:total];
            
            [newJar printJar];
            [self addClassJar:newJar];
            
        }

        
    }
}


#pragma mark - Read


- (NSMutableArray *) getClasses{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT * FROM class";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSInteger id = sqlite3_column_int(statement, 0);
                
                NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                
                NSInteger grade = sqlite3_column_int(statement, 2);
                
                NSInteger schoolid = sqlite3_column_int(statement, 3);
                
                NSInteger level = sqlite3_column_int(statement, 4);
                
                NSInteger progress = sqlite3_column_int(statement, 5);
                
                NSInteger nextlevel = sqlite3_column_int(statement, 6);
                
                class *cc = [[class alloc]init:id :name :grade :schoolid :level :progress :nextlevel];
                [resultArray addObject:cc];
                
            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            NSMutableArray *reversed = [[[resultArray reverseObjectEnumerator]allObjects]mutableCopy];
            return reversed;
        }
    }
    sqlite3_close(database);
    return nil;
}

//            "CREATE TABLE Class (id integer primary key, name text, grade integer, schoolid integer, level integer, progress integer, nextlevel integer);"

- (class *) getClass:(NSInteger)classId{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *getClassQuery = [NSString stringWithFormat:@"SELECT * FROM Class WHERE id=%ld", (long)classId];
        const char *query_stmt = [getClassQuery UTF8String];
        class *foundClass;
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger id = sqlite3_column_int(statement, 0);
                
                NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                
                NSInteger grade = sqlite3_column_int(statement, 2);
                
                NSInteger schoolId = sqlite3_column_int(statement, 3);
                
                NSInteger level = sqlite3_column_int(statement, 4);
                
                NSInteger progress = sqlite3_column_int(statement, 7);
                
                NSInteger nextlevel = sqlite3_column_int(statement, 8);
                
                foundClass = [[class alloc]init:id :name :grade :schoolId :level :progress :nextlevel];
                
                sqlite3_finalize(statement);
                
            }
        }
        sqlite3_close(database);
        return foundClass;
    }
    sqlite3_close(database);
    return nil;
}


- (class *) getClassWithstudentId:(NSInteger)studentId{
    NSInteger cid = [self getClassIdByStudentId:studentId];
    class *foundClass = [self getClass:cid];
    return foundClass;
}


- (NSInteger) getClassIdByStudentId:(NSInteger)studentId{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@" SELECT cid from StudentClassMatch WHERE sid=%ld", (long)studentId];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger cid = sqlite3_column_int(statement, 0);
                
                sqlite3_reset(statement);
                sqlite3_close(database);
                return cid;
            }
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return 0;
}


- (NSMutableArray *)getStudents:(NSInteger)cid{
    NSMutableArray *studentIds = [self getStudentIds:cid];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSMutableArray *allStudents = [[NSMutableArray alloc]init];
        for (NSNumber *studentId in studentIds){
            NSInteger sid = [studentId integerValue];
            NSString *getStudentsQuery = [NSString stringWithFormat:@"SELECT id, firstname, lastname, serial, lvl, progress, lvlupamount, points, totalpoints FROM Student WHERE id=%ld", (long)sid];
            const char *query_stmt = [getStudentsQuery UTF8String];
            
            if (sqlite3_prepare_v2(database,
                                   query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSInteger id = sqlite3_column_int(statement, 0);
                    
                    NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    
                    NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                    
                    NSString *serial = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                    
                    NSInteger level = sqlite3_column_int(statement, 4);
                    
                    NSInteger progress = sqlite3_column_int(statement, 5);
                    
                    NSInteger levelUpAmount = sqlite3_column_int(statement, 6);
                    
                    NSInteger points = sqlite3_column_int(statement, 7);
                    
                    NSInteger totalPoints = sqlite3_column_int(statement, 8);
                    
                    student *ss = [[student alloc] initWithid:id firstName:firstName lastName:lastName serial:serial lvl:level progress:progress lvlupamount:levelUpAmount points:points totalpoints:totalPoints];
                    [allStudents addObject:ss];
                    
                    sqlite3_finalize(statement);
                    
                }
            }
        }
        
        [allStudents sortUsingDescriptors:
         [NSArray arrayWithObjects:
          [NSSortDescriptor sortDescriptorWithKey:@"lvl" ascending:NO],
          [NSSortDescriptor sortDescriptorWithKey:@"progress" ascending:NO],
          [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO], nil]
         ];
        
        NSMutableArray *reversed = [[[allStudents reverseObjectEnumerator]allObjects]mutableCopy];
        
        sqlite3_close(database);
        return reversed;
    }
    sqlite3_close(database);
    return nil;
}


- (NSMutableArray *)getReinforcers:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * from Reinforcer where cid=%ld", (long)cid];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger id = sqlite3_column_int(statement, 0);
                
                NSInteger cid = sqlite3_column_int(statement, 1);
                
                NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                
                NSInteger value = sqlite3_column_int(statement, 3);
                
                reinforcer *rr = [[reinforcer alloc] init:id :cid :name :value];
                [resultArray addObject:rr];
                
            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            NSMutableArray *reversed = [[[resultArray reverseObjectEnumerator]allObjects]mutableCopy];
            return reversed;
        }
    }
    sqlite3_close(database);
    return nil;
}


- (NSMutableArray *)getItems:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * from Item where cid=%ld", (long)cid];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger id = sqlite3_column_int(statement, 0);
                
                NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                
                NSInteger cost = sqlite3_column_int(statement, 3);
                
                item *ii = [[item alloc]init:id :cid :name :cost];
                
                [resultArray addObject:ii];
                
            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            NSMutableArray *reversed = [[[resultArray reverseObjectEnumerator]allObjects]mutableCopy];
            return reversed;
        }
    }
    sqlite3_close(database);
    return nil;
}


- (classjar *)getClassJar:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM ClassJar where cid=%ld", (long)cid];
        
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        while (sqlite3_step(statement) == SQLITE_ROW){
            
            NSInteger id = sqlite3_column_int(statement, 0);
            
            NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            
            NSInteger progress = sqlite3_column_int(statement, 3);
            
            NSInteger total = sqlite3_column_int(statement, 4);
            
            classjar *cj = [[classjar alloc] initWithid:id cid:cid name:name progress:progress total:total];
            
            sqlite3_reset(statement);
                        
            
            return cj;
        }
    }
    return nil;
}


- (student *)getStudentWithSerial:(NSString *)serial{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * from Student WHERE serial=\"%@\"", serial];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW){
                @try {
                    NSInteger id = sqlite3_column_int(statement, 0);
                    
                    NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    
                    NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                    
                    NSString *serial = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                    
                    NSInteger lvl = sqlite3_column_int(statement, 4);
                    
                    NSInteger progress = sqlite3_column_int(statement, 5);
                    
                    NSInteger lvlupamount = sqlite3_column_int(statement, 6);
                    
                    NSInteger points = sqlite3_column_int(statement, 7);
                    
                    NSInteger totalpoints = sqlite3_column_int(statement, 8);
                    
                    student *ss = [[student alloc] initWithid:id firstName:firstName lastName:lastName serial:serial lvl:lvl progress:progress lvlupamount:lvlupamount points:points totalpoints:totalpoints];
                    
                    [ss printStudent];
                    
                    sqlite3_reset(statement);
                    sqlite3_close(database);
                    return (ss);
                }
                @catch (NSException * e) {
                    sqlite3_reset(statement);
                    sqlite3_close(database);
                    return nil;
                }
            }
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}


- (student *)getStudentWithID:(NSInteger)sid{
    return nil;
}


- (NSMutableArray *)getSchools{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT * FROM School";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger id = sqlite3_column_int(statement, 0);
                
                NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                
                school *ss = [[school alloc]init:id :name];
                
                [resultArray addObject:ss];
                
            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            return resultArray;
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}


- (NSString *)getSchoolName:(NSInteger)sid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@" SELECT * FROM School WHERE id=%ld", (long)sid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                sqlite3_reset(statement);
                sqlite3_close(database);
                return name;
            }
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}


- (NSInteger)getNumberOfStudentsInClass:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM StudentClassMatch WHERE cid = %ld", (long)cid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger studentCount = sqlite3_column_int(statement, 0);
                sqlite3_reset(statement);
                sqlite3_close(database);
                return studentCount;
            }
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return 0;
}


- (NSMutableDictionary *)getNumberOfStudentsInClasses:(NSMutableArray *)classIds{
    NSMutableDictionary *numberOfStudentsByClassId = [[NSMutableDictionary alloc]init];
    for (NSNumber *classId in classIds){
        NSInteger numberOfStudents = [self getNumberOfStudentsInClass:[classId integerValue]];
        NSNumber *numOfStudents = [NSNumber numberWithInteger:numberOfStudents];
        [numberOfStudentsByClassId setObject:numOfStudents forKey:classId];
        
    }
    return numberOfStudentsByClassId;
}


- (NSMutableArray *)getStudentIds:(NSInteger )cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSMutableArray *studentIds = [[NSMutableArray alloc]init];
        NSString *getStudentsInClassQuery = [NSString stringWithFormat:@"SELECT sid FROM StudentClassMatch WHERE cid = %ld", (long)cid];
        const char *query_stmt = [getStudentsInClassQuery UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger studentCount = sqlite3_column_int(statement, 0);
                NSNumber *studentCountNumber = [NSNumber numberWithInteger:studentCount];
                [studentIds addObject:studentCountNumber];
                
            }
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
        return studentIds;
    }
    sqlite3_close(database);
    return nil;
}


- (NSMutableArray *)getUnregisteredStudents:(NSInteger)cid{
    NSMutableArray *studentIds = [self getStudentIds:cid];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSMutableArray *unregisteredStudents = [[NSMutableArray alloc]init];
        for (NSNumber *studentId in studentIds){
            NSInteger sid = [studentId integerValue];
            NSString *getUnregisteredStudentCount = [NSString stringWithFormat:@"SELECT id, firstname, lastname, serial FROM Student WHERE id=%ld AND serial=''", (long)sid];
            const char *query_stmt = [getUnregisteredStudentCount UTF8String];
            
            if (sqlite3_prepare_v2(database,
                                   query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    
                    NSString *serial = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                    
                    if ([serial isEqualToString:@""]){
                        NSInteger id = sqlite3_column_int(statement, 0);
                        
                        NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                        
                        NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                        
                        
                        student *ss = [[student alloc] init];
                        [ss setFirstName:firstName];
                        [ss setLastName:lastName];
                        [ss setId:id];
                        [unregisteredStudents addObject:ss];
                        
                        sqlite3_finalize(statement);
                        

                    }
  
                }
            }
        }
        sqlite3_close(database);
        return unregisteredStudents;
    }
    sqlite3_close(database);
    return nil;
}


- (NSInteger)getNumberOfUnregisteredStudentsInClass:(NSInteger)cid{
    NSMutableArray *studentIds = [self getStudentIds:cid];

    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
   
        NSInteger studentCount = 0;
        
        for (NSNumber *studentId in studentIds){
            NSInteger sid = [studentId integerValue];
            NSString *getUnregisteredStudentCount = [NSString stringWithFormat:@"SELECT serial FROM Student WHERE id=%ld", (long)sid];
            const char *query_stmt = [getUnregisteredStudentCount UTF8String];
            
            if (sqlite3_prepare_v2(database,
                                   query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *serial = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                    if ([serial isEqualToString:@""]){
                        studentCount++;
                    }
                    sqlite3_finalize(statement);

                }
                
            }
        }
        sqlite3_close(database);
        return studentCount;

    }
    sqlite3_close(database);
    return 0;
}


//- (NSMutableArray *)getClassIdsBySchoolId:(NSInteger)schoolId{
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSMutableArray *classIds = [[NSMutableArray alloc]init];
//        NSString *getClassIdsQuery = [NSString stringWithFormat:@"SELECT id FROM Class WHERE schoolid = %ld", (long)schoolId];
//        const char *query_stmt = [getClassIdsQuery UTF8String];
//        if (sqlite3_prepare_v2(database,
//                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
//        {
//            while (sqlite3_step(statement) == SQLITE_ROW)
//            {
//                NSInteger classId = sqlite3_column_int(statement, 0);
//                NSNumber *classIdNumber = [NSNumber numberWithInteger:classId];
//                [classIds addObject:classIdNumber];
//                
//            }
//        }
//        sqlite3_reset(statement);
//        sqlite3_close(database);
//        return classIds;
//    }
//    sqlite3_close(database);
//    return nil;
//}
//
//
//- (NSMutableArray *)getStudentIdsByClassIds:(NSMutableArray *)classIds{
//    NSMutableArray *allStudentIds;
//    for (NSNumber *classId in classIds){
//        NSMutableArray *studentIds;
//        NSInteger classId_ = classId.integerValue;
//        studentIds = [self getStudentIds:classId_];
//        [allStudentIds addObjectsFromArray:studentIds];
//    }
//    return allStudentIds;
//}


- (NSMutableArray *) getSchoolIdsWithstudentId:(NSInteger)studentId{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSMutableArray *schoolIds = [[NSMutableArray alloc]init];
        NSString *getSchoolIdsQuery = [NSString stringWithFormat:@"SELECT schoolId FROM StudentSchoolMatch WHERE studentId = %ld", (long)studentId];
        const char *query_stmt = [getSchoolIdsQuery UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger schoolId = sqlite3_column_int(statement, 0);
                NSNumber *schoolIdNumber = [NSNumber numberWithInteger:schoolId];
                [schoolIds addObject:schoolIdNumber];
                
            }
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
        return schoolIds;
    }
    sqlite3_close(database);
    return nil;
}


#pragma mark - Update


- (void)editClass:(class *)updatedClass{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Categories SET name=\"%@\" WHERE cid=%ld", [updatedClass getName], (long)[updatedClass getId]];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
}


- (void)editReinforcer:(reinforcer *)updatedReinforcer{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Reinforcer SET name=\"%@\" WHERE id=%ld", [updatedReinforcer getName], (long)[updatedReinforcer getId]];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) //NSLog(@"We edited a reinforcer");
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
}


- (void)editItem:(item *)updatedItem{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Item SET name=\"%@\", cost=%ld WHERE id=%ld", [updatedItem getName], (long)[updatedItem getCost], (long)[updatedItem getId]];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}


- (void)registerStudent:(NSInteger)sid :(NSString *)serial{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Student SET serial=\"%@\" WHERE id=%ld", serial, (long)sid];
        NSLog(@"Register student -> %@", querySQL);
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"We edited a student");
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
}

- (void)unregisterStudent:(NSInteger)sid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Student SET serial=\"\" WHERE id=%ld", (long)sid];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
}


- (void)updateStudent:(student *)updatedStudent{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Student SET firstname=\"%@\", lastname=\"%@\", progress=%ld, lvlupamount=%ld, lvl=%ld, points=%ld, totalpoints=%ld WHERE id=%ld", [updatedStudent getFirstName], [updatedStudent getLastName], (long)[updatedStudent getProgress], (long)[updatedStudent getLvlUpAmount], (long)[updatedStudent getLvl], (long)[updatedStudent getPoints], (long)[updatedStudent getTotalPoints], (long)[updatedStudent getId]];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE) NSLog(@"We updated a student");
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
}


- (void)updateClassJar:(classjar *)updatedClassJar{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE ClassJar SET name=\"%@\", progress=%ld, total=%ld,  WHERE id=%ld", [updatedClassJar getName], (long)[updatedClassJar getProgress], (long)[updatedClassJar getTotal], (long)[updatedClassJar getId]];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"We edited a class jar");
            sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
}


- (void)rewardAllStudentsInClassWithid:(NSInteger)classId{
    NSMutableArray *resultArray = [self getStudents:classId];
    for (student *student in resultArray){
        NSLog(@"IN DB AND IN STUDENT ARRAY");
        [student addPoints:1];
        [self updateStudent:student];
    }
}


#pragma mark - Delete


- (void)deleteClass:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM Class where id=%ld", (long)cid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"We delete a class");
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
}


- (void)deleteStudent:(NSInteger)sid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM Student where id=%ld", (long)sid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"We delete a student");
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
}


- (void)deleteReinforcer:(NSInteger)rid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM Reinforcer where id=%ld", (long)rid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"We delete a reinforcer");
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
}


- (void)deleteItem:(NSInteger)iid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM Item where id=%ld", (long)iid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"We delete a item");
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
}


- (void)resetDatabase{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *deleteClass = [NSString stringWithFormat:
                                 @"DELETE FROM Class"];
        const char *delete_stmt = [deleteClass UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        NSString *deleteStudent = [NSString stringWithFormat:
                                   @"DELETE FROM Student"];
        const char *delete_stmt1 = [deleteStudent UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt1, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        
        NSString *deleteItem = [NSString stringWithFormat:
                                @"DELETE FROM Item"];
        const char *delete_stmt2 = [deleteItem UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt2, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        
        NSString *deleteJar = [NSString stringWithFormat:
                               @"DELETE FROM ClassJar"];
        const char *delete_stmt3 = [deleteJar UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt3, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        NSString *deletePoints = [NSString stringWithFormat:
                                  @"DELETE FROM Point"];
        const char *delete_stmt4 = [deletePoints UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt4, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        NSString *deleteTransactions = [NSString stringWithFormat:
                                        @"DELETE FROM Transactions"];
        const char *delete_stmt5 = [deleteTransactions UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt5, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        NSString *deleteStudentTimestamp = [NSString stringWithFormat:
                                            @"DELETE FROM StudentTimestamp"];
        const char *delete_stmt6 = [deleteStudentTimestamp UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt6, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        
        NSString *deleteStudentClassMatch = [NSString stringWithFormat:
                                             @"DELETE FROM StudentClassMatch"];
        const char *delete_stmt7 = [deleteStudentClassMatch UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt7, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        NSString *deleteStudents = [NSString stringWithFormat:
                                    @"DELETE FROM Student"];
        const char *delete_stmt8 = [deleteStudents UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt8, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
        
        NSString *deleteReinforcers = [NSString stringWithFormat:
                                       @"DELETE FROM Reinforcer"];
        const char *delete_stmt9 = [deleteReinforcers UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               delete_stmt9, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(database);
}


#pragma mark - Misc

// Teachers can only award points to students in the school of their current class.
// Check to see if student who stamped is in school for current class.
- (bool) isValidStamp:(NSString *)serial :(NSInteger)schoolId{
    student *currentStudent = [self getStudentWithSerial:serial];
    if (currentStudent != nil){
        NSMutableArray *schoolIds = [self getSchoolIdsWithstudentId:[currentStudent getId]];
        for (NSNumber *schoolNumber in schoolIds){
            if (schoolNumber.integerValue == schoolId){
                return YES;
            }
        }
    }
    else {
        return NO;
    }
    return NO;
}


- (bool)isSerialRegistered:(NSString *)serial{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT id FROM Student WHERE serial=\"%@\"", serial];
        
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_ROW){
            sqlite3_reset(statement);
            sqlite3_close(database);
            return YES;
        }
        return NO;
    }
    sqlite3_close(database);
    return NO;
}


- (bool)doesClassNameExist:(NSString *)className{
    currentUser = [user getInstance];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Class where name=\"%@\"", className];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                sqlite3_reset(statement);
                sqlite3_close(database);
                return YES;
            }
            else {
                sqlite3_reset(statement);
                sqlite3_close(database);
                return NO;
            }
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return NO;
}


@end
