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

@interface CreateClassViewController (){
    NSInteger index;
    NSMutableArray *schoolData;
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
    
    schoolData = [[DatabaseHandler getSharedInstance] getSchools];
    
    if (schoolData.count == 0){
        self.errorLabel.hidden = NO;
    }
    // Do any additional setup after loading the view.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return schoolData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[schoolData objectAtIndex:row] getName];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    index = row;
    
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (IBAction)addClassClicked:(id)sender {
    if (schoolData.count > 0 ){
        index = [self.schoolPicker selectedRowInComponent:0];
        
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
            [Utilities alertStatus:@"Error adding class" :errorMessage :@"Okay" :nil :0];
        }
        else {
            NSString *className = self.classNameTextField.text;
            NSInteger classGrade = [self.classGradeTextField.text integerValue];
            NSInteger schoolId = [self getSchoolId];
            newClass = [[class alloc]init:0 :className :classGrade :schoolId :0 :0 :30 :0];
            [webHandler addClass:currentUser.id :className :classGrade :schoolId];
            
        }
    }
    else {
        [Utilities alertStatus:@"Connection error" :@"Error loading schools, please try again" :@"Okay" :nil :0];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1){
        [self performSegueWithIdentifier:@"create_class_to_class" sender:nil];
    }
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
}


-(void)dataReady:(NSDictionary *)data :(NSInteger)type{
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatus:@"Connection error" :@"Please check your internet connection and try again." :@"Okay" :nil :0];
        return;
    }
    if (type == ADD_CLASS){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
        
        if([successNumber boolValue] == YES)
        {
            NSInteger cid = [[data objectForKey:@"id"] integerValue];
            [newClass setId:cid];
            NSLog(@"We just added this class");
            [newClass printClass];
            [[DatabaseHandler getSharedInstance]addClass:newClass];

            [Utilities alertStatus:@"Successfully added class!" :nil :@"Okay" :nil :1];
            
            
        } else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatus:@"Error editing class" :message :@"Okay" :nil :0];
            [hud hide:YES];
            return;
        }
        
    }
    else if (type == ADD_CLASS){
        
    }
    else if (type == DELETE_CLASS){
        
    }
}


-(void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}

-(IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
}

-(NSInteger)getSchoolId{
    NSInteger schoolIndex = index ;
    school *ss = [schoolData objectAtIndex:schoolIndex];
    NSInteger schoolId = [ss getId];
    return schoolId;
}


@end
