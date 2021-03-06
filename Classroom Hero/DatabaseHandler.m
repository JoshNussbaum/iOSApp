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
        "DROP TABLE IF EXISTS StudentSchoolMatch;"
        "CREATE TABLE Class (id integer primary key, name text, grade text, level integer, progress integer, currentday text, hash text);"
        "CREATE TABLE Student (id integer primary key, firstname text, lastname text, lvl integer, progress integer, lvlupamount integer, points integer, totalpoints integer, checkedin integer, hash text);"
        "CREATE TABLE Reinforcer (id integer primary key, cid integer, name text, value integer);"
        "CREATE TABLE Item (id integer primary key, cid integer, name text, cost integer);"
        "CREATE TABLE ClassJar (id integer primary key, cid integer, name text, progress integer, total integer);"
        "CREATE TABLE Point (id integer, cid integer, timestamp text);"
        "CREATE TABLE Transactions (id integer, iid integer, timestamp text);"
        "CREATE TABLE StudentClassMatch (sid integer, cid integer);";
        
        if (sqlite3_exec(database, create_tables, NULL, NULL, &errMsg) == SQLITE_OK)
        {
            sqlite3_close(database);
            return  isSuccess;
        }
        else
        {
            isSuccess = NO;
        }

    }
    else {
        isSuccess = NO;
    }

    sqlite3_close(database);
    return isSuccess;
}


#pragma mark - Create


- (void) addClass:(class *)cl{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //        "CREATE TABLE Class (id integer primary key, name text, grade integer, level integer, progress integer, currentday text);"

        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Class (id, name, grade, level, progress, currentday, hash) VALUES (%ld, \"%@\", \"%@\", %ld, %ld, \"%@\", \"%@\")", (long)[cl getId], [cl getName], [cl getGradeNumber], (long)[cl getLevel], (long)[cl getProgress], [cl getCurrentDate], [cl getHash]];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }

    }
    sqlite3_close(database);
}


- (void) addStudent:(student *)ss :(NSInteger)cid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"REPLACE INTO Student (id, firstname, lastname, lvl, progress, lvlupamount, points, totalpoints, checkedin, hash) VALUES (%ld, \"%@\", \"%@\", %ld, %ld, %ld, %ld, %ld, %ld, \"%@\")", (long)[ss getId], [ss getFirstName], [ss getLastName], (long)[ss getLvl], (long)[ss getProgress], (long)[ss getLvlUpAmount], (long)[ss getPoints], (long)[ss getTotalPoints], (long)([ss getCheckedIn] ? 1 : 0), [ss getHash]];

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


