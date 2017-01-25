//
//  CreateClassViewController.m
//  Classroom Hero
//
//  Created by Josh on 8/22/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "CreateClassViewController.h"
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import <Google/Analytics.h>

@interface CreateClassViewController (){
    NSInteger index;
    MBProgressHUD *hud;
    user *currentUser;
    ConnectionHandler *webHandler;
    class *newClass;
}

@end

@implementation CreateClassViewController


- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Create Class"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];

    self.classNameTextField.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    self.classGradeTextField.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);

    [Utilities makeRoundedButton:self.addClassButton :[Utilities CHBlueColor]];
    
}


- (void)viewDidLayoutSubviews{
    if (IS_IPAD_PRO) {
        self.addClassButton.frame = CGRectMake(425, 300, 180, 40);
    }
}


- (IBAction)addClassClicked:(id)sender {
    
    [self hideKeyboard];
    
    NSMutableArray *textFields = [[NSMutableArray alloc]initWithObjects:self.classNameTextField, self.classGradeTextField, nil];
    
    NSString *errorMessage = @"";
    
    for (int i =0; i < [textFields count]; i++){
        NSString *error = [[textFields objectAtIndex:i] validate];
        if ( ![error isEqualToString:@""] ){
            errorMessage = [errorMessage stringByAppendingString:error];
            break;
        }
    }
    
    [self activityStart:@"Adding class..."];
    [self hideKeyboard];
    NSString *className = self.classNameTextField.text;
    NSString *classGrade = self.classGradeTextField.text;
    newClass = [[class alloc]init];
    [newClass setName:className];
    [newClass setGradeNumber:classGrade];
    [webHandler addClass:currentUser.id :className :classGrade];
    
}


- (IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1){
        self.classNameTextField.text = @"";
        self.classGradeTextField.text = @"";
    }
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    [hud hide:YES];
    
    if ([[data objectForKey: @"detail"] isEqualToString:@"Signature has expired."]) {
        [Utilities disappearingAlertView:@"Your session has expired" message:@"Logging out..." otherTitles:nil tag:10 view:self time:1.5];
        double delayInSeconds = 1.4;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"unwind_to_login" sender:self];
        });
        return;
        
    }
    
    else if (data == nil || [data objectForKey: @"detail"]){
        [Utilities alertStatusNoConnection];
        return;
    }
    
    else if (type == ADD_CLASS){
        NSString *errorMessage = [data objectForKey: @"message"];

        if(!errorMessage)
        {
            AudioServicesPlaySystemSound([Utilities getTheSoundOfSuccess]);
            
            NSInteger cid = [[data objectForKey:@"class_id"] integerValue];
            NSString *classHash = [data objectForKey:@"class_hash"];
            [newClass setId:cid];
            [newClass setHash:classHash];
            [[DatabaseHandler getSharedInstance]addClass:newClass];
            
            self.classNameTextField.text = @"";
            self.classGradeTextField.text = @"";
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [Utilities disappearingAlertView:@"Error adding class" message:errorMessage otherTitles:nil tag:0 view:self time:2.0];
            return;
        }
        
    }
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.classGradeTextField) {
        [self.view endEditing:YES];
        return YES;
    }
    else if (textField == self.classNameTextField) {
        [self.classGradeTextField becomeFirstResponder];
        
    }
    return YES;
}


- (void)hideKeyboard{
    [self.view endEditing:YES];
    [self.classNameTextField resignFirstResponder];
    [self.classGradeTextField resignFirstResponder];
}


@end
