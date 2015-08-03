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
#import "class.h"

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
    
    switch (self.pageIndex) {
        case 0:
            [self onPage:@"" :@"" :@"" :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 1:
            [self onPage:@"class name" :@"grade number" :@"add class" :YES :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 2:
            [self onPage:@"student first name" :@"student last name" :@"add student" :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 3:
            [self onPage:@"" :@"positive reinforcer" :@"add reinforcer" :NO :UIKeyboardTypeDefault :UIKeyboardTypeDefault];
            break;
        case 4:
            [self onPage:@"item name" :@"item cost" :@"add item" :NO :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
            break;
        case 5:
            [self onPage:@"class jar name" :@"class jar total" :@"add class jar" :NO :UIKeyboardTypeDefault :UIKeyboardTypeNumberPad];
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
        bool nameValid = [self isInputValid:className];
        NSInteger classIndex = index + 1;
        if (nameValid){
            if (![[DatabaseHandler getSharedInstance] doesClassNameExist:className]){
                bool gradeValid = [self isNumeric:gradeNumber];
                if (gradeValid) {
                    [self activityStart:@"Validating class data..."];
                    [webHandler addClass:currentUser.currentClassId :className :gradeNumber.integerValue :classIndex];
                }
            }
            else {
                [self alertStatus:@"Error adding class" :[NSString stringWithFormat:@"A class with name \"%@\" already exists", className]];
            }
        }
        else return;
    }
    else{
        if (currentUser.currentClassId != 0){
            if (self.pageIndex == 2){
                NSString *firstName = self.textField1.text;
                NSString *lastName = self.textField2.text;
                bool firstValid = [self isInputValid:firstName];
                if (firstValid){
                    bool lastValid = [self isInputValid:lastName];
                    if (lastValid ) {
                        [webHandler addStudent:currentUser.currentClassId :firstName :lastName];
                        
                    }
                    else {
                        [self alertStatus:@"Error adding student" :@"Last name is invalid"];
                        return;
                    }
                }
                else {
                    [self alertStatus:@"Error adding student" :@"First name is invalid"];
                }
            }
            else if (self.pageIndex == 3){
                NSString *categoryName = self.textField2.text;

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
    if (data == nil){
        [self alertStatus:@"Connection error" :@"Please check your internet connection and try again."];
    }
    NSLog(@"In Tutorial and here is the data =>\n %@ \nand type = %d", data, type);
    if (type == 3){
        NSInteger successNumber = [[data objectForKey: @"success"]integerValue];
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
    
    else if (type == 6){
        NSInteger successNumber = [[data objectForKey: @"success"]integerValue];
        NSInteger studentId = [[data objectForKey:@"id"] integerValue];
        if(successNumber == 1)
        {
            student *newStudent = [[student alloc]init:studentId :self.textField1.text :self.textField2.text :@"" :0 :10 :0 :0 :0 :0 :0 :0 :[self getDate]];
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
    
    else{
        [self alertStatus:@"Connection error" :@"Please check your connectivity and try again"];
    }
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *title = pickerData[row];
    return title;
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
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

- (void) alertStatus:(NSString *)title :(NSString *)message
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:@"Close"
                                             otherButtonTitles:nil,nil];
    [alertView show];
}

-(bool)isInputValid:(NSString *)input{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&'*+-/=?^_`{|}~] "];
    for (NSUInteger i = 0; i < [input length]; ++i) {
        unichar uchar = [input characterAtIndex:i] ;
        if (![characterSet characterIsMember:uchar]) {
            [self alertStatus:@"Validation error" :[NSString stringWithFormat:@"\"%c\" is an invalid character", uchar]];
            return NO;
        }
    }
    if (input.length < 1){
        [self alertStatus:@"Validation error" :[NSString stringWithFormat:@"\"%@\" is invalid input - must contain at least 1 character", input]];
        return NO;
    }
    return YES;
}

-(bool) isNumeric:(NSString *)s
{
    NSScanner *sc = [NSScanner scannerWithString: s];

    if ( [sc scanFloat:NULL] && s.integerValue >= 0)
    {
        bool numeric = [sc isAtEnd];
        if (!numeric){
            [self alertStatus:@"Validation error" :[NSString stringWithFormat:@"\"%@\" is not a positive number", s]];
        }
        return numeric;
    }
    else{
        [self alertStatus:@"Validation error" :[NSString stringWithFormat:@"%@ is not a positive number", s]];
    }
    return NO;
}

/* ------- Misc Functions ------ */
-(NSString *) getDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateAsString = [formatter stringFromDate:[NSDate date]];
    return dateAsString;
}

                                   
                                   

@end
