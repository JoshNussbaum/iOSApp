//
//  StampIdentifierViewController.m
//  Classroom Hero
//
//  Created by Josh on 10/19/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import "StampIdentifierViewController.h"
#import "student.h"
#import "MBProgressHUD.h"
#import "Utilities.h"
#import "DatabaseHandler.h"



@interface StampIdentifierViewController (){
    user *currentUser;
    student *currentStudent;
    bool isStamping;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
}

@end

@implementation StampIdentifierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isStamping = NO;
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    self.unregisterStampButton.hidden = YES;
    self.studentNameLabel.hidden = YES;
    self.stampSerialLabel.hidden = YES;
    
    self.appKey = snowshoe_app_key ;
    self.appSecret = snowshoe_app_secret;
    
    [Utilities makeRoundedButton:self.unregisterStampButton :nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    else{
        [self activityStart:@"Unregistering stamp..."];
        [webHandler unregisterStampWithid:[currentStudent getId]];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    [hud hide:YES];
    isStamping = NO;
    if (data == nil){
        [Utilities alertStatusNoConnection];
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == UNREGISTER_STAMP){
        
        if([successNumber boolValue] == YES)
        {
            [[DatabaseHandler getSharedInstance]unregisterStudent:[currentStudent getId]];
            self.studentNameLabel.hidden = YES;
            self.stampSerialLabel.hidden = YES;
            self.unregisterStampButton.hidden = YES;
            [Utilities alertStatusWithTitle:@"Successfully unregistered stamp" message:nil cancel:nil otherTitles:nil tag:0 view:self];
            
        }
        else{
            [Utilities failAnimation:self.stampImage];
        }
    }
    else if (type == GET_STUDENT_BY_STAMP){
        if([successNumber boolValue] == YES)
        {
            NSDictionary *studentDictionary = [data objectForKey:@"student"];
            
            NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"currentCoins"];
            NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
            NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"lvl"];
            NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
            NSNumber * totalPoints = (NSNumber *)[studentDictionary objectForKey: @"totalCoins"];
            NSInteger lvlUpAmount = 2 + (2*(levelNumber.integerValue - 1));
            
            currentStudent = [[DatabaseHandler getSharedInstance] getStudentWithID:idNumber.integerValue];
            
            if (currentStudent != nil){
                [currentStudent setPoints:pointsNumber.integerValue];
                [currentStudent setLevel:levelNumber.integerValue];
                [currentStudent setProgress:progressNumber.integerValue];
                [currentStudent setLevelUpAmount:lvlUpAmount];
                [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
            }
            else{
                NSString *stamp = [studentDictionary objectForKey:@"stamp"];
                NSString * fname = [studentDictionary objectForKey: @"fname"];
                NSString * lname = [studentDictionary objectForKey: @"lname"];
                
                currentStudent = [[student alloc]initWithid:idNumber.integerValue firstName:fname lastName:lname serial:stamp lvl:levelNumber.integerValue progress:progressNumber.integerValue lvlupamount:lvlUpAmount points:pointsNumber.integerValue totalpoints:totalPoints.integerValue checkedin:NO];
                
                [[DatabaseHandler getSharedInstance]addStudent:currentStudent :-1 :[currentUser.currentClass getSchoolId]];
            }
            [self displayStudent];
        }
        else{
            [Utilities alertStatusWithTitle:@"No student owns this stamp" message:nil cancel:nil otherTitles:nil tag:0 view:self];
        }
    }
}


- (void)displayStudent{
    self.studentNameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.stampSerialLabel.text = [currentStudent getSerial];
    
    self.studentNameLabel.hidden = NO;
    self.stampSerialLabel.hidden = NO;
    self.unregisterStampButton.hidden = NO;
}


- (IBAction)unregisterStampClicked:(id)sender {
    [self activityStart:@"Unregistering stamp..."];
    
    [webHandler unregisterStampWithid:[currentStudent getId]];
}




- (void)stampResultDidChange:(NSString *)stampResult{
    if (!isStamping){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                isStamping = YES;
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                    [self activityStart:@"Examining stamp..."];
                    [webHandler getStudentBySerialwithserial:stampSerial :[currentUser.currentClass getSchoolId]];
                }
                else{
                    [Utilities failAnimation:self.stampImage];
                    isStamping = NO;
                }
            }
        }
    }
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


@end
