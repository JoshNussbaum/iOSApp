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
#import "TutorialViewController.h"
#import "FDKeychain.h"
#import <Google/Analytics.h>


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


- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Create Account"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];

    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:0];

    [Utilities makeRounded:self.createAccountButton.layer color:nil borderWidth:0.5f cornerRadius:5];
    
    textFields = [[NSMutableArray alloc]initWithObjects:self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.passwordTextField, self.confirmPasswordTextField, nil];
    
    for (UITextField *tf in textFields){
        [Utilities makeRounded:tf.layer color:[UIColor blackColor] borderWidth:0.5f cornerRadius:5];
    }
    
}


- (void)viewDidLayoutSubviews{
    if (IS_IPAD_PRO){
        textFields = [[NSMutableArray alloc]initWithObjects:self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.passwordTextField, self.confirmPasswordTextField, nil];
        
        for (UITextField *tf in textFields){
            float x = tf.frame.origin.x;
            float y = tf.frame.origin.y + 50;
            float width = tf.frame.size.width;
            float height = tf.frame.size.height;
            [tf setFrame:CGRectMake(x, y, width, height)];
        }
        float x = self.createAccountButton.frame.origin.x;
        float y = self.createAccountButton.frame.origin.y + 50;
        float width = self.createAccountButton.frame.size.width;
        float height = self.createAccountButton.frame.size.height;
        self.createAccountButton.frame = CGRectMake(x, y, width, height);
    }
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
    [self performSegueWithIdentifier:@"unwind_to_login" sender:self];
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
        NSString *errorMessage = [data objectForKey: @"message"];

        if(!errorMessage)
        {
            NSInteger tid = [[data objectForKey:@"id"] integerValue];
            currentUser.token = [data objectForKey:@"token"];

            currentUser.firstName = self.firstNameTextField.text;
            currentUser.lastName = self.lastNameTextField.text;
            currentUser.email = self.emailTextField.text;
            currentUser.password = self.passwordTextField.text;
            currentUser.id = tid;
            currentUser.accountStatus = 0;
            
            NSError *error = nil;
            [FDKeychain saveItem: self.emailTextField.text
                          forKey: @"email"
                      forService: @"Classroom Hero"
                           error: &error];
            
            [FDKeychain saveItem: self.passwordTextField.text
                          forKey: @"password"
                      forService: @"Classroom Hero"
                           error: &error];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

                [self performSegueWithIdentifier:@"create_account_to_tutorial" sender:self];
                
            }
            else {
                [self performSegueWithIdentifier:@"account_creation_to_class" sender:self];
            }

            
        }
        else {
            [Utilities alertStatusWithTitle:@"Error creating account" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
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
