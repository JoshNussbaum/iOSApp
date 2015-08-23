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

-(BOOL)createDatabase{
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
            "DROP TABLE IF EXISTS StudentTimestamp;"
            "DROP TABLE IF EXISTS StudentClassMatch;"
            "CREATE TABLE School (id integer primary key, name text);"
            "CREATE TABLE Class (id integer primary key, name text, grade integer, schoolid integer, level integer, progress integer, nextlevel integer, hasstamps integer);"
            "CREATE TABLE Student (id integer primary key, firstname text, lastname text, serial text, timestamp text, lvl integer, lvlupamount integer, lvlsgained integer, points integer, pointsgained integer, pointsspent integer, totalpoints integer, progress integer, progressgained integer);"
            "CREATE TABLE Reinforcer (id integer primary key, cid integer, name text);"
            "CREATE TABLE Item (id integer primary key, cid integer, name text, cost integer);"
            "CREATE TABLE ClassJar (id integer primary key, cid integer, name text, progress integer, total integer);"
            "CREATE TABLE Point (id integer, cid integer, timestamp text);"
            "CREATE TABLE Transactions (id integer, iid integer, timestamp text);"
            "CREATE TABLE StudentTimestamp (id integer primary key, timestamp text);"
            "CREATE TABLE StudentClassMatch (sid integer, cid integer);";
            
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

-(void) addClass:(class *)cl{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //            "CREATE TABLE Class (id integer primary key, name text, grade integer, schoolid integer, level integer, progress integer, nextlevel integer, hasstamps integer);"

        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Class (id, name, grade, schoolid, level, progress, nextlevel, hasstamps) VALUES (%ld, \"%@\", %ld, %ld, %ld, %ld, %ld, %ld)", (long)[cl getId], [cl getName], (long)[cl getGradeNumber], (long)[cl getSchoolId], (long)[cl getLevel], (long)[cl getProgress], (long)[cl getNextLevel], (long)[cl getHasStamps]];
        
        NSLog(@"Add Class Query SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A CLASS");
            sqlite3_finalize(statement);
        }
        
    }
    sqlite3_close(database);
}

-(void)addStudent:(student *)ss :(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Student (id, firstname, lastname, serial, lvl, lvlupamount, lvlsgained, points, pointsgained, pointsspent, progress, progressgained, timestamp) VALUES (%ld, \"%@\", \"%@\", \"%@\", %ld, %ld, %ld, %ld, %ld, %ld, %ld, %ld, %ld, \"%@\")", (long)[ss getId], [ss getFirstName], [ss getLastName], [ss getSerial], (long)[ss getLvl], (long)[ss getLvlUpAmount], (long)[ss getLvlsGained], (long)[ss getPoints], (long)[ss getPointsGained], (long)[ss getPointsSpent], (long)[ss getTotalPoints], (long)[ss getProgress], (long)[ss getProgressGained], [ss getTimestamp]];
        
        NSLog(@"Add Student Query SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A STUDENT");
        sqlite3_finalize(statement);
        
        NSString *querySQL2 = [NSString stringWithFormat:
                               @"INSERT INTO StudentClassMatch (sid, cid) VALUES (%ld, %ld)", (long)[ss getId], (long)cid];
        
        NSLog(@"Add Student Query SQL -> %@", querySQL2);
        const char *query_stmt2 = [querySQL2 UTF8String];
        sqlite3_prepare_v2(database, query_stmt2,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A STUDENT CLASS MATCH");
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}

-(void) addStudentToClass:(NSInteger)studentId :(NSInteger)classId{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO StudentClassMatch (sid, cid) VALUES (%ld, %ld)", (long)studentId, (long)classId];
        
        NSLog(@"Add Student to Class Query SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A STUDENT-CLASS MATCH");
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}

-(void)addReinforcer:(reinforcer *)rr{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Reinforcer (id, cid, name) VALUES (%ld, %ld, \"%@\")", (long)[rr getId], (long)[rr getCid], [rr getName]];
        
        NSLog(@"Add Reinforcer to QUERY SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A REINFORCER");
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}

-(void)addItem:(item *)ii{
    sqlite3_stmt *statement;

    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Item (id, cid, name, cost) VALUES (%ld, %ld, \"%@\", %ld)", (long)[ii getId], (long)[ii getCid], [ii getName], (long)[ii getCost]];
        NSLog(@"Add Item to QUERY SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED AN ITEM");
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}

-(void)addClassJar:(classjar *)cj{
    sqlite3_stmt *statement;

    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO ClassJar (id, cid, name, progress, total) VALUES (%ld, %ld, \"%@\", %ld, %ld)", (long)[cj getId], (long)[cj getCid], [cj getName], (long)[cj getProgress], (long)[cj getTotal]];
        NSLog(@"Add ClassJar to QUERY SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A CLASSJAR");
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}

-(void)addSchools:(NSMutableArray *)schools{
    // Set Categories
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        for (NSDictionary *school in schools)
        {
            // Category Attributes in Order
            NSInteger schoolId = [school[@"id"] intValue];
            NSString *schoolName = school[@"name"];
            
            NSString *querySQL = [NSString stringWithFormat:
                                  @"Insert INTO School (id, name) VALUES (%ld,\"%@\")", (long)schoolId, schoolName];
            const char *query_stmt = [querySQL UTF8String];
            sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A SCHOOL");
            sqlite3_finalize(statement);
            
        }
    }
    sqlite3_close(database);
}

