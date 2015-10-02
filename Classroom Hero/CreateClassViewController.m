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

- (IBAction)infoButtonClicked:(id)sender;

@end

@implementation CreateClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    self.schoolPicker.delegate = self;
    schoolData = [[DatabaseHandler getSharedInstance] getSchools];
    if (schoolData.count == 0){
        self.schoolPicker.hidden = YES;
        self.errorLabel.hidden = NO;
    }
    else {
        self.schoolPicker.hidden = NO;
        [self.schoolPicker selectRow:floor(schoolData.count/2) inComponent:0 animated:YES];
    }
    [Utilities setTextFieldPlaceholder:self.classNameTextField :@"Class name" :[Utilities CHBlueColor]];
    [Utilities setTextFieldPlaceholder:self.classGradeTextField :@"Class grade" :[Utilities CHBlueColor]];
    
    [Utilities makeRoundedButton:self.addClassButton :[UIColor blackColor]];
    [Utilities makeRoundedButton:self.backButton :[UIColor blackColor]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return schoolData.count;
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[schoolData objectAtIndex:row] getName];
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    index = row;
    
}


- (void)hideKeyboard{
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
            [Utilities alertStatusWithTitle:@"Error adding class" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            return;

        }
        if (self.classGradeTextField.text.length > 3){
            [Utilities alertStatusWithTitle:@"Error adding class" message:@"Grade must be 3 numbers or less"  cancel:nil otherTitles:nil tag:0 view:nil];
            return;

        }
        [self activityStart:@"Adding class..."];
        NSString *className = self.classNameTextField.text;
        NSInteger classGrade = [self.classGradeTextField.text integerValue];
        NSInteger schoolId = [self getSchoolId];
        newClass = [[class alloc]init:0 :className :classGrade :schoolId :1 :0 :30];
        [webHandler addClass:currentUser.id :className :classGrade :schoolId];
        
    }
    else {
        [Utilities alertStatusNoConnection];
    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1){
        self.classNameTextField.text = @"";
        self.classGradeTextField.text = @"";
        [self.classNameTextField becomeFirstResponder];
    }
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
}	


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        return;
    }
    if (type == ADD_CLASS){
        NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
        
        if([successNumber boolValue] == YES)
        {
            AudioServicesPlaySystemSound([Utilities getTheSoundOfSuccess]);
            NSInteger cid = [[data objectForKey:@"id"] integerValue];
            [newClass setId:cid];
            [newClass printClass];
            [[DatabaseHandler getSharedInstance]addClass:newClass];
            [hud hide:YES];
            self.classNameTextField.text = @"";
            self.classGradeTextField.text = @"";
            [Utilities alertStatusWithTitle:@"Successfully added class!" message:nil cancel:nil otherTitles:nil tag:0 view:nil];
            
            
            
        } else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing class" message:message cancel:nil otherTitles:nil tag:0 view:nil];

            [hud hide:YES];
            return;
        }
        
    }
    else if (type == ADD_CLASS){
        
    }
    else if (type == DELETE_CLASS){
        
    }
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
}


- (NSInteger)getSchoolId{
    NSInteger schoolIndex = index ;
    school *ss = [schoolData objectAtIndex:schoolIndex];
    NSInteger schoolId = [ss getId];
    return schoolId;
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




- (IBAction)infoButtonClicked:(id)sender {
    [Utilities alertStatusWithTitle:@"School Selector" message:@"If you do not see your school, contact classroomheroservices@gmail.com to get your school added" cancel:@"Close" otherTitles:nil tag:0 view:nil];
}

@end