- (void) login:(NSDictionary *)loginInfo{
    currentUser = [user getInstance];
    NSMutableArray *classes = [loginInfo objectForKey:@"classes"];

    if (classes.count == 0){
        currentUser.currentClass = [[class alloc]init];
        [currentUser.currentClass setId:0];
    }

    for (NSInteger i=0; i< classes.count; i++){
        NSDictionary *classDictionary = [classes objectAtIndex:i];
        NSInteger cid = [classDictionary[@"class_id"]integerValue];
        NSString *className = classDictionary[@"name"];
        NSInteger progress = [classDictionary[@"progress"]integerValue];
        NSString *grade = classDictionary[@"grade"];
        NSInteger level = [classDictionary[@"level"]integerValue];
        NSString *classHash = classDictionary[@"class_hash"];
        NSInteger nextLevel = level * 6;

        class *newClass = [[class alloc] init:cid :className :grade :level :progress :nextLevel :[Utilities getCurrentDate] :classHash];
        if (i == 0) currentUser.currentClass = newClass;
        [self addClass:newClass];


        NSMutableArray *students = [classDictionary objectForKey:@"students"];
        for (NSDictionary *studentDictionary in students){
            NSInteger sid = [[studentDictionary objectForKey:@"student_id"]integerValue];
            NSString *fname = [studentDictionary objectForKey:@"first_name"];
            NSString *lname = [studentDictionary objectForKey:@"last_name"];
            BOOL checkedIn = [[studentDictionary objectForKey:@"checked_in"]boolValue];
            NSString *studentHash = [studentDictionary objectForKey:@"student_hash"];
            NSInteger currentCoins = [[studentDictionary objectForKey:@"current_coins"]integerValue];
            NSInteger lvl = [[studentDictionary objectForKey:@"level"]integerValue];
            NSInteger lvlUpAmount = 3 * lvl;
            NSInteger progress = [[studentDictionary objectForKey:@"progress"]integerValue];
            NSInteger totalCoins = [[studentDictionary objectForKey:@"total_coins"]integerValue];

            student *newStudent = [[student alloc] initWithid:sid firstName:fname lastName:lname lvl:lvl progress:progress lvlupamount:lvlUpAmount points:currentCoins totalpoints:totalCoins checkedin:checkedIn hash:studentHash];
            [self addStudent:newStudent :cid];

        }
        NSMutableArray *reinforcers = [classDictionary objectForKey:@"reinforcers"];

        for (NSDictionary *reinforcerDictionary in reinforcers){
            NSInteger rid = [[reinforcerDictionary objectForKey:@"reinforcer_id"]integerValue];
            NSString *name = [reinforcerDictionary objectForKey:@"name"];
            NSInteger value = [[reinforcerDictionary objectForKey:@"value"]integerValue ];

            reinforcer *newReinforcer = [[reinforcer alloc] init:rid :cid :name :value];
            [self addReinforcer:newReinforcer];
        }

        NSMutableArray *items = [classDictionary objectForKey:@"items"];
        for (NSDictionary *itemDictionary in items){
            NSInteger iid = [[itemDictionary objectForKey:@"item_id"]integerValue ];
            NSString *name = [itemDictionary objectForKey:@"name"];
            NSInteger cost = [[itemDictionary objectForKey:@"cost"]integerValue ];
            item *newItem = [[item alloc] init:iid :cid :name :cost];
            [self addItem:newItem];
        }
        NSMutableArray *jars = [classDictionary objectForKey:@"jars"];
        for (NSDictionary *classJarDictionary in jars){
            NSInteger jid = [[classJarDictionary objectForKey:@"jar_id"]integerValue];
            NSString *name = [classJarDictionary objectForKey:@"name"];
            NSInteger jarProgress = [[classJarDictionary objectForKey:@"progress"]integerValue];
            NSInteger total = [[classJarDictionary objectForKey:@"total"]integerValue ];

            classjar *newJar = [[classjar alloc] initWithid:jid cid:cid name:name progress:jarProgress total:total];

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
                
                NSString *grade = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                
                NSInteger level = sqlite3_column_int(statement, 3);
                
                NSInteger progress = sqlite3_column_int(statement, 4);
                
                NSString *date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                
                NSString *hash = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];

                class *cc = [[class alloc]init:id :name :grade :level :progress :level*6 :date :hash];
                
                [resultArray addObject:cc];

            }
            sqlite3_reset(statement);
            sqlite3_close(database);
            return resultArray;
            //NSMutableArray *reversed = [[[resultArray reverseObjectEnumerator]allObjects]mutableCopy];
            //return reversed;
        }
    }
    sqlite3_close(database);
    return nil;
}


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

                NSString *grade = [NSString stringWithUTF8String:(char *)sqlite3_column_int(statement, 2)];

                NSInteger level = sqlite3_column_int(statement, 3);

                NSInteger progress = sqlite3_column_int(statement, 4);

                NSString *date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                
                NSString *hash = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];

                foundClass = [[class alloc]init:id :name :grade :level :progress :level*6 :date :hash];

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


