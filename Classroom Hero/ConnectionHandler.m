 //
//  ConnectionHandler.m
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.


#import "ConnectionHandler.h"
#import "Utilities.h"

//http://www.classroom-hero.com/classroom-web-services/
//http://ehorvat.webfactional.com/apps/ch/
//107.138.44.249:1337


static NSString * const CLASS_URL = @"http://www.classroom-hero.com/api/class";
static NSString * const ADD_CLASS_URL = @"http://www.classroom-hero.com/api/class/create/";

static NSString * const LOGIN_URL = @"http://www.classroom-hero.com/api/users/login/";
static NSString * const CREATE_ACCOUNT_URL = @"http://www.classroom-hero.com/api/users/register/";

static NSString * const EDIT_TEACHER_NAME_URL = @"http://www.classroom-hero.com/api/users/edit/";
static NSString * const EDIT_TEACHER_PASSWORD_URL = @"http://www.classroom-hero.com/api/users/changePassword/";
static NSString * const RESET_PASSWORD_URL = @"http://www.classroom-hero.com/api/users/password/reset/";

static NSString *POST = @"POST";
static NSString *PATCH = @"PATCH";
static NSString *PUT = @"PUT";
static NSString *GET = @"GET";
static NSString *DELETE = @"DELETE";

static ConnectionHandler *sharedInstance = nil;

static NSInteger connectionType;
static NSInteger statusCode;

@implementation ConnectionHandler

- (id)initWithDelegate:(id<ConnectionHandlerDelegate>)delegate token:(NSString *)token classId:(NSInteger)classId{
    self = [super init];
    if(self) {
        currentUser = [user getInstance];
        delegate_ = delegate;
        token_ = token;
        classId_ = classId;
    }
    return self;
}

+(ConnectionHandler *)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
    }
    return sharedInstance;
}

- (NSDictionary *)synchronousLogin:(NSString *)email :(NSString *)password{
    connectionType = LOGIN;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"email\": \"%@\", \"password\": \"%@\"}", email, password];
    
    return [self synchronousWebCall:jsonRequest :LOGIN_URL :POST];
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


- (void)addClass:(NSInteger)id :(NSString *)name :(NSString *)grade {
    connectionType = ADD_CLASS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"teacher\":%ld,\"name\":\"%@\", \"grade\":\"%@\"}", (long)id, name, grade];
    NSString *url = [NSString stringWithFormat:@"%@/create/", CLASS_URL];
    
    [self asynchronousWebCall:jsonRequest :url :POST];
}


- (void)editClass:(NSInteger)id :(NSString *)name :(NSString *)grade {
    connectionType = EDIT_CLASS;
    
    NSString *url = [NSString stringWithFormat:@"%@/%ld/edit/", CLASS_URL, (long)id];

    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\", \"grade\":\"%@\"}", name, grade];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)deleteClass:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/delete/", CLASS_URL, (long)id];
    
    connectionType = DELETE_CLASS;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addReinforcer:(NSInteger)id :(NSString *)name :(NSInteger)value{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/reinforcer/create/", CLASS_URL, (long)id];
    connectionType = ADD_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\",\"value\":%ld}", name, (long)value];
    
    [self asynchronousWebCall:jsonRequest :url :POST];
}


- (void)editReinforcer:(NSInteger)id :(NSString *)name :(NSInteger)value{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/reinforcer/%ld/edit/", CLASS_URL, classId_, (long)id];

    connectionType = EDIT_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\",\"value\":%ld}", name, (long)value];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)deleteReinforcer:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/reinforcer/%ld/delete/", CLASS_URL, classId_, (long)id];
    connectionType = DELETE_REINFORCER;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addJar:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/jar/create/", CLASS_URL, id];

    connectionType = ADD_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\", \"total\":%ld}", name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :url :POST];
}


- (void)editJar:(NSInteger)id :(NSString *)name :(NSInteger)cost :(NSInteger)progress{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/jar/%ld/edit/", CLASS_URL, classId_, (long)id];

    connectionType = EDIT_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\", \"total\":%ld, \"progress\":%ld}", name, (long)cost, (long)progress];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)deleteJar:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/jar/%ld/delete/", CLASS_URL, classId_, (long)id];
    connectionType = DELETE_JAR;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addItem:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/item/create/", CLASS_URL, id];

    connectionType = ADD_ITEM;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\", \"cost\":%ld}", name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :url :POST];
}


