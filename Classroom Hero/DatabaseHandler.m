//
//  DatabaseHandler.m
//  Classroom Hero
//
//  Created by Josh on 7/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "DatabaseHandler.h"
#import <sqlite3.h>


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
            "DROP TABLE IF EXISTS Class;"
            "DROP TABLE IF EXISTS Student;"
            "DROP TABLE IF EXISTS Reinforcer;"
            "DROP TABLE IF EXISTS Item;"
            "DROP TABLE IF EXISTS ClassJar;"
            "DROP TABLE IF EXISTS Point;"
            "DROP TABLE IF EXISTS Transactions;"
            "DROP TABLE IF EXISTS StudentTimestamp;"
            "DROP TABLE IF EXISTS StudentClassMatch;"
            "CREATE TABLE Class (id integer primary key, name text, grade integer, schoolid integer, level integer, progress integer, nextlevel integer, hasstamps integer);"
            "CREATE TABLE Student (id integer primary key, firstname text, lastname text, serial text, timestamp text, lvl integer, lvlupamount integer, lvlsgained integer, points integer, pointsgained integer, pointsspent integer, progress integer, progressgained integer);"
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

// Create Functions
-(void) addClass:(class *)cl{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //            "CREATE TABLE Class (id integer primary key, name text, grade integer, schoolid integer, level integer, progress integer, nextlevel integer, hasstamps integer);"

        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Class (id, name, grade, schoolid, level, progress, nextlevel, hasstamps) VALUES (%d, \"%@\", %d, %d, %d, %d, %d, %d)", [cl getId], [cl getName], [cl getGradeNumber], [cl getSchoolId], [cl getLevel], [cl getProgress], [cl getNextLevel], [cl getHasStamps]];
        
        NSLog(@"Add Class Query SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"IN HURRR");
            
            if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A CLASS");
            sqlite3_finalize(statement);
        }
        
    }
    sqlite3_close(database);
}

-(void)addStudent:(student *)ss{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Student (id, firstname, lastname, serial, lvl, lvlupamount, lvlsgained, points, pointsgained, pointsspent, progress, progressgained, timestamp) VALUES (%d, \"%@\", \"%@\", \"%@\", %d, %d, %d, %d, %d, %d, %d, %d, \"%@\")", [ss getId], [ss getFirstName], [ss getLastName], [ss getSerial], [ss getLvl], [ss getLvlUpAmount], [ss getLvlsGained], [ss getPoints], [ss getPointsGained], [ss getPointsSpent], [ss getProgress], [ss getProgressGained], [ss getTimestamp]];
        
        NSLog(@"Add Student Query SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A STUDENT");
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}

-(void) addStudentToClass:(NSInteger)studentId :(NSInteger)classId{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO StudentClassMatch (sid, cid) VALUES (%d, %d)", studentId, classId];
        
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
                              @"REPLACE INTO Reinforcer (id, cid, name) VALUES (%d, %d, \"%@\")", [rr getId], [rr getCid], [rr getName]];
        
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
                              @"REPLACE INTO Item (id, cid, name, cost) VALUES (%d, %d, \"%@\", %d)", [ii getId], [ii getCid], [ii getName], [ii getCost]];
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
                              @"REPLACE INTO ClassJar (id, cid, name, progress, total) VALUES (%d, %d, \"%@\", %d, %d)", [cj getId], [cj getCid], [cj getName], [cj getProgress], [cj getTotal]];
        NSLog(@"Add ClassJar to QUERY SQL -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"DOPE WE ADDED A CLASSJAR");
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
}

-(NSMutableArray *)getStudents:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM Students where cid=%d", cid];
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
                
                NSInteger progress = sqlite3_column_int(statement, 10);
                
                NSInteger progressgained = sqlite3_column_int(statement, 11);
                
                NSString *timestamp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
                
                student *ss = [[student alloc] init:id :firstName :lastName :serial :lvl :lvlupamount :lvlsgained :points :pointsgained :pointsspent :progress :progressgained :timestamp];

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
    return nil;
}

-(NSMutableArray *)getUnregisteredStudents:(NSInteger)cid{
    currentUser = [user getInstance];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM Students where serial='' and cid=%d", cid];
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
                
                NSString *timestamp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
                
                student *ss = [[student alloc] init:id :firstName :lastName :serial :lvl :lvlupamount :0 :points :0 :0 :progress :0 :timestamp];
                
                [resultArray addObject:ss];
                
            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            return resultArray;
        }
    }
    return nil;
}

-(NSMutableArray *)getReinforcers:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * from Categories where cid=%d", cid];
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
                              @"SELECT * from Items where cid=%d", cid];
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
            return reversed;            }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
    return nil;
}

//-(id)init:(NSInteger)id_ :(NSInteger)cid_ :(NSString *)name_ :(NSInteger)progress_ :(NSInteger)total_;

-(classjar *)getClassJar:(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM ClassJar where cid=%d", cid];
        
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
        //            "CREATE TABLE Student (id integer primary key, firstname text, lastname text, serial text,timestamp text, lvl integer, lvlupamount integer, lvlsgained integer, points integer, pointsgained integer, pointsspent integer, progress integer, progressgained integer);"

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
            
            NSInteger progress = sqlite3_column_int(statement, 10);
            
            NSInteger progressgained = sqlite3_column_int(statement, 11);
            
            NSString *timestamp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)];
            
            student *ss = [[student alloc] init:id :firstName :lastName :serial :lvl :lvlupamount :lvlsgained :points :pointsgained :pointsspent :progress :progressgained :timestamp];
            
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



// Misc Functions
-(bool)doesClassNameExist:(NSString *)className{
    currentUser = [user getInstance];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Class where name=\"%@\"", className];
        NSLog(@"Does class name exist query -> %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"In hereee");
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSLog(@"GONNA RETURN YES");
                sqlite3_reset(statement);
                sqlite3_close(database);
                return YES;
            }
            else {
                NSLog(@"GONNA RETURN NO");

                sqlite3_reset(statement);
                sqlite3_close(database);
                return NO;
            }
            
        }
    }
    NSLog(@"COULDNT OPEN UP");

    sqlite3_reset(statement);
    sqlite3_close(database);
    return NO;
}



@end
