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
    [Utilities makeRoundedButton:self.editNameButton :[UIColor whiteColor]];
    [Utilities makeRoundedButton:self.editPasswordButton :[UIColor whiteColor]];
    [Utilities makeRoundedButton:self.resetPasswordButton :nil];
    self.firstNameTextField.placeholder = currentUser.firstName;
    self.lastNameTextField.placeholder = currentUser.lastName;
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
}


- (IBAction)editNameClicked:(id)sender {
    [self hideKeyboard];
    textFields = [[NSMutableArray alloc]initWithObjects:self.firstNameTextField, self.lastNameTextField, nil];
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
        [Utilities alertStatusWithTitle:@"Error editing name" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
    }
    else {
        [self activityStart:@"Editing name..."];
        [webHandler editTeacherNameWithid:currentUser.id firstName:self.firstNameTextField.text lastName:self.lastNameTextField.text];
        
    }
    
}


- (IBAction)editPasswordClicked:(id)sender {
    [self hideKeyboard];
    textFields = [[NSMutableArray alloc]initWithObjects:self.currentPasswordTextField, self.editPasswordTextField, self.confirmNewPasswordTextField, nil];
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
        [webHandler editTeacherPasswordWithid:currentUser.id password:self.editPasswordTextField.text];
        
    }
}


- (IBAction)resetPasswordClicked:(id)sender {
    
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
    if (type == EDIT_TEACHER_NAME){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
        
        if([successNumber boolValue] == YES)
        {
            currentUser.firstName = self.firstNameTextField.text;
            currentUser.lastName = self.lastNameTextField.text;
            [hud hide:YES];
            [Utilities alertStatusWithTitle:@"Successfully edited name!" message:nil cancel:nil otherTitles:nil tag:0 view:nil];
            self.firstNameTextField.placeholder = currentUser.firstName;
            self.lastNameTextField.placeholder = currentUser.lastName;

        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing name" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            [hud hide:YES];
            return;
        }
    }
    else if (type == EDIT_TEACHER_PASSWORD){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
        if([successNumber boolValue] == YES)
        {
            currentUser.password = self.editPasswordTextField.text;
            [hud hide:YES];
            self.editPasswordTextField.text = @"";
            self.confirmNewPasswordTextField.text = @"";
            self.currentPasswordTextField.text = @"";
            [Utilities alertStatusWithTitle:@"Successfully edited password!" message:nil cancel:nil otherTitles:nil tag:0 view:nil];

        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing name" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            [hud hide:YES];
            return;
        }
    }
    else{
        [Utilities alertStatusNoConnection];
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
    return YES;
}


- (void)activityStart:(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


@end
