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
#import "FDKeychain.h"
#import <Google/Analytics.h>
#import "RootViewController.h"
#import "HomeLeftViewController.h"
#import "HomeRightViewController.h"
#import "HomeMainViewController.h"
#import "HomeNavigationController.h"


@interface LoginViewController (){
    ConnectionHandler *webHandler;
    NSMutableArray *textFields;
    NSString *errorMessage;
    user *currentUser;
    MBProgressHUD* hud;
    bool isStamping;
}
@end

@implementation LoginViewController


- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [currentUser reset];
    isStamping = NO;
    
    NSError *passwordError = nil;
    
    NSString *password = [FDKeychain itemForKey: @"password"
                                     forService: @"Classroom Hero"
                                          error: &passwordError];
    NSLog(@"Password -> %@", password);
    NSError *emailError = nil;
    
    NSString *email = [FDKeychain itemForKey: @"email"
                                  forService: @"Classroom Hero"
                                       error: &emailError];
    NSLog(@"Email -> %@", email);
    if (passwordError == nil && emailError == nil){
        self.emailTextField.text = email;
        self.passwordTextField.text = password;
    }
}


- (void) viewDidLayoutSubviews{
    if (IS_IPAD_PRO) {
        self.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:65.0];
        self.headerLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:48.0];
        self.logInButton.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:46];
        self.createAccountButton.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:46];
        self.forgotPasswordButton.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:30];
    }
}


- (void)viewDidLoad{
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:0];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImg1"]];
    
    NSArray *layers = @[self.titleLabel.layer, self.logInButton.layer, self.createAccountButton.layer, self.forgotPasswordButton.layer, self.emailTextField.layer, self.passwordTextField.layer];
    
    for (CALayer *layer in layers){
        [Utilities makeRounded:layer color:nil borderWidth:0.5f cornerRadius:5];

    }
    
}


- (IBAction)loginClicked:(id)sender{
    [self hideKeyboard];
    [[DatabaseHandler getSharedInstance] resetDatabase];
    
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


- (IBAction)createAccountClicked:(id)sender{
    [self performSegueWithIdentifier:@"login_to_account_creation" sender:self];
}


- (IBAction)aboutClicked:(id)sender{
    [self performSegueWithIdentifier:@"login_to_about" sender:self];
}


- (IBAction)forgotPasswordClicked:(id)sender {
    UIAlertView *av = [Utilities editAlertTextWithtitle:@"Password Reset" message:@"Enter your email below and we'll email you a link to reset your password" cancel:@"Cancel" done:@"Send email" delete:NO input:@"Email" tag:1 view:self capitalizationType:UITextAutocapitalizationTypeNone];
    if (self.emailTextField.text){
        [[av textFieldAtIndex:0]setText:self.emailTextField.text];
    }
}


- (IBAction)backgroundTap:(id)sender{
    [self hideKeyboard];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *email = [alertView textFieldAtIndex:0].text;
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    if (alertView.tag == 1){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                              action:@"Reset Password"
                                                               label:@"Login"
                                                               value:@1] build]];
        [self activityStart:@"Recovering password..."];

        [webHandler resetPasswordWithemail:email];
    }

}


- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    [hud hide:YES];
    
    if ([data objectForKey: @"detail"]) {
        [Utilities disappearingAlertView:@"Your session has expired" message:nil otherTitles:nil tag:10 view:self time:1.5];
        double delayInSeconds = 1.4;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"unwind_to_login" sender:self];
        });
    }
    
    if (data == nil){
        [Utilities alertStatusNoConnection];
        return;
    }
    NSString *errorMessage = [data objectForKey: @"message"];
    
    if (!errorMessage){
        if (type == LOGIN){
            
            [Utilities wiggleImage:self.stampImage sound:NO vertically:NO];
            [self loginSuccess:data];
        }
        else if (type == RESET_PASSWORD){
            [Utilities alertStatusWithTitle:@"Password recovery email sent" message:@"Check your inbox for an email containing instructions to reset your password" cancel:nil otherTitles:nil tag:0 view:nil];
        }
    }
    else {
        [Utilities alertStatusWithTitle:@"Error logging in" message:@"Invalid email / password combination" cancel:nil otherTitles:nil tag:0 view:nil];
        isStamping = NO;
    }
    
}


- (void)loginSuccess:(NSDictionary *)data{
    [[DatabaseHandler getSharedInstance] login:data];
    currentUser.email = self.emailTextField.text;
    currentUser.password = self.passwordTextField.text;
    currentUser.firstName = [data objectForKey:@"first_name"];
    currentUser.lastName = [data objectForKey:@"last_name"];
    currentUser.id = [[data objectForKey:@"id"] integerValue];
    currentUser.token = [data objectForKey:@"token"];
    
    NSError *error = nil;

    [FDKeychain saveItem: self.emailTextField.text
                  forKey: @"email"
              forService: @"Classroom Hero"
                   error: &error];
    
    [FDKeychain saveItem: self.passwordTextField.text
                  forKey: @"password"
              forService: @"Classroom Hero"
                   error: &error];
    
    [hud hide:YES];
    if ([currentUser.currentClass getId] == 0){
        [self performSegueWithIdentifier:@"login_to_create_class" sender:self];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StoryboardiPhone" bundle:nil];
        UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
        
        UITabBarController *tbc = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabBarController"];
        
        [navigationController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"]]];
        
        [tbc setViewControllers:@[navigationController]];
        
        RootViewController *rootVC = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
        rootVC.rootViewController = tbc;
        [rootVC initialize];
        
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        window.rootViewController = rootVC;
        
        [UIView transitionWithView:window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
    }
}


- (void)hideKeyboard{
    [self.view endEditing:YES];
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


- (void)activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue{
    
}


@end
