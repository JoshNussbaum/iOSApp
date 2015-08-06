//
//  TutorialContentViewController.m
//  Classroom Hero
//
//  Created by Josh on 7/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "TutorialContentViewController.h"
#import "MBProgressHUD.h"
#import "DatabaseHandler.h"
#import "Utilities.h"


static int screenNumber;

@interface TutorialContentViewController (){
    user *currentUser;
    NSInteger index;
    NSArray *pickerData;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
}

@end

@implementation TutorialContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    screenNumber = 0;
    currentUser = [user getInstance];
    
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
    pickerData = @[@"Strawberry Elementary School",@"Schaefer Elementary School",@"Olivet Elementary School", @"Sequoia Elementary School", @"Madrone Elementary School",@"Prior Lake-Savage Area Schools",  @"Gault Elementary School"];
    
    self.schoolPicker.delegate = self;
    
    self.titleLabel.text = self.titleText;
    
    self.appKey = snowshoe_app_key ;
    self.appSecret = snowshoe_app_secret;
    
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"award" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &success);

    
    switch (self.pageIndex) {
        case 0:
            [self onPage:@"" :@"" :@"" :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 1:
            [self onPage:@"Class Name" :@"Grade Number" :@"add class" :YES :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 2:
            [self onPage:@"Student First Name" :@"Student Last Name" :@"add student" :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 3:
            [self onPage:@"" :@"Positive Reinforcer" :@"add reinforcer" :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 4:
            [self onPage:@"Item Name" :@"Item Cost" :@"add item" :NO :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 5:
            [self onPage:@"Class Jar Name" :@"Class Jar Total" :@"add class jar" :NO :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 6:
            [self onPage:@"" :@"" :@"" :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            
            
        default:
            break;
    }

}

-(void)onPage:(NSString *)oneName :(NSString *)twoName :(NSString *)buttonName :(bool)picker :(UIKeyboardType)keyboard1Type :(UIKeyboardType)keyboard2Type{
    if (![oneName isEqualToString:@""]){
        self.textField1.placeholder = oneName;
        self.textField1.hidden = NO;
    }
    else {
       self.textField1.hidden = YES;
    }
    if (![twoName isEqualToString:@""]){
        self.textField2.placeholder = twoName;
        self.textField2.hidden = NO;
    }
    else {
        self.textField2.hidden = YES;
    }
    if (![buttonName isEqualToString:@""]){
        [self.button setTitle:buttonName forState:UIControlStateNormal];
    }
    else {
        self.button.hidden = YES;
    }
    if (picker){
        self.schoolPicker.hidden = NO;
    }
    else {
        self.schoolPicker.hidden = YES;
    }
    self.textField1.keyboardType = keyboard1Type;
    self.textField2.keyboardType = keyboard2Type;
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.pageIndex == 1 || self.pageIndex == 4 || self.pageIndex == 5){
        if (textField == self.textField1) {
            [self.textField2 becomeFirstResponder];
        }
        else {
            [self.view endEditing:YES];
        }
    }
    
    return YES;
}
- (IBAction)buttonClicked:(id)sender {
    [self handleAction];

}

-(void)handleAction{
    if (self.pageIndex == 1){
        NSString *className = self.textField1.text;
        NSString *gradeNumber = self.textField2.text;
        NSString *classErrorMessage = [Utilities isInputValid:className];
        NSInteger classIndex = index + 1;
        if ([classErrorMessage isEqualToString:@""]){
            if (![[DatabaseHandler getSharedInstance] doesClassNameExist:className]){
                NSString *gradeErrorMessage = [Utilities isNumeric:gradeNumber];
                if ([gradeErrorMessage isEqualToString:@""]) {
                    [self activityStart:@"Validating class data..."];
                    [webHandler addClass:currentUser.id :className :gradeNumber.integerValue :classIndex];
                }
                else{
                    [self alertStatus:@"Error adding class" :gradeErrorMessage];
                }
            }
            else {
                [self alertStatus:@"Error adding class" :[NSString stringWithFormat:@"A class with name \"%@\" already exists", className]];
            }
        }
        else{
            [self alertStatus:@"Error adding class" :classErrorMessage];
        }
    }
    else{
        if (currentUser.currentClassId != 0){
            if (self.pageIndex == 2){
                NSString *firstName = self.textField1.text;
                NSString *lastName = self.textField2.text;
                NSString *firstErrorMessage = [Utilities isInputValid:firstName];
                if ([firstErrorMessage isEqualToString:@""]){
                    NSString *lastErrorMessage = [Utilities isInputValid:lastName];
                    if ([lastErrorMessage isEqualToString:@""]) {
                        [webHandler addStudent:currentUser.currentClassId :firstName :lastName];
                        
                    }
                    else {
                        [self alertStatus:@"Error adding student" :lastErrorMessage];
                        return;
                    }
                }
                else {
                    [self alertStatus:@"Error adding student" :firstErrorMessage];
                }
            }
            else if (self.pageIndex == 3){
                NSString *reinforcerName = self.textField2.text;
                NSString *reinforcerErrorMessage = [Utilities isInputValid:reinforcerName];
                if ([reinforcerErrorMessage isEqualToString:@""]){
                    [webHandler addReinforcer:currentUser.currentClassId :reinforcerName];
                }
                else {
                    [self alertStatus:@"Error adding reinforcer" :reinforcerErrorMessage];
                    return;
                }
            }
            
            else if (self.pageIndex == 4){
                NSString *itemName = self.textField1.text;
                NSString *itemCost = self.textField2.text;
                
                NSString *nameErrorMessage = [Utilities isInputValid:itemName];
                if ([nameErrorMessage isEqualToString:@""]){
                    NSString *costErrorMessage = [Utilities isNumeric:itemCost];
                    if ([costErrorMessage isEqualToString:@""]) {
                        [webHandler addItem:currentUser.currentClassId :itemName :itemCost.integerValue];
                        
                    }
                    else {
                        [self alertStatus:@"Error adding item" :costErrorMessage];
                        return;
                    }
                }
                else {
                    [self alertStatus:@"Error adding item" :nameErrorMessage];
                }
            }
            else if (self.pageIndex == 5){
                NSString *jarName = self.textField1.text;
                NSString *jarCost = self.textField2.text;
                
                NSString *nameErrorMessage = [Utilities isInputValid:jarName];
                if ([nameErrorMessage isEqualToString:@""]){
                    NSString *costErrorMessage = [Utilities isNumeric:jarCost];
                    if ([costErrorMessage isEqualToString:@""]) {
                        [webHandler addItem:currentUser.currentClassId :jarName :jarCost.integerValue];
                        
                    }
                    else {
                        [self alertStatus:@"Error adding jar" :costErrorMessage];
                        return;
                    }
                }
                else {
                    [self alertStatus:@"Error adding jar" :nameErrorMessage];
                }
            }
        }
        else {
            [self alertStatus:@"Procedural Error" :@"You must create a class first!"];
        }
     
    }
}

-(void)setTitleAndClear:(NSString *)title{
    self.titleLabel.text = title;
    self.textField1.text=@"";
    self.textField2.text=@"";

}

- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    NSLog(@"In Tutorial and here is the data =>\n %@ \nand type = %d", data, type);
    if (data == nil){
        [self alertStatus:@"Connection error" :@"Please check your internet connection and try again."];
        return;
    }
    NSInteger successNumber = [[data objectForKey: @"success"]integerValue];
    if (successNumber == 1){
        AudioServicesPlaySystemSound(success);
    }
    if (type == ADD_CLASS){
        if(successNumber == 1)
        {
            NSInteger classId = [[data objectForKey:@"id"] integerValue];

            NSInteger schoolId = index + 1;
            class *newClass = [[class alloc]init:classId :self.textField1.text :self.textField2.text.integerValue :schoolId];
            [[DatabaseHandler getSharedInstance] addClass:newClass];
            currentUser.currentClassId = classId;
            [hud hide:YES];
            [self setTitleAndClear:@"Great  job!  Add  another  class  now,  or  swipe  left  to  continue"];
            [self.textField1 becomeFirstResponder];
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [self alertStatus:@"Error adding class" :message];
            [hud hide:YES];
            
        }
    }
    
    else if (type == ADD_STUDENT){
        if(successNumber == 1)
        {
            NSInteger studentId = [[data objectForKey:@"id"] integerValue];
            student *newStudent = [[student alloc]init:studentId :self.textField1.text :self.textField2.text :@"" :0 :10 :0 :0 :0 :0 :0 :0 :[Utilities getDate]];
            [[DatabaseHandler getSharedInstance] addStudent:newStudent];
            [hud hide:YES];
            [self setTitleAndClear:@"Great  job!  Add  another  student  now,  or  swipe  left  to  continue"];
            [self.textField1 becomeFirstResponder];
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [self alertStatus:@"Error adding class" :message];
            [hud hide:YES];
        }
    }
    
    else if (type == ADD_REINFORCER){
        NSString *reinforcerName = self.textField2.text;
        NSInteger reinforcerId = [[data objectForKey:@"id"] integerValue];
        reinforcer *newReinforcer = [[reinforcer alloc]init:reinforcerId :currentUser.currentClassId :reinforcerName];
        [[DatabaseHandler getSharedInstance] addReinforcer:newReinforcer];
        [hud hide:YES];
        [self setTitleAndClear:@"Superb!  Add  another  reinforcer  now,  or  swipe  left  to  continue"];
        [self.textField2 becomeFirstResponder];

    }
    else if (type == ADD_ITEM){
        NSString *itemName = self.textField1.text;
        NSInteger itemCost = self.textField2.text.integerValue;
        NSInteger itemId = [[data objectForKey:@"id"] integerValue];
        item *newItem = [[item alloc]init:itemId :currentUser.currentClassId :itemName :itemCost];
        [[DatabaseHandler getSharedInstance] addItem:newItem];
        [hud hide:YES];
        [self setTitleAndClear:@"Outstanding!  Add  another  item  now,  or  swipe  left  to  continue"];
        [self.textField1 becomeFirstResponder];
        
    }
  
    else if (type == ADD_JAR){
        NSString *jarName = self.textField1.text;
        NSInteger jarTotal = self.textField2.text.integerValue;
        NSInteger jarId = [[data objectForKey:@"id"] integerValue];
        classjar *newJar = [[classjar alloc]init:jarId :currentUser.currentClassId :jarName :0 :jarTotal];
        [[DatabaseHandler getSharedInstance] addClassJar:newJar];
        [hud hide:YES];
        [self setTitleAndClear:@"Splendid!  Add  another  jar  to  overwrite  the  one  just  added,  or  swipe  left  to  continue"];
        [self.textField2 becomeFirstResponder];
        
    }
    else{
        [self alertStatus:@"Connection error" :@"Please check your connectivity and try again"];
    }
    
}

-(void)wiggleImage{
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.chestImage center].x , [self.chestImage center].y - 3)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.chestImage center].x , [self.chestImage center].y + 3)]];
    [[self.chestImage layer] addAnimation:animation forKey:@"position"];
}