-(void) login:(NSDictionary *)loginInfo{
    currentUser = [user getInstance];
    NSLog(@"Login info->%@", loginInfo);
    
    NSMutableArray *classes = [loginInfo objectForKey:@"classes"];
    NSMutableArray *schools = [loginInfo objectForKey:@"schools"];
    
    if (classes.count > 0){
        currentUser.currentClassId = [[[classes objectAtIndex:0] objectForKey:@"cid"]integerValue];
    }
    else {
        currentUser.currentClassId = 0;
    }
    
    
    [self addSchools:schools];
        
    for (NSDictionary *classDictionary in classes){
        NSInteger cid = [classDictionary[@"cid"]integerValue];
        NSString *className = classDictionary[@"name"];
        NSInteger progress = [classDictionary[@"classProgress"]integerValue];
        NSInteger grade = [classDictionary[@"grade"]integerValue];
        NSInteger nextLevel = [classDictionary[@"grade"]integerValue];
        NSInteger level = [classDictionary[@"classLvl"]integerValue];
        NSInteger hasStamps = [classDictionary[@"hasStamps"]integerValue];
        NSInteger schoolId = [classDictionary[@"schoolId"]integerValue];
        
        
        class *newClass = [[class alloc] init:cid :className :grade :schoolId :level :progress :nextLevel :hasStamps];
        [self addClass:newClass];
        

        
        NSMutableArray *students = [classDictionary objectForKey:@"students"];
        for (NSDictionary *studentDictionary in students){
            NSInteger sid = [[studentDictionary objectForKey:@"uid"]integerValue];
            NSString *fname = [studentDictionary objectForKey:@"fname"];
            NSString *lname = [studentDictionary objectForKey:@"lname"];
            NSString *serial = [studentDictionary objectForKey:@"serial"];
            NSInteger currentCoins = [[studentDictionary objectForKey:@"currentCoins"]integerValue];
            NSInteger lvl = [[studentDictionary objectForKey:@"lvl"]integerValue];
            NSInteger lvlUpAmount = 10 + 5*lvl;
            NSInteger progress = [[studentDictionary objectForKey:@"progress"]integerValue];
            NSInteger totalCoins = [[studentDictionary objectForKey:@"totalCoins"]integerValue];
            
            student *newStudent = [[student alloc] init:sid :fname :lname :serial :lvl :lvlUpAmount :0 :currentCoins :0 :0  :totalCoins :progress :0 :[Utilities getDate]];
            [self addStudent:newStudent :cid];
            
        }
        NSMutableArray *reinforcers = [classDictionary objectForKey:@"reinforcers"];

        for (NSDictionary *reinforcerDictionary in reinforcers){
            NSInteger rid = [[reinforcerDictionary objectForKey:@"rid"]integerValue ];
            NSString *name = [reinforcerDictionary objectForKey:@"name"];
            reinforcer *newReinforcer = [[reinforcer alloc] init:rid :cid :name];
            [self addReinforcer:newReinforcer];
        }
       
        NSMutableArray *items = [classDictionary objectForKey:@"items"];
        for (NSDictionary *itemDictionary in items){
            NSInteger iid = [[itemDictionary objectForKey:@"rid"]integerValue ];
            NSInteger cid = [[itemDictionary objectForKey:@"cid"]integerValue ];
            NSString *name = [itemDictionary objectForKey:@"name"];
            NSInteger cost = [[itemDictionary objectForKey:@"cost"]integerValue ];
            item *newItem = [[item alloc] init:iid :cid :name :cost];
            [self addItem:newItem];
        }
        
        NSDictionary *classJarDictionary = [classDictionary objectForKey:@"classjar"];
        NSInteger jid = [[classJarDictionary objectForKey:@"jid"]integerValue];
        NSString *name = [classJarDictionary objectForKey:@"name"];
        NSInteger jarProgress = [[classJarDictionary objectForKey:@"progress"]integerValue];
        NSInteger total = [[classJarDictionary objectForKey:@"total"]integerValue ];

        classjar *newJar = [[classjar alloc]init:jid :cid :name :jarProgress :total];
        [self addClassJar:newJar];
        
        
    }
}


