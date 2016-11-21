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
#import "Class.h"
#import "Utilities.h"
#import "NSString+FontAwesome.h"
#import "Flurry.h"

static int screenNumber;

@interface TutorialContentViewController (){
    user *currentUser;
    NSInteger index;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
    BOOL isStamping;
    NSArray *titles;
    class *tmpClass;
    
}

@end

@implementation TutorialContentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    titles = @[@"Swipe  left  to  create  a  class  and  register  a  teacher  stamp", @"Create  a  class", @"Add  students  to  your  selected  class", @"Assign  point  values  to  reinforcers", @"Add  items  for  students  to  spend  points  on", @"Add  a  jar  for  a  class-wide  reward", @"For  any  questions, email  classroomheroservices@gmail.com"];
    screenNumber = 0;
    isStamping = NO;
    currentUser = [user getInstance];
    
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
    [Utilities makeRoundedButton:self.button :[Utilities CHBlueColor]];
    
    
    self.schoolPicker.delegate = self;
    
    self.titleLabel.text = self.titleText;
    
    [self setPage];
}

- (void) viewDidLayoutSubviews{
    if (IS_IPAD_PRO) {
        self.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:45.0];
    }
}


- (void)setPage{
    self.titleLabel.text = titles[self.pageIndex];
    switch (self.pageIndex) {
        case 0:
            [self onPage:nil :nil :nil :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 1:
            [self onPage:@"Class name" :@"Grade number" :@"Add  class" :NO :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 2:
            [self onPage:@"Student first name" :@"Student last name" :@"Add  student" :YES :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 3:
            [self onPage:@"e.g. Participation points" :@"e.g. 3" :@"Add  reinforcer" :YES :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 4:
            [self onPage:@"e.g. Day late homework pass" :@"e.g. 30" :@"Add  item" :YES :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 5:
            [self onPage:@"e.g. Pizza party" :@"100" :@"Add  class  jar" :YES :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 6:
            [self onPage:nil :nil :nil :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            
            
        default:
            break;
    }
}


- (IBAction)backgroundTap:(id)sender{
    [self hideKeyboard];
}


- (IBAction)buttonClicked:(id)sender {
    [self handleAction];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        return;
    }
}


- (void)handleAction{
    index = [self.schoolPicker selectedRowInComponent:0];
    [self hideKeyboard];
    if (self.pageIndex == 1){
        NSString *className = self.textField1.text;
        NSString *gradeNumber = self.textField2.text;
        NSString *classErrorMessage = [Utilities isInputValid:className :@"Class name"];
        if (!classErrorMessage){
            if (![[DatabaseHandler getSharedInstance] doesClassNameExist:className]){
                NSString *gradeErrorMessage = [Utilities isNumeric:gradeNumber];
                if (!gradeErrorMessage) {
                    if (!(gradeNumber.length > 3)){
                        [self activityStart:@"Validating class data..."];
                        [webHandler addClass:currentUser.id :className :gradeNumber.integerValue :1];
                    }
                    else {
                        [Utilities alertStatusWithTitle:@"Error adding class" message:@"Grade must be less than 1000" cancel:nil otherTitles:nil tag:0 view:nil];
                    }
                    
                }
                else{
                    [Utilities alertStatusWithTitle:@"Error adding class" message:gradeErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                }
            }
            else {
                [Utilities alertStatusWithTitle:@"Error adding class" message:[NSString stringWithFormat:@"A class with name \"%@\" already exists", className] cancel:nil otherTitles:nil tag:0 view:nil];
                
            }
        }
        else{
            [Utilities alertStatusWithTitle:@"Error adding class" message:classErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            
        }
    }
    else{
        if ([tmpClass getId]  != 0){
            tmpClass = [self getClass];
            
            if (self.pageIndex == 2){
                NSString *firstName = self.textField1.text;
                NSString *lastName = self.textField2.text;
                NSString *firstErrorMessage = [Utilities isInputValid:firstName :@"First name"];
                if (!firstErrorMessage){
                    NSString *lastErrorMessage = [Utilities isInputValid:lastName :@"Last name"];
                    if (!lastErrorMessage) {
                        [self activityStart:@"Adding student..."];
                        [webHandler addStudent:[tmpClass getId] :firstName :lastName :[tmpClass getSchoolId]];
                        
                    }
                    else {
                        [Utilities alertStatusWithTitle:@"Error adding student" message:lastErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                        
                        return;
                    }
                }
                else {
                    [Utilities alertStatusWithTitle:@"Error adding student" message:firstErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                    
                }
            }
            else if (self.pageIndex == 3){
                NSString *reinforcerName = self.textField1.text;
                NSString *reinforcerValue = self.textField2.text;
                NSString *reinforcerErrorMessage = [Utilities isInputValid:reinforcerName :@"Reinforcer name"];
                if (!reinforcerErrorMessage){
                    NSString *valueErrorMessage = [Utilities isNumeric:reinforcerValue];
                    if (!valueErrorMessage) {
                        [self activityStart:@"Adding reinforcer..."];
                        [webHandler addReinforcer:[tmpClass getId] :reinforcerName :reinforcerValue.integerValue];
                    }
                    else {
                        [Utilities alertStatusWithTitle:@"Error adding reinforcer" message:valueErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                        return;
                    }
                }
                else {
                    [Utilities alertStatusWithTitle:@"Error adding reinforcer" message:reinforcerErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                    return;
                }
            }
            
            else if (self.pageIndex == 4){
                NSString *itemName = self.textField1.text;
                NSString *itemCost = self.textField2.text;
                
                NSString *nameErrorMessage = [Utilities isInputValid:itemName :@"Item name"];
                if (!nameErrorMessage){
                    NSString *costErrorMessage = [Utilities isNumeric:itemCost];
                    if (!costErrorMessage) {
                        [self activityStart:@"Adding item..."];
                        [webHandler addItem:[tmpClass getId] :itemName :itemCost.integerValue];
                        
                    }
                    else {
                        [Utilities alertStatusWithTitle:@"Error adding item" message:costErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                        
                        return;
                    }
                }
                else {
                    [Utilities alertStatusWithTitle:@"Error adding item" message:nameErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                    
                }
            }
            else if (self.pageIndex == 5){
                NSString *jarName = self.textField1.text;
                NSString *jarCost = self.textField2.text;
                
                NSString *nameErrorMessage = [Utilities isInputValid:jarName :@"Jar name"];
                if (!nameErrorMessage){
                    NSString *costErrorMessage = [Utilities isNumeric:jarCost];
                    if (!costErrorMessage && [jarCost integerValue] > 0) {
                        [self activityStart:@"Adding jar..."];
                        [webHandler addJar:[tmpClass getId] :jarName :jarCost.integerValue];
                        
                    }
                    else {
                        if (!([jarCost integerValue] > 0)){
                            costErrorMessage = @"Jar total must be greater than 0";
                        }
                        [Utilities alertStatusWithTitle:@"Error adding jar" message:costErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                        return;
                    }
                }
                else {
                    [Utilities alertStatusWithTitle:@"Error adding jar" message:nameErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                }
            }
        }
        else {
            [Utilities alertStatusWithTitle:@"Procedural Error" message:@"You must create a class first!" cancel:nil otherTitles:nil tag:0 view:nil];
        }
        
    }
}


- (void)dataReady:(NSDictionary*)data :(NSInteger)type{
    //NSLog(@"In Tutorial and here is the data =>\n %@ \nand type = %ld", data, (long)type);
    [hud hide:YES];
    if (data == nil){
        [Utilities alertStatusNoConnection];
        isStamping = NO;
        return;
    }
    NSString * compliment;
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    
    if ([successNumber boolValue] == YES){
        if (type != GET_SCHOOLS){
            AudioServicesPlaySystemSound([Utilities getAwardSound]);
            compliment = [Utilities getRandomCompliment];
        }


        if (type == ADD_CLASS){
            NSInteger classId = [[data objectForKey:@"id"] integerValue];
            class *newClass = [[class alloc]init:classId :self.textField1.text :self.textField2.text.integerValue :1 :1 :0 :30 :[Utilities getCurrentDate]];
            [[DatabaseHandler getSharedInstance] addClass:newClass];
            tmpClass = newClass;
            [self setTitleAndClear:[NSString stringWithFormat:@"%@ Add  another  class  or  swipe  left  to  continue", compliment]];
            [self.textField1 becomeFirstResponder];

            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[tmpClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add Class - Tutorial" withParameters:params];

            
        }
        
        else if (type == ADD_STUDENT){
            NSInteger studentId = [[data objectForKey:@"id"] integerValue];
            student *newStudent = [[student alloc]initWithid:studentId firstName:self.textField1.text lastName:self.textField2.text serial:@"" lvl:1 progress:0 lvlupamount:3 points:0 totalpoints:0 checkedin:NO];
            [[DatabaseHandler getSharedInstance] addStudent:newStudent :[tmpClass getId] :[tmpClass getSchoolId]];
            [self setTitleAndClear:[NSString stringWithFormat:@"%@ Add  another  student  or  swipe  left  to  continue", compliment]];
            [self.textField1 becomeFirstResponder];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[tmpClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add Student - Tutorial" withParameters:params];

        }
        
        else if (type == ADD_REINFORCER){
            NSString *reinforcerName = self.textField1.text;
            NSInteger reinforcerValue = self.textField2.text.integerValue;
            NSInteger reinforcerId = [[data objectForKey:@"id"] integerValue];
            reinforcer *newReinforcer = [[reinforcer alloc]init:reinforcerId :[tmpClass getId] :reinforcerName :reinforcerValue];
            [[DatabaseHandler getSharedInstance] addReinforcer:newReinforcer];
            [self setTitleAndClear:[NSString stringWithFormat:@"%@ Add  another  reinforcer  or  swipe  left  to  continue", compliment]];
            [self.textField1 becomeFirstResponder];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[tmpClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add Reinforcer - Tutorial" withParameters:params];
        }
        else if (type == ADD_ITEM){
            NSString *itemName = self.textField1.text;
            NSInteger itemCost = self.textField2.text.integerValue;
            NSInteger itemId = [[data objectForKey:@"id"] integerValue];
            item *newItem = [[item alloc]init:itemId :[tmpClass getId]  :itemName :itemCost];
            [[DatabaseHandler getSharedInstance] addItem:newItem];
            [self setTitleAndClear:[NSString stringWithFormat:@"%@ Add  another  item  or  swipe  left  to  continue", compliment]];
            [self.textField1 becomeFirstResponder];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[tmpClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add Item - Tutorial" withParameters:params];
        }
        
        else if (type == ADD_JAR){
            NSString *jarName = self.textField1.text;
            NSInteger jarTotal = self.textField2.text.integerValue;
            NSInteger jarId = [[data objectForKey:@"id"] integerValue];
            classjar *newJar = [[classjar alloc]initWithid:jarId cid:[tmpClass getId]  name:jarName progress:0 total:jarTotal];
            [[DatabaseHandler getSharedInstance] addClassJar:newJar];
            [self setTitleAndClear:[NSString stringWithFormat:@"%@ Replace  your  jar  or  swipe  left  to  continue", compliment]];
            [self.textField1 becomeFirstResponder];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[tmpClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add Jar - Tutorial" withParameters:params];
        }
        
        
        else{
            [Utilities alertStatusNoConnection];
        }
        NSDictionary* tmpClassDict = @{@"tmpClass": tmpClass};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetTmpClass" object:tmpClassDict];
    }
    else {
        NSString *errorMessage = nil;
        NSString *message = [data objectForKey:@"message"];
        
        if (type == ADD_CLASS){
            errorMessage = @"Error adding class";
        }
        else if (type == ADD_STUDENT){
            errorMessage = @"Error adding student";
        }
        else if (type == ADD_REINFORCER){
            errorMessage = @"Error adding reinforcer";
        }
        else if (type == ADD_ITEM){
            errorMessage = @"Error adding item";
        }
        else if (type == ADD_JAR){
            errorMessage = @"Error adding jar";
        }
        isStamping = NO;
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
    }

}


- (void)onPage:(NSString *)oneName :(NSString *)twoName :(NSString *)buttonName :(bool)picker :(UIKeyboardType)keyboard1Type :(UIKeyboardType)keyboard2Type{
    if (oneName){
        [self setFirstTextField:oneName];
        self.textField1.hidden = NO;
    }
    else {
        self.textField1.hidden = YES;
    }
    if (twoName){
        [self setSecondTextField:twoName];
        self.textField2.hidden = NO;
    }
    else {
        self.textField2.hidden = YES;
    }
    if (buttonName){
        [self.button setTitle:buttonName forState:UIControlStateNormal];
        self.button.hidden = NO;
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
                self.pickerLabel.text = @"";
            }
            else {
                self.pickerLabel.text = @"Class Selector";
                self.pickerLabel.hidden = NO;
                for (int i=0; i <self.classData.count; i++){
                    if ([[self.classData objectAtIndex:i] getId] == [tmpClass getId]){
                        [self.schoolPicker selectRow:i inComponent:0 animated:YES];
                        continue;
                    }
                }
                
                self.classNameLabel.hidden = YES;
            }
        }
    }
    else {
        if (self.pageIndex == 0 || self.pageIndex == 6){
            self.stampImage.hidden = NO;
            if (self.pageIndex == 6){
                self.titleLabel.hidden = NO;

            }
            
            
        }
        else if (self.pageIndex == 1){
            self.stampImage.hidden = YES;
        }
        self.pickerLabel.hidden = YES;
        self.schoolPicker.hidden = YES;
        self.classNameLabel.hidden = YES;
    }
    self.textField1.keyboardType = keyboard1Type;
    self.textField2.keyboardType = keyboard2Type;
    
}


- (class *)getClass{
    NSInteger classIndex = index ;
    class *cc = [self.classData objectAtIndex:classIndex];
    return cc;
}


- (void)alertStatus:(NSString *)title :(NSString *)message{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:nil,nil];
    [alertView show];
}


- (void)setFirstTextField:(NSString *)placeholder{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:placeholder attributes:nil];
    
    self.textField1.attributedPlaceholder = str;
}


- (void)setSecondTextField:(NSString *)placeholder{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:placeholder attributes:nil];
    self.textField2.attributedPlaceholder = str;
}


- (void)activityStart :(NSString *)message{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.textField1) {
        [self.textField2 becomeFirstResponder];
    }
    else {
        [self.view endEditing:YES];
    }
    return YES;
}


- (void)setTitleAndClear:(NSString *)title{
    self.titleLabel.text = title;
    self.textField1.text=@"";
    self.textField2.text=@"";

}


- (void)hideKeyboard{
    [self.view endEditing:YES];
}


#pragma mark - PickerView


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.classData.count;

}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *title = [[self.classData objectAtIndex:row] getName];
    return title;
 
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self.view endEditing:YES];
    index = row;
    
}


- (void)setTmpClass:(class *)tmpClass_{
    tmpClass = tmpClass_;
}




@end
