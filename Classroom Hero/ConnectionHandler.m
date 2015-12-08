//
//  ConnectionHandler.m
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//


#import "ConnectionHandler.h"
#import "Utilities.h"

static NSString * const LOGIN_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/login/auth";
static NSString * const STAMP_TO_LOGIN_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/login/auth/stamp";
static NSString * const CREATE_ACCOUNT_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/register/teacher";

static NSString * const ADD_CLASS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/class/add";
static NSString * const EDIT_CLASS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/class/edit";
static NSString * const DELETE_CLASS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/class/delete";

static NSString * const ADD_REINFORCER_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/reinforcer/add";
static NSString * const EDIT_REINFORCER_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/reinforcer/edit";
static NSString * const DELETE_REINFORCER_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/reinforcer/delete";

static NSString * const ADD_ITEM_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/item/add";
static NSString * const EDIT_ITEM_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/item/edit";
static NSString * const DELETE_ITEM_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/item/delete";

static NSString * const ADD_JAR_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/jar/add";
static NSString * const EDIT_JAR_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/jar/edit";
static NSString * const DELETE_JAR_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/jar/delete";

static NSString * const ADD_STUDENT_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/student/add";
static NSString * const EDIT_STUDENT_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/student/edit";
static NSString * const DELETE_STUDENT_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/student/delete";
static NSString * const GET_STUDENT_BY_SERIAL_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/student/get";
static NSString * const REWARD_STUDENT_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/student/reward";
static NSString * const CHECK_IN_STUDENT_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/student/checkin";
static NSString * const CHECK_OUT_STUDENT_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/student/checkout";
static NSString * const CHECK_IN_ALL_STUDENTS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/class";
static NSString * const CHECK_OUT_ALL_STUDENTS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/class";

static NSString * const STUDENT_TRANSACTION_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/student/transaction";

static NSString * const GET_SCHOOLS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/schools/get";
static NSString * const REGISTER_STAMP_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/register/stamp";
static NSString * const UNREGISTER_STAMP_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/register/unregisterStamp";

static NSString * const REWARD_ALL_STUDENTS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/class/rewardAllStudents";
static NSString * const ADD_TO_JAR_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/jar/fill";

static NSString * const ORDER_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/register/order";

static NSString * const EDIT_TEACHER_NAME_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/register/order";
static NSString * const EDIT_TEACHER_PASSWORD_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/register/order";

static NSString * const GET_CLASS_STATS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/class/stats";

static NSString * const IDENTIFY_STAMP_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/user/identify";

static NSString * const UNREGISTER_ALL_STUDENTS_URL = @"http://73.231.27.167:8080/dev.classroomhero/services/class/unregisterAllStudents";

//[[NSDate date] timeIntervalSince1970];
static NSString *POST = @"POST";
static NSString *PUT = @"PUT";
static NSString *GET = @"GET";
static NSString *DELETE = @"DELETE";

static ConnectionHandler *sharedInstance = nil;

static NSInteger connectionType;


@implementation ConnectionHandler
- (id)initWithDelegate:(id<ConnectionHandlerDelegate>)delegate {
    self = [super init];
    if(self) {
        currentUser = [user getInstance];
        delegate_ = delegate;
    }
    return self;
}

+(ConnectionHandler *)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
    }
    return sharedInstance;
}


- (void)logIn:(NSString *)email :(NSString *)password :(double)date{
    connectionType = LOGIN;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"username\": \"%@\", \"password\": \"%@\", \"date\": %ld}", email, password, (long)date];
    
    [self asynchronousWebCall:jsonRequest :LOGIN_URL :POST];
}


- (void)createAccount:(NSString *)email :(NSString *)password :(NSString *)fname :(NSString *)lname{
    connectionType = CREATE_ACCOUNT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"email\":\"%@\",\"password\":\"%@\", \"fname\":\"%@\", \"lname\":\"%@\"}", email, password, fname, lname];
    
    [self asynchronousWebCall:jsonRequest :CREATE_ACCOUNT_URL :POST];
}


- (void)addClass:(NSInteger)id :(NSString *)name :(NSInteger)grade :(NSInteger)schoolId {
    connectionType = ADD_CLASS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\", \"grade\":%ld, \"schoolId\":%ld}", (long)id, name, (long)grade, (long)schoolId];
    
    [self asynchronousWebCall:jsonRequest :ADD_CLASS_URL :POST];
}


