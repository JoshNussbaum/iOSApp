//
//  ConnectionHandler.m
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.


#import "ConnectionHandler.h"
#import "Utilities.h"

//http://107.206.158.62:1337/classroom-web-services/
//http://ehorvat.webfactional.com/apps/ch/
//http://107.206.158.62:1337/api/


static NSString * const CLASS_URL = @"http://107.206.158.62:1337/api/class/";
static NSString * const ADD_CLASS_URL = @"http://107.206.158.62:1337/api/class/create/";

static NSString * const LOGIN_URL = @"http://107.206.158.62:1337/api/users/login/";
static NSString * const CREATE_ACCOUNT_URL = @"http://107.206.158.62:1337/api/users/register/";

static NSString * const REINFORCER_URL = @"http://107.206.158.62:1337/api/class/";
static NSString * const ADD_REINFORCER_URL = @"http://107.206.158.62:1337/api/reinforcer/";
static NSString * const EDIT_REINFORCER_URL = @"http://107.206.158.62:1337/api/reinforcer/edit";
static NSString * const DELETE_REINFORCER_URL = @"http://107.206.158.62:1337/api/reinforcer/delete";

static NSString * const ITEM_URL = @"http://107.206.158.62:1337/api/item/";
static NSString * const ADD_ITEM_URL = @"http://107.206.158.62:1337/api/item/add";
static NSString * const EDIT_ITEM_URL = @"http://107.206.158.62:1337/api/item/edit";
static NSString * const DELETE_ITEM_URL = @"http://107.206.158.62:1337/api/item/delete";

static NSString * const JAR_URL = @"http://107.206.158.62:1337/api/jar/add";
static NSString * const ADD_JAR_URL = @"http://107.206.158.62:1337/api/jar/add";
static NSString * const EDIT_JAR_URL = @"http://107.206.158.62:1337/api/jar/edit";
static NSString * const DELETE_JAR_URL = @"http://107.206.158.62:1337/api/jar/delete";

static NSString * const STUDENT_URL = @"http://107.206.158.62:1337/api/student/";
static NSString * const ADD_STUDENT_URL = @"http://107.206.158.62:1337/api/class/";
static NSString * const EDIT_STUDENT_URL = @"http://107.206.158.62:1337/api/student/edit";
static NSString * const DELETE_STUDENT_URL = @"http://107.206.158.62:1337/api/student/delete";

static NSString * const REWARD_STUDENT_URL = @"http://107.206.158.62:1337/api/student/reward";
static NSString * const REWARD_STUDENT_BULK_URL = @"http://107.206.158.62:1337/api/student/reward/bulk";

static NSString * const CHECK_IN_STUDENT_URL = @"http://107.206.158.62:1337/api/student/checkin";
static NSString * const CHECK_OUT_STUDENT_URL = @"http://107.206.158.62:1337/api/student/checkout";
static NSString * const CHECK_IN_ALL_STUDENTS_URL = @"http://107.206.158.62:1337/api/class";
static NSString * const CHECK_OUT_ALL_STUDENTS_URL = @"http://107.206.158.62:1337/api/class";

static NSString * const STUDENT_TRANSACTION_URL = @"http://107.206.158.62:1337/api/student/transaction";

static NSString * const GET_SCHOOLS_URL = @"http://107.206.158.62:1337/api/schools/get";

static NSString * const REWARD_ALL_STUDENTS_URL = @"http://107.206.158.62:1337/api/class";

static NSString * const SUBTRACT_STUDENT_POINTS_URL = @"http://107.206.158.62:1337/api/student/subtractPoints";
static NSString * const STUDENT_ADD_POINTS_URL = @"http://107.206.158.62:1337/api/student/addPoints";


static NSString * const ADD_TO_JAR_URL = @"http://107.206.158.62:1337/api/jar/fill";

static NSString * const ORDER_URL = @"http://107.206.158.62:1337/api/register/order";

static NSString * const EDIT_TEACHER_NAME_URL = @"http://107.206.158.62:1337/api/user/settings/editName";
static NSString * const EDIT_TEACHER_PASSWORD_URL = @"http://107.206.158.62:1337/api/user/settings/changePassword";
static NSString * const RESET_PASSWORD_URL = @"http://107.206.158.62:1337/api/user/settings/recoverPassword";