- (void)editItem:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/item/%ld/edit/", CLASS_URL, classId_, (long)id];

    connectionType = EDIT_ITEM;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld,\"name\":\"%@\", \"cost\":%ld}", (long)id, name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)deleteItem:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/item/%ld/delete/", CLASS_URL, classId_, (long)id];
    
    connectionType = DELETE_ITEM;
    
    [self asynchronousWebCall:nil :url :DELETE];
}


- (void)addStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname{
    connectionType = ADD_STUDENT;
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/create/", CLASS_URL, (long)id];
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"first_name\":\"%@\", \"last_name\":\"%@\"}", fname, lname];
    
    [self asynchronousWebCall:jsonRequest :url :POST];
}


- (void)editStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/%ld/edit/", CLASS_URL, classId_, (long)id];

    connectionType = EDIT_STUDENT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"first_name\":\"%@\", \"last_name\":\"%@\"}", fname, lname];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)deleteStudent:(NSInteger)id{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/%ld/delete/", CLASS_URL, classId_, (long)id];
    connectionType = DELETE_STUDENT;
    
    [self asynchronousWebCall:nil :url :DELETE];
}



- (void)rewardStudentWithid:(NSInteger)id reinforcerId:(NSInteger)reinforcerId{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/%ld/reward/", CLASS_URL, classId_, (long)id];

    connectionType = REWARD_STUDENT;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"reinforcer_id\":%ld}", (long)reinforcerId];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)rewardStudentsWithids:(NSMutableArray *)ids reinforcerId:(NSInteger)reinforcerId{
    
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/reward/bulk/", CLASS_URL, classId_];

    connectionType = REWARD_STUDENT_BULK;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ids
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"student_ids\":%@, \"reinforcer_id\":%ld}", jsonString, (long)reinforcerId];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)subtractPointsWithStudentId:(NSInteger)id points:(NSInteger)points{

    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/%ld/subtract/", CLASS_URL, classId_, id];
    connectionType = SUBTRACT_POINTS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"points\":%ld}", (long)points];

    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)addPointsWithStudentId:(NSInteger)id points:(NSInteger)points{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/%ld/add/", CLASS_URL, classId_, id];
    connectionType = ADD_POINTS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"points\":%ld}", (long)points];

    [self asynchronousWebCall:jsonRequest :url :PUT];
}

- (void)addPointsWithStudentIds:(NSMutableArray *)ids points:(NSInteger)points{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/add/bulk/", CLASS_URL, classId_];
    
    connectionType = ADD_POINTS_BULK;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ids
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"student_ids\":%@, \"points\":%ld}", jsonString, (long)points];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)subtractPointsWithStudentIds:(NSMutableArray *)ids points:(NSInteger)points{
    //PATCH /api/class/{class_id}/student/subtract/bulk
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/subtract/bulk/", CLASS_URL, classId_];
    
    connectionType = SUBTRACT_POINTS_BULK;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ids
                                                       options:NSJSONWritingPrettyPrinted                                                       error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"student_ids\":%@, \"points\":%ld}", jsonString, (long)points];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)addToClassJar:(NSInteger)cjid :(NSInteger)points{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/jar/%ld/add/", CLASS_URL, classId_, cjid];

    connectionType = ADD_TO_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"points\":%ld}", (long)points];

    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}


- (void)studentTransactionWithsid:(NSInteger)sid iid:(NSInteger)iid{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/%ld/sell/", CLASS_URL, classId_, sid];

    connectionType = STUDENT_TRANSACTION;

    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"item_id\":%ld}", (long)iid];
    
    [self asynchronousWebCall:jsonRequest :url :PUT];
}