- (void)editClass:(NSInteger)id :(NSString *)name :(NSInteger)grade :(NSInteger)schoolId {
    connectionType = EDIT_CLASS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\", \"grade\":%ld, \"schoolId\":%ld}", (long)id, name, (long)grade, (long)schoolId];
    
    [self asynchronousWebCall:jsonRequest :EDIT_CLASS_URL :PUT];
}


- (void)deleteClass:(NSInteger)id{
    
    NSString *url = [NSString stringWithFormat:@"%@/%ld", DELETE_CLASS_URL, (long)id];
    connectionType = DELETE_CLASS;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addReinforcer:(NSInteger)id :(NSString *)name :(NSInteger)value{
    connectionType = ADD_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"cid\":%ld,\"name\":\"%@\",\"value\":%ld}", (long)id, name, (long)value];
    
    [self asynchronousWebCall:jsonRequest :ADD_REINFORCER_URL :POST];
}


- (void)editReinforcer:(NSInteger)id :(NSString *)name :(NSInteger)value{
    connectionType = EDIT_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\",\"value\":%ld}", (long)id, name, (long)value];
    
    [self asynchronousWebCall:jsonRequest :EDIT_REINFORCER_URL :PUT];
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


- (void)editJar:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    connectionType = EDIT_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\", \"total\":%ld}", (long)id, name, (long)cost];
    
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


- (void)addStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname :(NSInteger)schoolId{
    connectionType = ADD_STUDENT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"cid\":%ld, \"fname\":\"%@\", \"lname\":\"%@\", \"schoolId\":%ld}", (long)id, fname, lname, (long)schoolId];
    
    [self asynchronousWebCall:jsonRequest :ADD_STUDENT_URL :POST];
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

- (void)registerStamp:(NSInteger)id :(NSString *)serial{
    connectionType = REGISTER_STAMP;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"uid\":%ld, \"stamp\":\"%@\"}", (long)id, serial];
    
    [self asynchronousWebCall:jsonRequest :REGISTER_STAMP_URL :POST];
}


- (void)rewardStudentWithserial:(NSString *)serial pointsEarned:(NSInteger)pointsEarned reinforcerId:(NSInteger)reinforcerId schoolId:(NSInteger)schoolId{
    connectionType = REWARD_STUDENT;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"stamp\":\"%@\", \"pointsearned\":%ld, \"reinforcerId\":%ld, \"schoolId\":%ld}", serial, (long)pointsEarned, (long)reinforcerId, (long)schoolId];
    
    [self asynchronousWebCall:jsonRequest :REWARD_STUDENT_URL :POST];
}


- (void)rewardAllStudentsWithcid:(NSInteger)cid{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", REWARD_ALL_STUDENTS_URL, (long)cid];
    connectionType = REWARD_ALL_STUDENTS;
    
    [self asynchronousWebCall:nil :url :PUT];
}


- (void)addToClassJar:(NSInteger)cjid :(NSInteger)points{
    NSString *url = [NSString stringWithFormat:@"%@/?id=%ld&points=%ld", ADD_TO_JAR_URL, (long)cjid, (long)points];

    connectionType = ADD_TO_JAR;
    
    [self asynchronousWebCall:nil :url :PUT];
}


- (void)studentTransactionWithsid:(NSInteger)sid iid:(NSInteger)iid cost:(NSInteger)cost{
    connectionType = STUDENT_TRANSACTION;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"sid\":%ld, \"iid\":%ld, \"cost\":%ld}", (long)sid, (long)iid, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :STUDENT_TRANSACTION_URL :POST];
}