static NSString * const GET_CLASS_STATS_URL = @"http://107.206.158.62:1337/api/class/stats";
static NSString * const UNREGISTER_ALL_STUDENTS_URL = @"http://107.206.158.62:1337/api/class";

static NSString *POST = @"POST";
static NSString *PUT = @"PUT";
static NSString *GET = @"GET";
static NSString *DELETE = @"DELETE";

static ConnectionHandler *sharedInstance = nil;

static NSInteger connectionType;


@implementation ConnectionHandler

- (id)initWithDelegate:(id<ConnectionHandlerDelegate>)delegate token:(NSString *)token{
    self = [super init];
    if(self) {
        currentUser = [user getInstance];
        delegate_ = delegate;
        token_ = token;
    }
    return self;
}

+(ConnectionHandler *)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
    }
    return sharedInstance;
}


- (void)logIn:(NSString *)email :(NSString *)password{
    connectionType = LOGIN;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"email\": \"%@\", \"password\": \"%@\"}", email, password];
    
    [self asynchronousWebCall:jsonRequest :LOGIN_URL :POST];
}


- (void)createAccount:(NSString *)email :(NSString *)password :(NSString *)fname :(NSString *)lname{
    connectionType = CREATE_ACCOUNT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"email\":\"%@\", \"password\":\"%@\", \"first_name\":\"%@\", \"last_name\":\"%@\"}", email, password, fname, lname];
    
    [self asynchronousWebCall:jsonRequest :CREATE_ACCOUNT_URL :POST];
}


- (void)addClass:(NSInteger)id :(NSString *)name :(NSInteger)grade {
    connectionType = ADD_CLASS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"teacher\":%ld,\"name\":\"%@\", \"grade\":\"%@\"}", (long)id, name, grade];
    NSString *url = [NSString stringWithFormat:@"%@create/", CLASS_URL];
    
    [self asynchronousWebCall:jsonRequest :url :POST];
}


- (void)editClass:(NSInteger)id :(NSString *)name :(NSString *)grade {
    connectionType = EDIT_CLASS;
    
    NSString *url = [NSString stringWithFormat:@"%@%ld/edit/", CLASS_URL, (long)id];

    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\", \"grade\":\"%@\"}", name, grade];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)deleteClass:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@%ld/delete/", CLASS_URL, (long)id];
    
    connectionType = DELETE_CLASS;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addReinforcer:(NSInteger)id :(NSString *)name :(NSInteger)value{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/reinforcer/create/", CLASS_URL, (long)id];
    connectionType = ADD_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\",\"value\":%ld}", name, (long)value];
    
    [self asynchronousWebCall:jsonRequest :ADD_REINFORCER_URL :POST];
}


- (void)editReinforcer:(NSInteger)id :(NSString *)name :(NSInteger)value{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/reinforcer/edit/", CLASS_URL, (long)id];

    connectionType = EDIT_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\",\"value\":%ld}", (long)id, name, (long)value];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)deleteReinforcer:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", DELETE_REINFORCER_URL, (long)id];
    connectionType = DELETE_REINFORCER;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addJar:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    connectionType = ADD_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\", \"total\":%ld}", (long)id, name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :ADD_JAR_URL :POST];
}


- (void)editJar:(NSInteger)id :(NSString *)name :(NSInteger)cost :(NSInteger)progress{
    connectionType = EDIT_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\", \"total\":%ld, \"progress\":%ld}", (long)id, name, (long)cost, (long)progress];
    
    [self asynchronousWebCall:jsonRequest :EDIT_JAR_URL :PUT];
}


- (void)deleteJar:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", DELETE_JAR_URL, (long)id];
    connectionType = DELETE_JAR;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addItem:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    connectionType = ADD_ITEM;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"cid\":%ld,\"name\":\"%@\", \"cost\":%ld}", (long)id, name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :ADD_ITEM_URL :POST];
}


- (void)editItem:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    connectionType = EDIT_ITEM;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\", \"cost\":%ld}", (long)id, name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :EDIT_ITEM_URL :PUT];
}