- (void)editTeacherNameWithid:(NSInteger)id firstName:(NSString *)firstName lastName:(NSString *)lastName{
    
    connectionType = EDIT_TEACHER_NAME;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld, \"first_name\":\"%@\", \"last_name\":\"%@\"}", (long)id, firstName, lastName];
    
    [self asynchronousWebCall:jsonRequest :EDIT_TEACHER_NAME_URL :PATCH];

}


- (void)editTeacherPasswordWithid:(NSInteger)id password:(NSString *)password{
    connectionType = EDIT_TEACHER_PASSWORD;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"id\":%ld, \"password\":\"%@\"}", id, password];
    
    [self asynchronousWebCall:jsonRequest :EDIT_TEACHER_PASSWORD_URL :PUT];
}


- (void)checkInStudentWithstudentId:(NSInteger)studentId :(BOOL)manual{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/%ld/checkin/", CLASS_URL, classId_, studentId];

    connectionType = STUDENT_CHECK_IN;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"reward\":%@}", manual ? @"true" : @"false"];

    [self asynchronousWebCall:jsonRequest :url :PUT];
    
}


- (void)checkOutStudentWithstudentId:(NSInteger)studentId{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/student/%ld/checkout/", CLASS_URL, classId_, studentId];

    connectionType = STUDENT_CHECK_OUT;
    
    
    [self asynchronousWebCall:nil :url :PUT];
}


- (void)checkInAllStudents{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/checkAllIn/", CLASS_URL, classId_];

    connectionType = ALL_STUDENT_CHECK_IN;
    
    
    [self asynchronousWebCall:nil :url :PUT];
}



- (void)checkOutAllStudents{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/checkAllOut/", CLASS_URL, classId_];
    
    connectionType = ALL_STUDENT_CHECK_OUT;
    
    
    [self asynchronousWebCall:nil :url :PUT];

}

- (void)resetPasswordWithemail:(NSString *)email{
    connectionType = RESET_PASSWORD;
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"email\":\"%@\"}", email];
    
    [self asynchronousWebCall:jsonRequest :RESET_PASSWORD_URL :POST];
}


- (NSDictionary *) synchronousWebCall:(NSString *)jsonRequest :(NSURL *)url :(NSString *)httpMethod{
    NSURL *url_ = [NSURL URLWithString:url];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url_
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
    NSError *err = nil;
    NSDictionary *jsonData;
    @try{
        jsonData = [NSJSONSerialization
                    JSONObjectWithData:urlData
                    options:NSJSONReadingMutableContainers
                    error:&err];
    }
    @catch (NSException *exception){
        return nil;
    }
    //NSLog(@"Synchronous login - Here is the data \n-> %@", jsonData);

    return jsonData;

}

- (void)asynchronousWebCall:(NSString *)jsonRequest :(NSString *)urlString :(NSString *)httpMethod{
    NSURL *url = [NSURL URLWithString:urlString];
    //NSLog(@"Here is the URL -> %@", url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:httpMethod];
    if (token_){
        [request addValue:[NSString stringWithFormat:@"JWT %@", token_] forHTTPHeaderField:@"Authorization"];
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:8];

    if (jsonRequest != nil){
        NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
        [request setHTTPBody: requestData];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    }
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

/* Connection Delegates */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    statusCode = [response statusCode];
    //NSLog(@"Here is the status code -> %ld", (long)statusCode);
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [delegate_ dataReady:nil :connectionType];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *err = nil;
    NSDictionary *jsonData = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableContainers
                              error:&err];
    //NSLog(@"Here is the status code -> %ld", (long)statusCode);
    //NSLog(@"Here is the data -> %@", jsonData);
    if (statusCode >= 200 && statusCode < 400){

        //NSLog(@"%@ connection finished\nHere is the data \n-> %@", [Utilities getConnectionTypeString:connectionType], jsonData);
        if (!jsonData){
            jsonData = [NSDictionary dictionaryWithObject:@"1" forKey:@"success"];
        }
        [delegate_ dataReady:jsonData :connectionType];
    }
    else {
        if (statusCode == 403){
            jsonData = [NSDictionary dictionaryWithObject:@"Signature has expired." forKey:@"detail"];
        }
        [delegate_ dataReady:jsonData :connectionType];
    }

}


@end
