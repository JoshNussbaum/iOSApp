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


@interface LoginViewController (){
    ConnectionHandler *webHandler;
    NSMutableArray *textFields;
    NSString *errorMessage;
    user *currentUser;
    MBProgressHUD* hud;
}

@end

@implementation LoginViewController


- (void)viewDidAppear:(BOOL)animated{
    [currentUser reset];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    [Utilities setTextFieldPlaceholder:self.emailTextField :@"Email" :[Utilities CHBlueColor]];
    [Utilities setTextFieldPlaceholder:self.passwordTextField :@"Password" :[Utilities CHBlueColor]];
    
    [Utilities makeRoundedButton:self.aboutButton :nil];
    [Utilities makeRoundedButton:self.pricingButton :nil];

    // Do any additional setup after loading the view.
}


- (void)activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (void)hideKeyboard{
    [self.view endEditing:YES];
}


- (IBAction)backgroundTap:(id)sender{
    [self hideKeyboard];
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


- (IBAction)loginClicked:(id)sender{
    //[self performSegueWithIdentifier:@"login_to_class" sender:self];
    [self hideKeyboard];
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
        [webHandler logIn:self.emailTextField.text :self.passwordTextField.text];
    }
}


- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    NSLog(@"In Login \n %@", data);
    if (type == 1){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
        
        if([successNumber boolValue] == YES)
        {
            // Set all the user stuff and query the database
            [[DatabaseHandler getSharedInstance] login:data];
            currentUser.accountStatus = [[[data objectForKey:@"login"] objectForKey:@"accountStatus"] integerValue];
            currentUser.email = self.emailTextField.text;
            currentUser.password = self.passwordTextField.text;
            currentUser.serial = [[data objectForKey:@"login"] objectForKey:@"stamp"];

            currentUser.firstName = [[data objectForKey:@"login"] objectForKey:@"fname"];
            currentUser.lastName = [[data objectForKey:@"login"] objectForKey:@"lname"];
            currentUser.id = [[[data objectForKey:@"login"] objectForKey:@"uid"] integerValue];
            
            self.passwordTextField.text=@"";
        
            if (currentUser.accountStatus == 0){
                [self performSegueWithIdentifier:@"login_to_tutorial" sender:nil];
            }
            else {
                 [self performSegueWithIdentifier:@"login_to_class" sender:nil];
            }
            [hud hide:YES];
            
            
            
            //[self performSegueWithIdentifier:@"login_to_class" sender:nil];
            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [hud hide:YES];
            if (!message){
                message = @"Connection error. Please try again.";
            }
            [Utilities alertStatusWithTitle:@"Error logging in" message:message cancel:nil otherTitles:nil tag:0 view:nil];

        }
    }
    else {
        //[self alertStatus:@"Connection error" :@"Please check your connectivity and try again"];
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


- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue{
    
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
                                                                                                  NSFontAttributeName : [UIFont fontWithName:@"Gill Sans" size:23.0]
                                                                                                  }];
    self.passwordTextField.attributedPlaceholder = str;
}


@end