- (NSMutableArray *)getStudents:(NSInteger)cid :(BOOL)attendance studentIds:(NSMutableArray *)studentIds{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSMutableArray *allStudents = [[NSMutableArray alloc]init];
        for (NSNumber *studentId in studentIds){
            NSInteger sid = [studentId integerValue];
            NSString *getStudentsQuery = [NSString stringWithFormat:@"SELECT id, firstname, lastname, lvl, progress, lvlupamount, points, totalpoints, checkedin, hash FROM Student WHERE id=%ld", (long)sid];
            const char *query_stmt = [getStudentsQuery UTF8String];

            if (sqlite3_prepare_v2(database,
                                   query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSInteger id = sqlite3_column_int(statement, 0);

                    NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];

                    NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];

                    NSInteger level = sqlite3_column_int(statement, 3);

                    NSInteger progress = sqlite3_column_int(statement, 4);

                    NSInteger levelUpAmount = sqlite3_column_int(statement, 5);

                    NSInteger points = sqlite3_column_int(statement, 6);

                    NSInteger totalPoints = sqlite3_column_int(statement, 7);

                    NSInteger checkedIn = sqlite3_column_int(statement, 8);
                    
                    NSString *hash = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];

                    student *ss = [[student alloc] initWithid:id firstName:firstName lastName:lastName lvl:level progress:progress lvlupamount:levelUpAmount points:points totalpoints:totalPoints checkedin:(checkedIn==1 ? YES : NO) hash:hash];
                    [allStudents addObject:ss];

                    sqlite3_finalize(statement);

                }
            }
        }
        if (attendance){
            [allStudents sortUsingDescriptors:
             [NSArray arrayWithObjects:
              [NSSortDescriptor sortDescriptorWithKey:@"checkedin" ascending:NO],
              [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:NO],
              [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:NO], nil]
             ];
        }
        else {
            [allStudents sortUsingDescriptors:
             [NSArray arrayWithObjects:
              [NSSortDescriptor sortDescriptorWithKey:@"lvl" ascending:YES],
              [NSSortDescriptor sortDescriptorWithKey:@"progress" ascending:YES],
              [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:YES], nil]
             ];
        }

        //NSMutableArray *reversed = [[[allStudents reverseObjectEnumerator]allObjects]mutableCopy];

        sqlite3_close(database);
        return allStudents;
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


- (student *)getStudentWithID:(NSInteger)sid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * from Student WHERE id=%ld", (long)sid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW){
                @try {
                    NSInteger id = sqlite3_column_int(statement, 0);
                    
                    NSString *firstName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    
                    NSString *lastName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                    
                    NSInteger level = sqlite3_column_int(statement, 3);
                    
                    NSInteger progress = sqlite3_column_int(statement, 4);
                    
                    NSInteger levelUpAmount = sqlite3_column_int(statement, 5);
                    
                    NSInteger points = sqlite3_column_int(statement, 6);
                    
                    NSInteger totalPoints = sqlite3_column_int(statement, 7);
                    
                    NSInteger checkedIn = sqlite3_column_int(statement, 8);
                    
                    NSString *hash = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];

                    
                    student *ss = [[student alloc] initWithid:id firstName:firstName lastName:lastName lvl:level progress:progress lvlupamount:levelUpAmount points:points totalpoints:totalPoints checkedin:(checkedIn==1 ? YES : NO) hash:hash];

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



- (NSMutableDictionary *)getClassStats:(NSInteger)classId :(NSMutableArray *)studentIds{

// Get Total stamps by students progress


    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableArray *students = [self getStudents:classId :NO studentIds:studentIds];
    if (students.count > 0){
        NSInteger totalLevels = 0;
        NSInteger totalPoints = 0;
        for (student *student_ in students){
            totalPoints += [student_ getPoints];
            totalLevels += [student_ getLvl];
        }
        NSInteger averageLevel = totalLevels / [students count];
        NSInteger averagePoints = totalPoints / [students count];

        [stats setObject:[NSNumber numberWithInteger:averageLevel] forKey:@"averageLevel"];
        [stats setObject:[NSNumber numberWithInteger:averagePoints] forKey:@"averagePoints"];
        return stats;

    }
    return nil;

}


#pragma mark - Update