#pragma mark - Read


-(NSMutableArray *)getClasses{
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
                
                NSInteger progress = sqlite3_column_int(statement, 7);
                
                NSInteger nextlevel = sqlite3_column_int(statement, 8);
                
                NSInteger hasstamps = sqlite3_column_int(statement, 9);
                
                class *cc = [[class alloc]init:id :name :grade :schoolid :level :progress :nextlevel :hasstamps];
                [resultArray addObject:cc];
                
            }
            NSLog(@"HERE ARE ALL THE CLASSES => %@", resultArray);
            sqlite3_reset(statement);
            sqlite3_close(database);
            return resultArray;
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}

-(NSMutableArray *)getStudents:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM Students where cid=%ld", (long)cid];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {

                NSInteger id = sqlite3_column_int(statement, 0);
                
                NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                
                NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
               
                NSString *serial = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                
                NSInteger lvl = sqlite3_column_int(statement, 4);
                
                NSInteger lvlupamount = sqlite3_column_int(statement, 5);
                
                NSInteger lvlsgained = sqlite3_column_int(statement, 6);
                
                NSInteger points = sqlite3_column_int(statement, 7);
                
                NSInteger pointsgained = sqlite3_column_int(statement, 8);
                
                NSInteger pointsspent = sqlite3_column_int(statement, 9);
                
                NSInteger totalpoints = sqlite3_column_int(statement, 10);
                
                NSInteger progress = sqlite3_column_int(statement, 11);
                
                NSInteger progressgained = sqlite3_column_int(statement, 12);
                
                NSString *timestamp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 13)];
                
                student *ss = [[student alloc] init:id :firstName :lastName :serial :lvl :lvlupamount :lvlsgained :points :pointsgained :pointsspent :totalpoints :progress :progressgained :timestamp];

                [resultArray addObject:ss];
                
            }
            [resultArray sortUsingDescriptors:
             [NSArray arrayWithObjects:
              [NSSortDescriptor sortDescriptorWithKey:@"lvl" ascending:NO],
              [NSSortDescriptor sortDescriptorWithKey:@"progress" ascending:NO],
              [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO], nil]];
            
            sqlite3_reset(statement);
            sqlite3_close(database);
            return resultArray;
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}

-(NSMutableArray *)getUnregisteredStudents:(NSInteger)cid{
    currentUser = [user getInstance];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM Students where serial='' and cid=%ld", (long)cid];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSInteger id = sqlite3_column_int(statement, 0);
                
                NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                
                NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];

                NSString *serial = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                
                NSInteger lvl = sqlite3_column_int(statement, 4);
                
                NSInteger lvlupamount = sqlite3_column_int(statement, 5);
                
                NSInteger points = sqlite3_column_int(statement, 6);
                
                NSInteger progress = sqlite3_column_int(statement, 9);
                
                NSInteger totalpoints = sqlite3_column_int(statement, 10);
                
                NSString *timestamp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 13)];
                
                student *ss = [[student alloc] init:id :firstName :lastName :serial :lvl :lvlupamount :0 :points :0 :0 :totalpoints :progress :0 :timestamp];
                
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