//- (void)orderStampsWithid:(NSInteger)id packageId:(NSInteger)packageId stamps:(NSInteger)stamps schoolId:(NSInteger)schoolId source:(STPToken *)source amount:(NSInteger)amount currency:(NSString *)currency email:(NSString *)email{
//    if (packageId == 1){
//        connectionType = ORDER_RECRUIT;
//    }
//    else if (packageId == 2){
//        connectionType = ORDER_EPIC;
//    }
//    else if (packageId == 3){
//        connectionType = ORDER_LEGENDARY;
//    }
//    else if (packageId == 4){
//        connectionType = ORDER_HERO;
//    }
//    
//    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"order\":{\"uid\":%ld, \"package\":%ld, \"numStamps\":%ld, \"schoolId\":%ld, \"source\":\"%@\", \"amount\":%ld, \"currency\":\"%@\", \"email\":\"%@\" }}", (long)id, (long)packageId, (long)stamps, (long)schoolId, source, (long)amount, @"USD", email];
//    
//    [self asynchronousWebCall:jsonRequest :ORDER_URL :POST];
//}


- (void)unregisterStampWithid:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", UNREGISTER_STAMP_URL, (long)id];
    connectionType = UNREGISTER_STAMP;
    
    [self asynchronousWebCall:nil :url :PUT];
}


- (void)editTeacherNameWithid:(NSInteger)id firstName:(NSString *)firstName lastName:(NSString *)lastName{
    
    connectionType = EDIT_TEACHER_NAME;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld, \"firstName\":\"%@\", \"lastName\":\"%@\"}", (long)id, firstName, lastName];
    
    [self asynchronousWebCall:jsonRequest :EDIT_TEACHER_NAME_URL :PUT];

}


- (void)editTeacherPasswordWithid:(NSInteger)id password:(NSString *)password{
    connectionType = EDIT_TEACHER_PASSWORD;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld, \"password\":\"%@\"}", (long)id, password];
    
    [self asynchronousWebCall:jsonRequest :EDIT_TEACHER_PASSWORD_URL :PUT];
}

- (void)stampToLogin:(NSString *)stampSerial{
    NSString *url = [NSString stringWithFormat:@"%@/%@", STAMP_TO_LOGIN_URL, stampSerial];
    connectionType = STAMP_TO_LOGIN;
    
    [self asynchronousWebCall:nil :url :POST];
}

- (void)getClassStatsWithclassId:(NSInteger)classId schoolId:(NSInteger)schoolId{
    connectionType = GET_CLASS_STATS;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"classId\":%ld, \"schoolId\":%ld}", (long)classId, (long)schoolId];
    
    [self asynchronousWebCall:jsonRequest :GET_CLASS_STATS_URL :GET];
}


- (void)identifyStampWithserial:(NSString *)serial{
    NSString *url = [NSString stringWithFormat:@"%@/%@", IDENTIFY_STAMP_URL, serial];
    connectionType = IDENTIFY_STAMP;
    
    [self asynchronousWebCall:nil :url :GET];
}

- (void)unregisterAllStudentsInClassWithid:(NSInteger)classId{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", UNREGISTER_ALL_STUDENTS_URL, (long)classId];
    connectionType = UNREGISTER_ALL_STUDENTS;
    
    [self asynchronousWebCall:nil :url :GET];
}

- (void)getStudentBySerialwithserial:(NSString *)serial :(NSInteger)schoolId{
    NSString *url = [NSString stringWithFormat:@"%@/?stamp=%@&schoolId=%ld", GET_STUDENT_BY_SERIAL_URL, serial, (long)schoolId];
    connectionType = GET_STUDENT_BY_STAMP;
    
    [self asynchronousWebCall:nil :url :GET];
}


- (void)checkInStudentWithstudentId:(NSInteger)studentId classId:(NSInteger)classId{
    connectionType = STUDENT_CHECK_IN;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld, \"cid\":%ld, \"timestamp\":%ld}", (long)studentId, (long)classId, (long)[[NSDate date] timeIntervalSince1970]];
    
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
        NSLog(@"Synchronous web call failed");
        return nil;
    }
}

- (void)asynchronousWebCall:(NSString *)jsonRequest :(NSString *)urlString :(NSString *)httpMethod{
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:httpMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20];
    
    if (jsonRequest != nil){
        NSLog(@"Json Request -> %@", jsonRequest );
        NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
        [request setHTTPBody: requestData];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    }
    else {
        NSLog(@"Heres the URL -> %@", url);
    }
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

/* Connection Delegates */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"In connection did fail");

    if(error.code == NSURLErrorTimedOut){
    }
    else {

    }
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
    
    [delegate_ dataReady:jsonData :connectionType];
}


@end