- (void)editClass:(class *)updatedClass{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //        "CREATE TABLE Class (id integer primary key, name text, grade integer, schoolid integer, level integer, progress integer, nextlevel integer, currentday text);"

        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Class SET name=\"%@\", grade=\"%@\", level=%ld, progress=%ld, currentday=\"%@\" WHERE id=%ld", [updatedClass getName], [updatedClass getGradeNumber], (long)[updatedClass getLevel], (long)[updatedClass getProgress], [updatedClass getCurrentDate], (long)[updatedClass getId]];
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
                              @"UPDATE Reinforcer SET name=\"%@\", value=%ld WHERE id=%ld", [updatedReinforcer getName], (long)[updatedReinforcer getValue], (long)[updatedReinforcer getId]];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        sqlite3_step(statement);
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


- (void)updateStudent:(student *)updatedStudent{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Student SET firstname=\"%@\", lastname=\"%@\", progress=%ld, lvlupamount=%ld, lvl=%ld, points=%ld, totalpoints=%ld, checkedin=%ld WHERE id=%ld", [updatedStudent getFirstName], [updatedStudent getLastName], (long)[updatedStudent getProgress], (long)[updatedStudent getLvlUpAmount], (long)[updatedStudent getLvl], (long)[updatedStudent getPoints], (long)[updatedStudent getTotalPoints], (long)([updatedStudent getCheckedIn] ? 1 : 0), (long)[updatedStudent getId]];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }

    sqlite3_close(database);
}



- (void)updateClassJar:(classjar *)updatedClassJar{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE ClassJar SET name=\"%@\", progress=%ld, total=%ld, cid=%ld WHERE id=%ld", [updatedClassJar getName], (long)[updatedClassJar getProgress], (long)[updatedClassJar getTotal], (long)[updatedClassJar getCid], (long)[updatedClassJar getId]];
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }

    sqlite3_close(database);
}


- (void)updateStudentCheckedIn:(NSInteger)studentId :(BOOL)checkedIn{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSInteger checkedIn_ = (checkedIn ? 1: 0);
        NSString *querySQL = [NSString stringWithFormat:
                              @"UPDATE Student SET checkedin=%ld WHERE id=%ld", (long)checkedIn_, (long)studentId];
         const char *update_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database,
                           update_stmt, -1, &statement, NULL);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }

    sqlite3_close(database);
}

- (void)updateAllStudentsCheckedInWithclassId:(NSInteger)classId checkedIn:(BOOL)checkedIn studentIds:(NSMutableArray *)studentIds{
    NSMutableArray *students = [self getStudents:classId :YES studentIds:studentIds];
    for (student *stud in students){
        [self updateStudentCheckedIn:[stud getId] :checkedIn];
    }
}


#pragma mark - Delete


- (void)deleteClass:(NSInteger)cid{
    [self deleteStudentClassMatches:cid];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM Class where id=%ld", (long)cid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);

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
            sqlite3_step(statement);
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
            sqlite3_step(statement);
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
            sqlite3_step(statement);

        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
}


- (void)deleteClassJar:(NSInteger)cjid{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM ClassJar where id=%ld", (long)cjid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
}


- (void)deleteStudentClassMatches:(NSInteger)classId{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM StudentClassMatch where cid=%ld", (long)classId];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);

        }
    }
    sqlite3_reset(statement);
    sqlite3_close(database);
}



- (void)resetDatabase{
    const char *dbpath = [databasePath UTF8String];
    /*
    if([[NSFileManager defaultManager] fileExistsAtPath:databasePath]){
        [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
    }
     */

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


        NSString *deleteStudentClassMatch = [NSString stringWithFormat:
                                             @"DELETE FROM StudentClassMatch"];
        const char *delete_stmt6 = [deleteStudentClassMatch UTF8String];

        if (sqlite3_prepare_v2(database,
                               delete_stmt6, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }

        NSString *deleteStudents = [NSString stringWithFormat:
                                    @"DELETE FROM Student"];
        const char *delete_stmt7 = [deleteStudents UTF8String];

        if (sqlite3_prepare_v2(database,
                               delete_stmt7, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }

        NSString *deleteReinforcers = [NSString stringWithFormat:
                                       @"DELETE FROM Reinforcer"];
        const char *delete_stmt8 = [deleteReinforcers UTF8String];

        if (sqlite3_prepare_v2(database,
                               delete_stmt8, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }

    }
    sqlite3_close(database);
}


#pragma mark - Misc


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


@end
