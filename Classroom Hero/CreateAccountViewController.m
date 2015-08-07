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


@interface CreateAccountViewController (){
    MBProgressHUD* hud;
    NSMutableArray *textFields;
    ConnectionHandler *webHandler;
    NSString *errorMessage;
    user *currentUser;
}

@end

@implementation CreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];

}



- (IBAction)createAccountClicked:(id)sender {
    [self hideKeyboard];
    [self performSegueWithIdentifier:@"create_account_to_tutorial" sender:self];
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
        [Utilities alertStatus:@"Error creating account" :errorMessage :@"Okay" :nil :0];
    }
    else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]){
        [Utilities alertStatus:@"Error creating account" :@"Passwords don't match" :@"Okay" :nil :0];
    }
    else {
        [self activityStart:@"Validating account..."];
        [webHandler createAccount:self.emailTextField.text :self.passwordTextField.text :self.firstNameTextField.text :self.lastNameTextField.text];
        
    }
}

- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    NSLog(@"In here and here is the data =>\n %@", data);
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatus:@"Connection error" :@"Please check your internet connection and try again." :@"Okay" :nil :0];
        return;
    }
    if (type == 2){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
        NSInteger cid = [[data objectForKey:@"id"] integerValue];

        if([successNumber boolValue] == YES)
        {
            currentUser.firstName = self.firstNameTextField.text;
            currentUser.lastName = self.lastNameTextField.text;
            currentUser.email = self.emailTextField.text;
            currentUser.password = self.passwordTextField.text;
            currentUser.id = cid;
            [hud hide:YES];
            [self performSegueWithIdentifier:@"create_account_to_tutorial" sender:self];
            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatus:@"Error creating account" :message :@"Okay" :nil :0];
            [hud hide:YES];
            return;
        }
    }
    else{
        [Utilities alertStatus:@"Connection error" :@"Please check your connectivity and try again" :@"Okay" :nil :0];
    }
}

-(void)createAccountSuccess:(NSDictionary *)accountInfo{
    [hud hide:YES];
}


- (IBAction)backClicked:(id)sender {
    [self performSegueWithIdentifier:@"account_creation_to_login" sender:self];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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

- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}

@end
