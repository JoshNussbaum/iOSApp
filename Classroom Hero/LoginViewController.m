//
//  LoginViewController.m
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "LoginViewController.h"
#import "Utilities.h"
#import "MBProgressHUD.h"

NSDictionary *fakeSchool1;
NSArray *fakeSchools;
NSDictionary *fakeClass1;
NSArray *fakeClassArray;
NSDictionary *fakeUserDict;
NSDictionary *fakeLoginDict;
NSDictionary *fakeStudent1;
NSDictionary *fakeStudent2;
NSDictionary *fakeStudent3;
NSArray *fakeStudents;


@interface LoginViewController (){
    ConnectionHandler *webHandler;
    NSMutableArray *textFields;
    NSString *errorMessage;
    user *currentUser;
    MBProgressHUD* hud;
    bool isStamping;
}

@end

@implementation LoginViewController


- (void)viewDidAppear:(BOOL)animated{
    [currentUser reset];
    
    isStamping = NO;
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    
    self.emailTextField.text = @"josh@gmail.com";
    self.passwordTextField.text = @"Punkzor";
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
    [Utilities setTextFieldPlaceholder:self.emailTextField :@"Email" :[Utilities CHBlueColor]];
    [Utilities setTextFieldPlaceholder:self.passwordTextField :@"Password" :[Utilities CHBlueColor]];
    
    [Utilities makeRoundedButton:self.aboutButton :nil];
    [Utilities makeRoundedButton:self.pricingButton :nil];
    
    
    fakeStudent1 = @{@"id": @"1", @"fname": @"Mel", @"lname": @"Clarke", @"currentCoins": @"1", @"lvl": @"1", @"progress": @"1", @"totalCoins": @"1", @"checkedIn": @"0"};
    fakeStudent2 = @{@"id": @"2", @"fname": @"Holly", @"lname": @"Irish", @"currentCoins": @"2", @"lvl": @"1", @"progress": @"2", @"totalCoins": @"2", @"checkedIn": @"0"};
    fakeStudent3 = @{@"id": @"3", @"fname": @"Mike", @"lname": @"Sela", @"currentCoins": @"3", @"lvl": @"2", @"progress": @"0", @"totalCoins": @"3", @"checkedIn": @"0"};
    
    fakeStudents = @[fakeStudent1, fakeStudent2, fakeStudent3];
    
    fakeSchool1 = @{@"id": @"2", @"name": @"Josh's Jedi Lounge"};
    fakeSchools = @[fakeSchool1];
    fakeClass1 = @{@"cid": @"20", @"name": @"Python for Monkeys", @"classProgress": @"2", @"grade": @"2", @"nextLvl": @"10", @"classLvl": @"1", @"schoolId": @"2", @"students": fakeStudents};
    fakeClassArray = @[fakeClass1];
    fakeUserDict = @{@"fname" : @"Monkey", @"lname": @"Wizard", @"uid": @"120", @"accountStatus": @"2"};
    fakeLoginDict = @{@"login": fakeUserDict, @"classes":fakeClassArray, @"schools": fakeSchools};
}


- (IBAction)loginClicked:(id)sender{
    [self hideKeyboard];
    [[DatabaseHandler getSharedInstance] resetDatabase];
//    [self loginSuccess:fakeLoginDict];
//    return;
    textFields = [[NSMutableArray alloc]initWithObjects:self.emailTextField, self.passwordTextField, nil];
    
    errorMessage = @"";
    for (int i =0; i < [textFields count]; i++){
        NSString *error = [[textFields objectAtIndex:i] validate];
        if ( ![error isEqualToString:@""] ){
            errorMessage = [errorMessage stringByAppendingString:error];
            break;
        }
    }
    
    if (![errorMessage isEqualToString:@""]){
        [Utilities alertStatusWithTitle:@"Error logging in" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
    }
    
    else {
        [self activityStart:@"Logging in..."];
        [[DatabaseHandler getSharedInstance] resetDatabase];
        [webHandler logIn:self.emailTextField.text :self.passwordTextField.text :[[NSDate date] timeIntervalSince1970]];
    }
}


- (IBAction)createAccountClicked:(id)sender{
    [self performSegueWithIdentifier:@"login_to_account_creation" sender:self];
}


- (IBAction)aboutClicked:(id)sender{
    [self performSegueWithIdentifier:@"login_to_about" sender:self];
}


- (IBAction)pricingClicked:(id)sender{
    [self performSegueWithIdentifier:@"login_to_pricing" sender:self];
}


- (IBAction)forgotPasswordClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Forgot password" message:@"Enter your email to reset your password" cancel:@"Cancel" done:@"Confirm" delete:NO input:@"Email" tag:1 view:self];
}