-(NSMutableArray *)getReinforcers:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * from Categories where cid=%ld", (long)cid];
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
                
                reinforcer *rr = [[reinforcer alloc] init:id :cid :name];
                
                [resultArray addObject:rr];
                
            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            NSMutableArray *reversed = [[[resultArray reverseObjectEnumerator]allObjects]mutableCopy];
            return reversed;
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}

-(NSMutableArray *)getItems:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * from Items where cid=%ld", (long)cid];
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
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}

-(classjar *)getClassJar:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM ClassJar where cid=%ld", (long)cid];
        
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        while (sqlite3_step(statement) == SQLITE_ROW){
            
            NSInteger id = sqlite3_column_int(statement, 0);
            
            NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            NSInteger progress = sqlite3_column_int(statement, 2);
            
            NSInteger total = sqlite3_column_int(statement, 3);
            
            classjar *cj = [[classjar alloc] init:id :cid :name :progress :total];
            
            sqlite3_reset(statement);
            
            return cj;
        }
    }
    return nil;
}

-(student *)getStudentWithSerial:(NSString *)serial{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * from Students WHERE serial=\"%@\"", serial];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            
            NSInteger id = sqlite3_column_int(statement, 0);
            
            NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            
            NSString *serial = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            
            NSInteger lvl = sqlite3_column_int(statement, 4);
            
            NSInteger lvlupamount = sqlite3_column_int(statement, 5);
            
            NSInteger lvlsgained = sqlite3_column_int(statement, 6);
            
            NSInteger points = sqlite3_column_int(statement, 7);
            
            NSInteger pointsgained = sqlite3_column_int(statement, 8);
            
            NSInteger pointsspent = sqlite3_column_int(statement, 9);
            
            NSInteger totalpoints = sqlite3_column_int(statement, 10);
            
            NSInteger progress = sqlite3_column_int(statement, 11);
            
            NSInteger progressgained = sqlite3_column_int(statement, 12);
            
            NSString *timestamp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 13)];
            
            student *ss = [[student alloc] init:id :firstName :lastName :serial :lvl :lvlupamount :lvlsgained :points :pointsgained :pointsspent :totalpoints :progress :progressgained :timestamp];
            
            sqlite3_reset(statement);
            sqlite3_close(database);
            return (ss);
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}

-(student *)getStudentWithID:(NSInteger)sid{
    return nil;
}

-(NSMutableArray *)getSchools{
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

-(NSString *)getSchoolName:(NSInteger)sid{
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
                NSLog(@"FOUND SCHOOL %@", name);
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

-(NSInteger)getNumberOfStudentsInClass:(NSInteger)cid{
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
                NSLog(@"Student count is %ld for class %ld", (long)studentCount, (long)cid);

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

-(NSMutableDictionary *)getNumberOfStudentsInClasses:(NSMutableArray *)classIds{
    NSMutableDictionary *numberOfStudentsByClassId = [[NSMutableDictionary alloc]init];
    for (NSNumber *classId in classIds){
        NSLog(@"Class ID => %@", classId);
        NSInteger cid = [classId integerValue];
        NSLog(@"On class id %d", cid);
        NSInteger numberOfStudents = [self getNumberOfStudentsInClass:[classId integerValue]];
        NSNumber *numOfStudents = [NSNumber numberWithInteger:numberOfStudents];
        [numberOfStudentsByClassId setObject:numOfStudents forKey:classId];
        
    }
    NSLog(@"Here is the dictionary of student numbers by class ids : %@", numberOfStudentsByClassId);
    return numberOfStudentsByClassId;
}


#pragma mark - Update

-(void)editClass:(class *)updatedClass{
    

}


// Misc Functions
-(void)resetDatabase{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
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

-(bool)doesClassNameExist:(NSString *)className{
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

#pragma mark - Delete

-(void)deleteClass:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM Class where id=%ld", (long)cid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@"we deleted class with id %d", cid);
            }
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
}



@end
