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
#import "Flurry.h"

@interface CreateClassViewController (){
    NSInteger index;
    MBProgressHUD *hud;
    user *currentUser;
    ConnectionHandler *webHandler;
    class *newClass;
}

@end

@implementation CreateClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];

    self.classNameTextField.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    self.classGradeTextField.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);

    [Utilities makeRoundedButton:self.addClassButton :[Utilities CHBlueColor]];
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
    
    if (![errorMessage isEqualToString:@""]){
        [Utilities alertStatusWithTitle:@"Error adding class" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        return;
        
    }
    if (self.classGradeTextField.text.length > 3){
        [Utilities alertStatusWithTitle:@"Error adding class" message:@"Grade must be 3 numbers or less"  cancel:nil otherTitles:nil tag:0 view:nil];
        return;
        
    }
    [self activityStart:@"Adding class..."];
    [self hideKeyboard];
    NSString *className = self.classNameTextField.text;
    NSInteger classGrade = [self.classGradeTextField.text integerValue];
    newClass = [[class alloc]init:0 :className :classGrade :1 :1 :0 :30 :[Utilities getCurrentDate]];
    [webHandler addClass:currentUser.id :className :classGrade :1];
    
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
    
    NSString *message = [data objectForKey:@"message"];
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];

    if (type == ADD_CLASS){
        
        if([successNumber boolValue] == YES)
        {
            AudioServicesPlaySystemSound([Utilities getTheSoundOfSuccess]);
            
            NSInteger cid = [[data objectForKey:@"id"] integerValue];
            [newClass setId:cid];
            [[DatabaseHandler getSharedInstance]addClass:newClass];
            
            self.classNameTextField.text = @"";
            self.classGradeTextField.text = @"";
            
            [Utilities alertStatusWithTitle:@"Successfully added class!" message:nil cancel:nil otherTitles:nil tag:0 view:nil];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[newClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add Class - Create Class" withParameters:params];
            
        } else {
            [Utilities alertStatusWithTitle:@"Error editing class" message:message cancel:nil otherTitles:nil tag:0 view:nil];
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