- (IBAction)backgroundTap:(id)sender{
    [self hideKeyboard];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *email = [alertView textFieldAtIndex:0].text;
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    if (alertView.tag == 1){
        // RESET PASSWORD CONNETION HERE
        // Check to make sure its an email
        [webHandler resetPasswordWithemail:email];
    }

}


- (void)stampResultDidChange:(NSString *)stampResult{
    if (!currentUser.serial && !isStamping){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                isStamping = YES;
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                    [Utilities wiggleImage:self.stampImage sound:NO];
                    if (![[DatabaseHandler getSharedInstance]isSerialRegistered:stampSerial]){
                        [Utilities wiggleImage:self.stampImage sound:NO];
                        [self activityStart:@"Logging in..."];
                        [[DatabaseHandler getSharedInstance] resetDatabase];
                        [webHandler stampToLogin:stampSerial];
                    }
                    else {
                        [Utilities failAnimation:self.stampImage];
                        isStamping = NO;
                    }
                }
                else{
                    [Utilities failAnimation:self.stampImage];
                    isStamping = NO;
                }
                
            }
        }
    }
    
}


- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    [hud hide:YES];
    if (data == nil){
        [Utilities alertStatusNoConnection];
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    
    if ([successNumber boolValue] == YES){
        if (type == LOGIN || type == STAMP_TO_LOGIN){
            
            [Utilities wiggleImage:self.stampImage sound:NO];
            [self loginSuccess:data];
        }
    }
    else {
        NSString *message = [data objectForKey:@"message"];
        NSString *errorMessage;
        if (type == LOGIN){
            errorMessage = @"Error logging in";
        }
        else if (type == STAMP_TO_LOGIN){
            errorMessage = @"Error stamping to log in";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:nil];
        isStamping = NO;
    }
    
}


- (void)loginSuccess:(NSDictionary *)data{
    NSLog([NSString stringWithFormat:@"Here's the login info\n %@", data ]);
    // Set all the user stuff and query the database
    [[DatabaseHandler getSharedInstance] login:data];
    currentUser.accountStatus = [[[data objectForKey:@"login"] objectForKey:@"accountStatus"] integerValue];
    currentUser.email = self.emailTextField.text;
    currentUser.password = self.passwordTextField.text;
    currentUser.serial = [[data objectForKey:@"login"] objectForKey:@"stamp"];
    currentUser.firstName = [[data objectForKey:@"login"] objectForKey:@"fname"];
    currentUser.lastName = [[data objectForKey:@"login"] objectForKey:@"lname"];
    currentUser.id = [[[data objectForKey:@"login"] objectForKey:@"uid"] integerValue];
    NSInteger unregisteredStudents = [[DatabaseHandler getSharedInstance] getNumberOfUnregisteredStudentsInClass:currentUser.id];
    
    self.passwordTextField.text=@"";
    
    if (currentUser.accountStatus == 0){
        [self performSegueWithIdentifier:@"login_to_tutorial" sender:nil];
    }
    else {
        if (unregisteredStudents == 0){
            [self performSegueWithIdentifier:@"login_to_class" sender:nil];
            
        }
        else {
            [self performSegueWithIdentifier:@"login_to_register_students" sender:self];
        }
    }
    [hud hide:YES];
}


- (void)hideKeyboard{
    [self.view endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.passwordTextField) {
        [self.view endEditing:YES];
        return YES;
    }
    else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
        
    }
    return YES;
}


- (void)activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue{
    
}



@end
