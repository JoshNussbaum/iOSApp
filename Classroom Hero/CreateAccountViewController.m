//
//  CreateAccountViewController.m
//  Classroom Hero
//
//  Created by Josh on 7/25/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "RegisterStudentsViewController.h"
#import "TutorialViewController.h"
#import "Flurry.h"


@interface CreateAccountViewController (){
    MBProgressHUD* hud;
    NSMutableArray *textFields;
    ConnectionHandler *webHandler;
    NSString *errorMessage;
    user *currentUser;
    NSDictionary *schoolData;
}

@end

@implementation CreateAccountViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];

    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
//    [Utilities setTextFieldPlaceholder:self.firstNameTextField :@"First name" :[UIColor blackColor]];
//    [Utilities setTextFieldPlaceholder:self.lastNameTextField :@"Last name" :[UIColor blackColor]];
//    [Utilities setTextFieldPlaceholder:self.emailTextField :@"Email" :[UIColor blackColor]];
//    [Utilities setTextFieldPlaceholder:self.passwordTextField :@"Password" :[UIColor blackColor]];
//    [Utilities setTextFieldPlaceholder:self.confirmPasswordTextField :@"Confirm password" :[UIColor blackColor]];
    
    [Utilities makeRoundedButton:self.createAccountButton :[UIColor whiteColor]];
}


- (IBAction)createAccountClicked:(id)sender {
    [self hideKeyboard];
    
    textFields = [[NSMutableArray alloc]initWithObjects:self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.passwordTextField, self.confirmPasswordTextField, nil];
    
    errorMessage = @"";
    for (int i =0; i < [textFields count]; i++){
        NSString *error = [[textFields objectAtIndex:i] validate];
        if ( ![error isEqualToString:@""] ){
            errorMessage = [errorMessage stringByAppendingString:error];
            break;
        }
    }
    if (![errorMessage isEqualToString:@""]){
        
        [hud hide:YES];
        [Utilities alertStatusWithTitle:@"Error creating account" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
    }
    else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]){
        [Utilities alertStatusWithTitle:@"Error creating account" message:@"Passwords don't match" cancel:nil otherTitles:nil tag:0 view:nil];

    }
    else {
        [self activityStart:@"Validating account..."];
        [[DatabaseHandler getSharedInstance] resetDatabase];
        [webHandler createAccount:self.emailTextField.text :self.passwordTextField.text :self.firstNameTextField.text :self.lastNameTextField.text];
    }
}


- (IBAction)backClicked:(id)sender{
    [self performSegueWithIdentifier:@"account_creation_to_login" sender:self];
}


- (IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
}


- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    [hud hide:YES];

    if (data == nil){
        [Utilities alertStatusNoConnection];
        
        return;
    }
    if (type == CREATE_ACCOUNT){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];

        if([successNumber boolValue] == YES)
        {
            NSInteger tid = [[data objectForKey:@"id"] integerValue];

            NSMutableArray *schools = data[@"schools"];
            
            [[DatabaseHandler getSharedInstance] addSchools:schools];
            currentUser.firstName = self.firstNameTextField.text;
            currentUser.lastName = self.lastNameTextField.text;
            currentUser.email = self.emailTextField.text;
            currentUser.password = self.passwordTextField.text;
            currentUser.id = tid;
            currentUser.accountStatus = 0;
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%ld", (long)tid], @"Teacher ID",
                                    [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name",
                                    [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil
                                    ];
            
            [Flurry logEvent:@"Create Account" withParameters:params];
            
            [self performSegueWithIdentifier:@"create_account_to_tutorial" sender:self];

            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error creating account" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            return;
        }
    }
    else{
        [Utilities alertStatusNoConnection];
    }
}


- (void)createAccountSuccess:(NSDictionary *)accountInfo{
    [hud hide:YES];
}


- (void)hideKeyboard{
    [self.view endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.confirmPasswordTextField) {
        [self.view endEditing:YES];
        return YES;
    }
    else if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
        
    }
    else if (textField == self.lastNameTextField) {
        [self.emailTextField becomeFirstResponder];
        
    }
    else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
        
    }
    else if (textField == self.passwordTextField) {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    
    return YES;
}


- (void)activityStart:(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"create_account_to_tutorial"]){
        TutorialViewController *vc = [segue destinationViewController];
        [vc setFlag:1];
    }

}





@end