-(void)stampResultDidChange:(NSString *)stampResult{
    if (self.pageIndex == 6){
        [self wiggleImage];
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                
                if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                    currentUser.serial = stampSerial;
                    
                }
                
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        return;
    }
    else if (alertView.tag == 1){
        [self performSegueWithIdentifier:@"tutorial_content_to_login" sender:nil];
    }
}


- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *title = pickerData[row];
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    index = row;
    
}

-(NSString *)getSchoolName:(NSInteger)id{
    NSString *schoolname;
    if (id == 1){
        schoolname = @"Strawberry Elementary School";
    }
    else if (id == 2){
        schoolname = @"Schaefer Elementary School";
    }
    else if (id == 3){
        schoolname = @"Olivet Elementary School";
    }
    else if (id == 4){
        schoolname = @"Sequoia Elementary School";
    }
    else if (id == 5){
        schoolname = @"Madrone Elementary School";
    }
    else if (id == 6){
        schoolname = @"Prior Lake-Savage Area Schools";
    }
    else if (id == 7){
        schoolname = @"Gault Elementary School";
    }
    return schoolname;
}

- (void)alertStatus:(NSString *)title :(NSString *)message
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:@"Close"
                                             otherButtonTitles:nil,nil];
    [alertView show];
}


                                   
                                   

@end
