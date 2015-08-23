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
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
    SystemSoundID success;
}

@end

@implementation TutorialContentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    screenNumber = 0;
    currentUser = [user getInstance];
    
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
    self.schoolPicker.delegate = self;
    
    if (self.pageIndex == 6 && currentUser.accountStatus == 3){
        self.titleLabel.text = @"You  have  already  registered  your  a  stamp  to  your account.  Unregister  from  the  settings  menu";
    }
    else {
        self.titleLabel.text = self.titleText;
    }
    
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
            [self onPage:@"Class name" :@"Grade number" :@"Add  class" :YES :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            [self.schoolPicker selectRow:floor(self.schoolData.count/2) inComponent:0 animated:YES];
            break;
        case 2:
            [self onPage:@"Student first name" :@"Student last name" :@"Add  student" :YES :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 3:
            [self onPage:@"" :@"Positive reinforcer" :@"Add  reinforcer" :YES :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 4:
            [self onPage:@"Item name" :@"Item cost" :@"Add  item" :YES :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 5:
            [self onPage:@"Class jar name" :@"Class jar total" :@"Add  class  jar" :YES :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
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
        self.stampImage.hidden = YES;
        self.schoolPicker.hidden = NO;
        if (self.pageIndex != 1){
            if (self.classData.count == 0){
                self.schoolPicker.hidden = YES;
                self.classNameLabel.text = @"You  must  add  a  class  first!";
                self.classNameLabel.hidden = NO;
            }
            else {
                self.pickerLabel.text= @"Class Picker";
                self.pickerLabel.hidden = NO;
                //NSInteger row = self.classData.count - 1;
                for (int i=0; i <self.classData.count; i++){
                    if ([[self.classData objectAtIndex:i] getId] == currentUser.currentClassId){
                        [self.schoolPicker selectRow:i inComponent:0 animated:YES];
                        continue;
                    }
                }

                self.classNameLabel.hidden = YES;
            }
        }
        else {
            if (self.schoolData.count == 0){
                self.pickerLabel.hidden = YES;
                self.schoolPicker.hidden = YES;
                self.classNameLabel.text = @"Error loading schools";
                self.classNameLabel.hidden = NO;
            }
            else {
                self.pickerLabel.text = @"School Picker	";
                self.pickerLabel.hidden = NO;
                
                self.classNameLabel.hidden = YES;
            }

        }
    }
    else {
        if (self.pageIndex == 0 || self.pageIndex == 6){
            self.stampImage.hidden = NO;
            if (self.pageIndex == 6){
                if ([currentUser.serial isEqualToString:@""]){
                    self.titleLabel.hidden = NO;
                }
                else {
                    self.titleLabel.text = @"You  have  a  stamp  registered  to  your  account!  Unregister  from  the  my  account  page.";
                    self.titleLabel.hidden =  NO;
                }
            }
            self.pickerLabel.hidden = YES;
            self.schoolPicker.hidden = YES;
            self.classNameLabel.hidden = YES;

            
        }
        else {
            self.schoolPicker.hidden = YES;
     
        }
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
    if (self.pageIndex == 1 || self.pageIndex == 2 || self.pageIndex == 4 || self.pageIndex == 5){
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
    index = [self.schoolPicker selectedRowInComponent:0];
    [self hideKeyboard];
    if (self.pageIndex == 1){
        NSString *className = self.textField1.text;
        NSString *gradeNumber = self.textField2.text;
        NSString *classErrorMessage = [Utilities isInputValid:className :@"Class name"];
        NSInteger schoolId = [self getSchoolId];
        if ([classErrorMessage isEqualToString:@""]){
            if (![[DatabaseHandler getSharedInstance] doesClassNameExist:className]){
                NSString *gradeErrorMessage = [Utilities isNumeric:gradeNumber];
                if ([gradeErrorMessage isEqualToString:@""]) {
                    [self activityStart:@"Validating class data..."];
                    [webHandler addClass:currentUser.id :className :gradeNumber.integerValue :schoolId];
                }
                else{
                    [Utilities alertStatus:@"Error adding class" :gradeErrorMessage :@"Okay" :nil :0];
                }
            }
            else {
                [Utilities alertStatus:@"Error adding class" :[NSString stringWithFormat:@"A class with name \"%@\" already exists", className] :@"Okay" :nil :0];
            }
        }
        else{
            [Utilities alertStatus:@"Error adding class" :classErrorMessage :@"Okay" :nil :0];
        }
    }
    else{
        if (currentUser.currentClassId != 0){
            currentUser.currentClassId = [self getClassId];

            if (self.pageIndex == 2){
                NSString *firstName = self.textField1.text;
                NSString *lastName = self.textField2.text;
                NSString *firstErrorMessage = [Utilities isInputValid:firstName :@"First name"];
                if ([firstErrorMessage isEqualToString:@""]){
                    NSString *lastErrorMessage = [Utilities isInputValid:lastName :@"Last name"];
                    if ([lastErrorMessage isEqualToString:@""]) {
                        [self activityStart:@"Adding student..."];
                        [webHandler addStudent:currentUser.currentClassId :firstName :lastName];
                        
                    }
                    else {
                        [Utilities alertStatus:@"Error adding student" :lastErrorMessage :@"Okay" :nil :0];
                        return;
                    }
                }
                else {
                    [Utilities alertStatus:@"Error adding student" :firstErrorMessage :@"Okay" :nil :0];
                }
            }
            else if (self.pageIndex == 3){
                NSString *reinforcerName = self.textField2.text;
                NSString *reinforcerErrorMessage = [Utilities isInputValid:reinforcerName :@"Reinforcer name"];
                if ([reinforcerErrorMessage isEqualToString:@""]){
                    [self activityStart:@"Adding reinforcer..."];
                    [webHandler addReinforcer:currentUser.currentClassId :reinforcerName];
                }
                else {
                    [Utilities alertStatus:@"Error adding reinforcer" :reinforcerErrorMessage :@"Okay" :nil :0];
                    return;
                }
            }
            
            else if (self.pageIndex == 4){
                NSString *itemName = self.textField1.text;
                NSString *itemCost = self.textField2.text;
                
                NSString *nameErrorMessage = [Utilities isInputValid:itemName :@"Item name"];
                if ([nameErrorMessage isEqualToString:@""]){
                    NSString *costErrorMessage = [Utilities isNumeric:itemCost];
                    if ([costErrorMessage isEqualToString:@""]) {
                        [self activityStart:@"Adding item..."];
                        [webHandler addItem:currentUser.currentClassId :itemName :itemCost.integerValue];
                        
                    }
                    else {
                        [Utilities alertStatus:@"Error adding item" :costErrorMessage :@"Okay" :nil :0];
                        return;
                    }
                }
                else {
                    [Utilities alertStatus:@"Error adding item" :nameErrorMessage :@"Okay" :nil :0];
                }
            }
            else if (self.pageIndex == 5){
                NSString *jarName = self.textField1.text;
                NSString *jarCost = self.textField2.text;
                
                NSString *nameErrorMessage = [Utilities isInputValid:jarName :@"Jar name"];
                if ([nameErrorMessage isEqualToString:@""]){
                    NSString *costErrorMessage = [Utilities isNumeric:jarCost];
                    if ([costErrorMessage isEqualToString:@""]) {
                        [self activityStart:@"Adding jar..."];
                        [webHandler addJar:currentUser.currentClassId :jarName :jarCost.integerValue];
                        
                    }
                    else {
                        [Utilities alertStatus:@"Error adding jar" :costErrorMessage :@"Okay" :nil :0];
                        return;
                    }
                }
                else {
                    [Utilities alertStatus:@"Error adding jar" :nameErrorMessage :@"Okay" :nil :0];
                }
            }
        }
        else {
            [Utilities alertStatus:@"Procedural Error" :@"You must create a class first!" :@"Okay" :nil :0];
        }
     
    }
}

-(void)setTitleAndClear:(NSString *)title{
    self.titleLabel.text = title;
    self.textField1.text=@"";
    self.textField2.text=@"";

}

- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    NSLog(@"In Tutorial and here is the data =>\n %@ \nand type = %ld", data, (long)type);
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatus:@"Connection error" :@"Please check your internet connection and try again." :@"Okay" :nil :0];
        return;
    }
    NSInteger successNumber = [[data objectForKey: @"success"]integerValue];
    if (successNumber == 1 && type != GET_SCHOOLS){
        AudioServicesPlaySystemSound(success);
    }
    if (type == ADD_CLASS){
        if(successNumber == 1)
        {
            NSInteger classId = [[data objectForKey:@"id"] integerValue];

            NSInteger schoolId = index + 1;

            class *newClass = [[class alloc]init:classId :self.textField1.text :self.textField2.text.integerValue :schoolId :0 :0 :30 :0];
            [[DatabaseHandler getSharedInstance] addClass:newClass];
            currentUser.currentClassId = classId;
            currentUser.currentClassName = self.textField1.text;
            [hud hide:YES];
            [self setTitleAndClear:@"Great  job!  Add  another  class  now,  or  swipe  left  to  continue"];
            [self.textField1 becomeFirstResponder];
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatus:@"Error adding class" :message :@"Okay" :nil :0];
            [hud hide:YES];
            
        }
    }
    
    else if (type == ADD_STUDENT){
        if(successNumber == 1)
        {
            NSInteger studentId = [[data objectForKey:@"id"] integerValue];
            student *newStudent = [[student alloc]init:studentId :self.textField1.text :self.textField2.text :@"" :0 :10 :0 :0 :0 :0 :0 :0 :0 :[Utilities getDate]];
            [[DatabaseHandler getSharedInstance] addStudent:newStudent :currentUser.currentClassId];
            [hud hide:YES];
            [self setTitleAndClear:@"Great  job!  Add  another  student  now,  or  swipe  left  to  continue"];
            [self.textField1 becomeFirstResponder];
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatus:@"Error adding class" :message :@"Okay" :nil :0];
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
        [Utilities alertStatus:@"Connection error" :@"Please check your connectivity and try again" :@"Okay" :nil :0];
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
                
                
                /* ADD A WEB CALL HURR" */
                
                if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                    currentUser.serial = stampSerial;
                    [self performSegueWithIdentifier:@"tutorial_to_class" sender:nil];
                }
                
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        return;
    }
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (IBAction)backgroundTap:(id)sender {
    [self hideKeyboard];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (self.pageIndex > 1){
        return self.classData.count;
    }
    else{
        return self.schoolData.count;
    }
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.pageIndex > 1){
        NSString *title = [[self.classData objectAtIndex:row] getName];
        return title;

    }
    else{
        NSString *title = [[self.schoolData objectAtIndex:row] getName];
        return title;
    }
 
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    index = row;
    
}

-(NSInteger)getSchoolId{
    NSInteger schoolIndex = index ;
    school *ss = [self.schoolData objectAtIndex:schoolIndex];
    NSInteger schoolId = [ss getId];
    return schoolId;
}

-(NSInteger)getClassId{
    NSInteger schoolIndex = index ;
    school *cc = [self.classData objectAtIndex:schoolIndex];
    NSInteger classId = [cc getId];
    return classId;
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
