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
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token];

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
    
    [self hideKeyboard ];
    
    NSMutableArray *textFields = [[NSMutableArray alloc]initWithObjects:self.classNameTextField, self.classGradeTextField, nil];
    
    NSString *errorMessage = @"";
    
    for (int i =0; i < [textFields count]; i++){
        NSString *error = [[textFields objectAtIndex:i] validate];
        if ( ![error isEqualToString:@""] ){
            errorMessage = [errorMessage stringByAppendingString:error];
            break;
        }
    }
    
    /*if (![errorMessage isEqualToString:@""]){
        [Utilities disappearingAlertView:@"Error adding class" message:errorMessage otherTitles:nil tag:0 view:self time:2.0];

        return;
        
    }*/
    /*if (self.classGradeTextField.text.length > 3){
        [Utilities disappearingAlertView:@"Error adding class" message:@"Grade must be less than 1000" otherTitles:nil tag:0 view:self time:2.0];

        return;
        
    }*/
    [self activityStart:@"Adding class..."];
    [self hideKeyboard];
    NSString *className = self.classNameTextField.text;
    NSString *classGrade = self.classGradeTextField.text;
    NSLog(@"Here is the grade \n-> %@", classGrade);
    newClass = [[class alloc]init:0 :className :classGrade :1 :1 :30 :[Utilities getCurrentDate]];
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

    if (data == nil){
        [Utilities alertStatusNoConnection];
        return;
    }

    if (type == ADD_CLASS){
        NSString *errorMessage = [data objectForKey: @"message"];

        if(!errorMessage)
        {
            AudioServicesPlaySystemSound([Utilities getTheSoundOfSuccess]);
            
            NSInteger cid = [[data objectForKey:@"class_id"] integerValue];
            [newClass setId:cid];
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
}


@end
