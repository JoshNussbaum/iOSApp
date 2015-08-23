//
//  ConnectionHandler.m
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//


#import "ConnectionHandler.h"
#import "Utilities.h"

static NSString * const LOGIN_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/login/auth";
static NSString * const CREATE_ACCOUNT_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/register/teacher";

static NSString * const ADD_CLASS_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/class/add";
static NSString * const EDIT_CLASS_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/class/edit";
static NSString * const DELETE_CLASS_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/class/delete";

static NSString * const ADD_CATEGORY_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/category/add";
static NSString * const EDIT_CATEGORY_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/category/edit";
static NSString * const DELETE_CATEGORY_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/category/delete";

static NSString * const ADD_ITEM_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/item/add";
static NSString * const EDIT_ITEM_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/item/edit";
static NSString * const DELETE_ITEM_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/item/delete";

static NSString * const ADD_JAR_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/jar/add";
static NSString * const EDIT_JAR_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/jar/edit";
static NSString * const DELETE_JAR_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/jar/delete";

static NSString * const ADD_STUDENT_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/student/add";
static NSString * const EDIT_STUDENT_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/student/edit";
static NSString * const DELETE_STUDENT_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/student/delete";
static NSString * const REWARD_STUDENT_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/student/reward";
static NSString * const TRANSACTION_STUDENT_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/student/transaction";

static NSString * const GET_SCHOOLS_URL = @"http://73.231.27.167:8080/SynappWebServiceDemo/services/schools/get";


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


-(void)logIn:(NSString *)email :(NSString *)password{
    connectionType = LOGIN;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"credentials\":{\"username\": \"%@\", \"password\": \"%@\"}}", email, password];
    
    [self asynchronousWebCall:jsonRequest :LOGIN_URL :POST];
}


-(void)createAccount:(NSString *)email :(NSString *)password :(NSString *)fname :(NSString *)lname{
    connectionType = CREATE_ACCOUNT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"email\":\"%@\",\"password\":\"%@\", \"fname\":\"%@\", \"lname\":\"%@\"}", email, password, fname, lname];
    
    [self asynchronousWebCall:jsonRequest :CREATE_ACCOUNT_URL :POST];
}


-(void)addClass:(NSInteger)id :(NSString *)name :(NSInteger)grade :(NSInteger)schoolId {
    connectionType = ADD_CLASS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"class\":{\"id\":%ld,\"name\":\"%@\", \"grade\":%ld, \"schoolId\":%ld}}", (long)id, name, (long)grade, (long)schoolId];
    
    [self asynchronousWebCall:jsonRequest :ADD_CLASS_URL :POST];
}


-(void)editClass:(NSInteger)id :(NSString *)name :(NSInteger)grade :(NSInteger)schoolId {
    connectionType = EDIT_CLASS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"class\":{\"id\":%ld,\"name\":\"%@\", \"grade\":%ld, \"schoolId\":%ld}}", (long)id, name, (long)grade, (long)schoolId];
    
    [self asynchronousWebCall:jsonRequest :EDIT_CLASS_URL :PUT];
}


-(void)deleteClass:(NSInteger)id{
    connectionType = DELETE_CLASS;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"class\":{\"id\":%ld,}}", (long)id];
    
    [self asynchronousWebCall:jsonRequest :DELETE_CLASS_URL :DELETE];
}


-(void)addReinforcer:(NSInteger)id :(NSString *)name{
    connectionType = ADD_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"category\":{\"id\":%ld,\"name\":\"%@\"}}", (long)id, name];
    
    [self asynchronousWebCall:jsonRequest :ADD_CATEGORY_URL :POST];
}


-(void)editCategory:(NSInteger)id :(NSString *)name{
    connectionType = EDIT_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"category\":{\"id\":%ld,\"name\":\"%@\"}}", (long)id, name];
    
    [self asynchronousWebCall:jsonRequest :EDIT_CATEGORY_URL :PUT];
}


-(void)deleteCategory:(NSInteger)id{
    connectionType = DELETE_REINFORCER;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"category\":{\"id\":%ld}}", (long)id];
    
    [self asynchronousWebCall:jsonRequest :DELETE_CATEGORY_URL :DELETE];
}


-(void)addJar:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    connectionType = ADD_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"jar\":{\"id\":%ld,\"name\":\"%@\", \"total\":%ld}}", (long)id, name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :ADD_JAR_URL :POST];
}


-(void)editJar:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    connectionType = EDIT_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"jar\":{\"id\":%ld,\"name\":\"%@\", \"total\":%ld}}", (long)id, name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :EDIT_JAR_URL :PUT];
}


-(void)deleteJar:(NSInteger)id{
    connectionType = DELETE_JAR;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"jar\":{\"id\":%ld}}", (long)id];
    
    [self asynchronousWebCall:jsonRequest :DELETE_JAR_URL :DELETE];
}


-(void)addItem:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    connectionType = ADD_ITEM;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"item\":{\"id\":%ld,\"name\":\"%@\", \"cost\":%ld}}", (long)id, name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :ADD_ITEM_URL :POST];
}


-(void)editItem:(NSInteger)id :(NSString *)name :(NSInteger)cost{
    connectionType = EDIT_ITEM;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"item\":{\"id\":%ld,\"name\":\"%@\", \"cost\":%ld}}", (long)id, name, (long)cost];
    
    [self asynchronousWebCall:jsonRequest :EDIT_ITEM_URL :PUT];
}


-(void)deleteItem:(NSInteger)id{
    connectionType = DELETE_ITEM;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"item\":{\"id\":%ld}}", (long)id];
    
    [self asynchronousWebCall:jsonRequest :DELETE_ITEM_URL :DELETE];
}


-(void)addStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname{
    connectionType = ADD_STUDENT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"student\":{\"id\":%ld,\"fname\":\"%@\", \"lname\":\"%@\"}}", (long)id, fname, lname];
    
    [self asynchronousWebCall:jsonRequest :ADD_STUDENT_URL :POST];
}


-(void)editStudent:(NSInteger)id :(NSString *)fname :(NSString *)lname{
    connectionType = EDIT_STUDENT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"student\":{\"id\":%ld,\"fname\":\"%@\", \"lname\":\"%@\"}}", (long)id, fname, lname];
    
    [self asynchronousWebCall:jsonRequest :EDIT_STUDENT_URL :PUT];
}

-(void)deleteStudent:(NSInteger)id{
    connectionType = DELETE_STUDENT;
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"student\":{\"id\":%ld}}", (long)id];
    
    [self asynchronousWebCall:jsonRequest :DELETE_STUDENT_URL :DELETE];
}

-(void)getSchools{
    connectionType = GET_SCHOOLS;
    
    [self asynchronousWebCall:nil :GET_SCHOOLS_URL :GET];
    
}



-(NSDictionary *) synchronousWebCall:(NSString *)jsonRequest :(NSURL *)url :(NSString *)httpMethod{
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

-(void)asynchronousWebCall:(NSString *)jsonRequest :(NSString *)urlString :(NSString *)httpMethod{
    NSLog(@"Json Request -> %@", jsonRequest );
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
    [request setHTTPMethod:httpMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    [request setTimeoutInterval:20];
    
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
    [delegate_ dataReady:jsonData :connectionType];
}


@end