- (void)deleteItem:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", DELETE_ITEM_URL, (long)id];
    connectionType = DELETE_ITEM;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname{
    connectionType = ADD_STUDENT;
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/create", ADD_STUDENT_URL, (long)id];
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{, \"first_name\":\"%@\", \"last_name\":\"%@\"}", fname, lname];
    
    [self asynchronousWebCall:jsonRequest :url :POST];
}


- (void)editStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname{
    connectionType = EDIT_STUDENT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld, \"fname\":\"%@\", \"lname\":\"%@\"}", (long)id, fname, lname];
    
    [self asynchronousWebCall:jsonRequest :EDIT_STUDENT_URL :PUT];
}

- (void)deleteStudent:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", DELETE_STUDENT_URL, (long)id];
    connectionType = DELETE_STUDENT;
    
    [self asynchronousWebCall:nil :url :DELETE];
}

- (void)getSchools{
    connectionType = GET_SCHOOLS;
    
    [self asynchronousWebCall:nil :GET_SCHOOLS_URL :GET];
}

- (void)rewardStudentWithid:(NSInteger)id pointsEarned:(NSInteger)pointsEarned reinforcerId:(NSInteger)reinforcerId classId:(NSInteger)classId{
    connectionType = REWARD_STUDENT;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":\"%ld\", \"pointsearned\":%ld, \"reinforcerId\":%ld, \"cid\":%ld}", (long)id, (long)pointsEarned, (long)reinforcerId, (long)classId];
    
    [self asynchronousWebCall:jsonRequest :REWARD_STUDENT_URL :POST];
}


- (void)rewardStudentsWithids:(NSMutableArray *)ids pointsEarned:(NSInteger)pointsEarned reinforcerId:(NSInteger)reinforcerId classId:(NSInteger)classId{
    connectionType = REWARD_STUDENT_BULK;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ids
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"ids\":%@, \"points\":%ld, \"reinforcerId\":%ld, \"classId\":%ld}", jsonString, (long)pointsEarned, (long)reinforcerId, (long)classId];
    
    [self asynchronousWebCall:jsonRequest :REWARD_STUDENT_BULK_URL :POST];
}


- (void)rewardAllStudentsWithcid:(NSInteger)cid{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/rewardAllStudents", REWARD_ALL_STUDENTS_URL, (long)cid];
    connectionType = REWARD_ALL_STUDENTS;
    
    [self asynchronousWebCall:nil :url :PUT];
}

- (void)subtractPointsWithStudentId:(NSInteger)id points:(NSInteger)points{
    NSString *url = [NSString stringWithFormat:@"%@/?id=%ld&points=%ld", SUBTRACT_STUDENT_POINTS_URL, (long)id, (long)points];
    connectionType = SUBTRACT_POINTS;
    [self asynchronousWebCall:nil :url :PUT];
}

- (void)addPointsWithStudentId:(NSInteger)id points:(NSInteger)points{
    NSString *url = [NSString stringWithFormat:@"%@/?id=%ld&points=%ld", STUDENT_ADD_POINTS_URL, (long)id, (long)points];
    connectionType = ADD_POINTS;
    [self asynchronousWebCall:nil :url :PUT];
}


- (void)addToClassJar:(NSInteger)cjid :(NSInteger)points :(NSInteger)cid{
    NSString *url = [NSString stringWithFormat:@"%@/?id=%ld&points=%ld&cid=%ld", ADD_TO_JAR_URL, (long)cjid, (long)points, (long)cid];

    connectionType = ADD_TO_JAR;
    
    [self asynchronousWebCall:nil :url :PUT];
}


- (void)studentTransactionWithsid:(NSInteger)sid iid:(NSInteger)iid cost:(NSInteger)cost cid:(NSInteger)cid{
    connectionType = STUDENT_TRANSACTION;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"sid\":%ld, \"iid\":%ld, \"cost\":%ld, \"cid\":%ld}", (long)sid, (long)iid, (long)cost, (long)cid];
    
    [self asynchronousWebCall:jsonRequest :STUDENT_TRANSACTION_URL :POST];
}

- (void)editTeacherNameWithid:(NSInteger)id firstName:(NSString *)firstName lastName:(NSString *)lastName{
    
    connectionType = EDIT_TEACHER_NAME;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"uid\":%ld, \"fname\":\"%@\", \"lname\":\"%@\"}", (long)id, firstName, lastName];
    
    [self asynchronousWebCall:jsonRequest :EDIT_TEACHER_NAME_URL :PUT];

}


