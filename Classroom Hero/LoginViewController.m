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
    
    [[DatabaseHandler getSharedInstance] doesClassNameExist:@"rekt"];
    
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
        [webHandler logIn:self.emailTextField.text :self.passwordTextField.text];
    }
}

- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    NSLog(@"In Login baby /n %@", data);
    if (type == 1){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
        
        if([successNumber boolValue] == YES)
        {
            // Set all the user stuff and query the database
            
            [hud hide:YES];
            
        }
        else {
            [hud hide:YES];
            
        }
    }
    else {
        //[self alertStatus:@"Connection error" :@"Please check your connectivity and try again"];
    }
 
    
}


- (IBAction)createAccountClicked:(id)sender {
    [self performSegueWithIdentifier:@"login_to_account_creation" sender:self];
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue
{
    
}

@end
