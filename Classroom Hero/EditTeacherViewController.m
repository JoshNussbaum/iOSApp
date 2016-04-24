//
//  EditTeacherViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "EditTeacherViewController.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "Flurry.h"

@interface EditTeacherViewController (){
    user *currentUser;
    MBProgressHUD *hud;
    NSMutableArray *textFields;
    NSString *errorMessage;
    
    ConnectionHandler *webHandler;

}

@end

@implementation EditTeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    NSArray *buttons = @[self.editNameButton, self.editPasswordButton, self.resetPasswordButton, self.manageStampButton];
    for (UIButton *button in buttons){
        [Utilities makeRoundedButton:button :[UIColor whiteColor]];
    }
    self.firstNameTextField.placeholder = currentUser.firstName;
    self.lastNameTextField.placeholder = currentUser.lastName;
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
}


- (IBAction)editNameClicked:(id)sender {
    [self hideKeyboard];
    textFields = [[NSMutableArray alloc]initWithObjects:self.firstNameTextField, self.lastNameTextField, nil];
    errorMessage = @"";
    if ([self.firstNameTextField.text isEqualToString:currentUser.firstName] && [self.lastNameTextField.text isEqualToString:currentUser.lastName]){
        [Utilities alertStatusWithTitle:@"Error editing name" message:@"Names are the same" cancel:nil otherTitles:nil tag:0 view:self];
        return;
    }
    for (int i =0; i < [textFields count]; i++){
        NSString *error = [[textFields objectAtIndex:i] validate];
        if ( ![error isEqualToString:@""] ){
            errorMessage = [errorMessage stringByAppendingString:error];
            break;
        }
    }
    if (![errorMessage isEqualToString:@""]){
        
        [hud hide:YES];
        [Utilities alertStatusWithTitle:@"Error editing name" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
    }
    else {
        [self activityStart:@"Editing name..."];
        [webHandler editTeacherNameWithid:currentUser.id firstName:self.firstNameTextField.text lastName:self.lastNameTextField.text];
        
    }
    
}


- (IBAction)editPasswordClicked:(id)sender {
    NSString *pass = currentUser.password;
    [self hideKeyboard];
    textFields = [[NSMutableArray alloc]initWithObjects:self.currentPasswordTextField, self.editPasswordTextField, self.confirmNewPasswordTextField, nil];
    if ([self.currentPasswordTextField.text isEqualToString:currentUser.password]){
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
            [Utilities alertStatusWithTitle:@"Error editing password" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
        else if (![self.editPasswordTextField.text isEqualToString:self.confirmNewPasswordTextField.text]){
            [Utilities alertStatusWithTitle:@"Error editing password" message:@"Passwords don't match" cancel:nil otherTitles:nil tag:0 view:nil];
            
        }
        else {
            [self activityStart:@"Editing password..."];
            [webHandler editTeacherPasswordWithemail:currentUser.email oldPassword:self.currentPasswordTextField.text newPassword:self.confirmNewPasswordTextField.text];
            
        }
    }
    else {
        [Utilities alertStatusWithTitle:@"Error editing password" message:@"Your original password does not match" cancel:nil otherTitles:nil tag:0 view:self];
    }

}


- (IBAction)resetPasswordClicked:(id)sender {
    [Utilities alertStatusWithTitle:@"Are you sure?" message:@"Send confirmation email to reset password?" cancel:@"Cancel" otherTitles:@[@"Reset"] tag:1 view:self];
}


- (IBAction)manageStampClicked:(id)sender {
    [self performSegueWithIdentifier:@"edit_teacher_to_manage_stamp" sender:self];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [self hideKeyboard];
        return;
    }
    
    else if (alertView.tag == 1){
        [webHandler resetPasswordWithemail:currentUser.email];
        [self activityStart:@"Recovering password..."];

        return;
    }
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if ([successNumber boolValue] == YES){
        if (type == EDIT_TEACHER_NAME){
            currentUser.firstName = self.firstNameTextField.text;
            currentUser.lastName = self.lastNameTextField.text;
            [hud hide:YES];
            self.firstNameTextField.text = @"";
            self.lastNameTextField.text = @"";
            [Utilities alertStatusWithTitle:@"Successfully edited name!" message:nil cancel:nil otherTitles:nil tag:0 view:nil];
            self.firstNameTextField.placeholder = currentUser.firstName;
            self.lastNameTextField.placeholder = currentUser.lastName;
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Edit Teacher Name" withParameters:params];
            
            
        }
        else if (type == EDIT_TEACHER_PASSWORD){
            currentUser.password = self.editPasswordTextField.text;
            [hud hide:YES];
            self.editPasswordTextField.text = @"";
            self.confirmNewPasswordTextField.text = @"";
            self.currentPasswordTextField.text = @"";
            [Utilities alertStatusWithTitle:@"Successfully edited password!" message:nil cancel:nil otherTitles:nil tag:0 view:nil];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Edit Teacher Password" withParameters:params];
        }
        
        else if (type == RESET_PASSWORD){
            [hud hide:YES];
            [Utilities alertStatusWithTitle:@"Password recovery email sent" message:@"Check your inbox for an email containing instructions to reset your password" cancel:nil otherTitles:nil tag:0 view:nil];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Reset Teacher Password" withParameters:params];
        }
        else{
            [Utilities alertStatusNoConnection];
        }
    }
    else {
        NSString *message = [data objectForKey:@"message"];
        NSString *errorMessage;
        
        if (type == EDIT_TEACHER_NAME){
            errorMessage = @"Error editing name";
        }
        else if (type == EDIT_TEACHER_PASSWORD){
            errorMessage = @"Error editing password";
        }
        else if (type == RESET_PASSWORD){
            errorMessage = @"Error resetting password";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
        [hud hide:YES];

    }

}


- (IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
}


- (void)hideKeyboard{
    [self.view endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.lastNameTextField) {
        [self.view endEditing:YES];
        return YES;
    }
    else if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
        
    }
    else if (textField == self.currentPasswordTextField) {
        [self.editPasswordTextField becomeFirstResponder];
        
    }
    else if (textField == self.editPasswordTextField) {
        [self.confirmNewPasswordTextField becomeFirstResponder];
        
    }
    else if (textField == self.confirmNewPasswordTextField){
        [self.view endEditing:YES];
    }
    return YES;
}


- (void)activityStart:(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


@end