- (void)editTeacherPasswordWithemail:(NSString *)email oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword{
    connectionType = EDIT_TEACHER_PASSWORD;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"email\":\"%@\", \"password\":\"%@\", \"newPassword\":\"%@\"}", email, oldPassword, newPassword];
    
    [self asynchronousWebCall:jsonRequest :EDIT_TEACHER_PASSWORD_URL :PUT];
}


- (void)getClassStatsWithclassId:(NSInteger)classId{
    connectionType = GET_CLASS_STATS;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"classId\":%ld,}", (long)classId];
    
    [self asynchronousWebCall:jsonRequest :GET_CLASS_STATS_URL :GET];
}


- (void)checkInStudentWithstudentId:(NSInteger)studentId classId:(NSInteger)classId{
    connectionType = STUDENT_CHECK_IN;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld, \"cid\":%ld}", (long)studentId, (long)classId];
    
    [self asynchronousWebCall:jsonRequest :CHECK_IN_STUDENT_URL :POST];
    
}


- (void)checkOutStudentWithstudentId:(NSInteger)studentId classId:(NSInteger)classId{
    connectionType = STUDENT_CHECK_OUT;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld, \"cid\":%ld}", (long)studentId, (long)classId];
    
    [self asynchronousWebCall:jsonRequest :CHECK_OUT_STUDENT_URL :POST];
}


- (void)checkInAllStudentsWithclassId:(NSInteger)classId{
    connectionType = ALL_STUDENT_CHECK_IN;
    
    NSString *url = [NSString stringWithFormat:@"%@/%ld/checkAllStudentsIn", CHECK_IN_ALL_STUDENTS_URL, (long)classId];
    
    [self asynchronousWebCall:nil :url :POST];
}



- (void)checkOutAllStudentsWithclassId:(NSInteger)classId{
    connectionType = ALL_STUDENT_CHECK_OUT;

    NSString *url = [NSString stringWithFormat:@"%@/%ld/checkAllStudentsOut", CHECK_OUT_ALL_STUDENTS_URL, (long)classId];
    
    [self asynchronousWebCall:nil :url :POST];

}

- (void)resetPasswordWithemail:(NSString *)email{
    connectionType = RESET_PASSWORD;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"email\":\"%@\"}", email];
    
    [self asynchronousWebCall:jsonRequest :RESET_PASSWORD_URL :POST];
}


- (NSDictionary *) synchronousWebCall:(NSString *)jsonRequest :(NSURL *)url :(NSString *)httpMethod{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
    
    [request setHTTPMethod:httpMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *response = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"Check out the request -> %@", request);

    if ([response statusCode] >= 200 && [response statusCode] < 300)
    {
        NSError *err = nil;
        NSDictionary *jsonData = [NSJSONSerialization
                                  JSONObjectWithData:urlData
                                  options:NSJSONReadingMutableContainers
                                  error:&err];
        return jsonData;
    }
    else{
        return nil;
    }
}

- (void)asynchronousWebCall:(NSString *)jsonRequest :(NSString *)urlString :(NSString *)httpMethod{
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:httpMethod];
    NSLog(@"Here is the token %@", token_);
    if (token_){
        [request addValue:[NSString stringWithFormat:@"JWT %@", token_] forHTTPHeaderField:@"Authorization"];
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:8];
    NSLog(@"Check out the request -> %@", request);

    if (jsonRequest != nil){
        NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
        NSLog(@"Check out the sent data -> %@", request);
        [request setHTTPBody: requestData];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    }
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

/* Connection Delegates */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NSLog([NSString stringWithFormat:@"Here is the response %d",[response statusCode]]);
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"In connection did fail");
    [delegate_ dataReady:nil :connectionType];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *err = nil;
    NSDictionary *jsonData = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableContainers
                              error:&err];
    NSLog(@"%@ connection finished\nHere is the data \n-> %@", [Utilities getConnectionTypeString:connectionType], jsonData);
    if (!jsonData){
        jsonData = [NSDictionary dictionaryWithObject:@"1" forKey:@"success"];
    }
    [delegate_ dataReady:jsonData :connectionType];
}


@end
