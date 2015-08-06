//
//  CreateAccountViewController.m
//  Classroom Hero
//
//  Created by Josh on 7/25/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "MBProgressHUD.h"


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
    //[self performSegueWithIdentifier:@"create_account_to_tutorial" sender:self];
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
        [self alertStatus:@"Error creating account" :errorMessage];
    }
    else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]){
        [self alertStatus:@"Error creating account" :@"Passwords don't match"];
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
        [self alertStatus:@"Connection error" :@"Please check your internet connection and try again."];
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
            [self alertStatus:@"Error creating account" :message];
            [hud hide:YES];
            return;
        }
    }
    else{
        [self alertStatus:@"Connection error" :@"Please check your connectivity and try again"];
    }
}

-(void)createAccountSuccess:(NSDictionary *)accountInfo{
    [hud hide:YES];
}

- (void) alertStatus:(NSString *)title :(NSString *)message
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:@"Close"
                                             otherButtonTitles:nil,nil];
    [alertView show];
}

- (IBAction)backClicked:(id)sender {
    [self performSegueWithIdentifier:@"account_creation_to_login" sender:self];
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
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
