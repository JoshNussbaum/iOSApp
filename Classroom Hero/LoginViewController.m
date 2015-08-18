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

-(void)viewDidAppear:(BOOL)animated{
    [currentUser reset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        [self.view endEditing:YES];
        return YES;
    }
    else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
        
    }
    return YES;
}

- (IBAction)loginClicked:(id)sender {
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
        [Utilities alertStatus:@"Error logging in" :errorMessage :@"Okay" :nil :0];
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
            currentUser.firstName = [[data objectForKey:@"login"] objectForKey:@"fname"];
            currentUser.lastName = [[data objectForKey:@"login"] objectForKey:@"lname"];
            currentUser.id = [[[data objectForKey:@"login"] objectForKey:@"uid"] integerValue];
            
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
            [Utilities alertStatus:@"Error logging in" :message :@"Okay" :nil :0];
            //+ (void) alertStatus:(NSString *)title :(NSString *)message :(NSString *)cancel :(NSArray *)otherTitles :(NSInteger)tag

        }
    }
    else {
        //[self alertStatus:@"Connection error" :@"Please check your connectivity and try again"];
    }
 
    
}


- (IBAction)createAccountClicked:(id)sender {
    [self performSegueWithIdentifier:@"login_to_account_creation" sender:self];
}

- (IBAction)aboutClicked:(id)sender {
    [self performSegueWithIdentifier:@"login_to_about" sender:self];
}

- (IBAction)pricingClicked:(id)sender {
    [self performSegueWithIdentifier:@"login_to_pricing" sender:self];
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue
{
    
}

@end
