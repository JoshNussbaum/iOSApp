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
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
    [Utilities setTextFieldPlaceholder:self.firstNameTextField :@"First name" :[Utilities CHGreenColor]];
    [Utilities setTextFieldPlaceholder:self.lastNameTextField :@"Last name" :[Utilities CHGreenColor]];
    [Utilities setTextFieldPlaceholder:self.emailTextField :@"Email" :[Utilities CHGreenColor]];
    [Utilities setTextFieldPlaceholder:self.passwordTextField :@"Password" :[Utilities CHGreenColor]];
    [Utilities setTextFieldPlaceholder:self.confirmPasswordTextField :@"Confirm password" :[Utilities CHGreenColor]];
    
    [Utilities makeRoundedButton:self.createAccountButton :[UIColor blackColor]];
    
    [Utilities makeRoundedButton:self.backButton :[UIColor blackColor]];

}


- (IBAction)createAccountClicked:(id)sender {
    //[self performSegueWithIdentifier:@"create_account_to_tutorial" sender:nil];
    
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


- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    NSLog(@"In Create Account and here is the data =>\n %@", data);
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        
        return;
    }
    if (type == CREATE_ACCOUNT){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];

        if([successNumber boolValue] == YES)
        {
            NSInteger cid = [[data objectForKey:@"id"] integerValue];

            NSMutableArray *schools = data[@"schools"];
            
            [[DatabaseHandler getSharedInstance] addSchools:schools];
            currentUser.firstName = self.firstNameTextField.text;
            currentUser.lastName = self.lastNameTextField.text;
            currentUser.email = self.emailTextField.text;
            currentUser.password = self.passwordTextField.text;
            currentUser.id = cid;
            currentUser.accountStatus = 0;
            [hud hide:YES];
            
            [self performSegueWithIdentifier:@"create_account_to_tutorial" sender:self];

            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error creating account" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            [hud hide:YES];
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


- (IBAction)backClicked:(id)sender{
    [self performSegueWithIdentifier:@"account_creation_to_login" sender:self];
}


- (void)hideKeyboard{
    [self.view endEditing:YES];
}


- (IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
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

- (void)setFirstTextField:(NSString *)placeholder{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
                                                                                                  NSForegroundColorAttributeName : [Utilities CHBlueColor],
                                                                                                  NSFontAttributeName : [UIFont fontWithName:@"Gill Sans" size:25.0]
                                                                                                  }];
    
    self.emailTextField.attributedPlaceholder = str;
}


- (void)setSecondTextField:(NSString *)placeholder{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
                                                                                                  NSForegroundColorAttributeName : [Utilities CHBlueColor],
                                                                                                  NSFontAttributeName : [UIFont fontWithName:@"Gill Sans" size:25.0]
                                                                                                  }];
    self.passwordTextField.attributedPlaceholder = str;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"create_account_to_tutorial"]){
        TutorialViewController *vc = [segue destinationViewController];
        [vc setFlag:1];
    }

}





@end
