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


- (IBAction)unregisterStampClicked:(id)sender {
    [self activityStart:@"Unregistering stamp..."];
    [webHandler unregisterStampWithid:[currentStudent getId]];
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
                    [webHandler getUserBySerialWithserial:stampSerial];
                }
                else{
                    [Utilities failAnimation:self.stampImage];
                    isStamping = NO;
                }
            }
        }
    }
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
            [Utilities wiggleImage:self.stampImage sound:YES];
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
    else if (type == GET_USER_BY_STAMP){
        if([successNumber boolValue] == YES)
        {
            NSDictionary *studentDictionary = [data objectForKey:@"user"];
            
            NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
            currentStudent = [[DatabaseHandler getSharedInstance] getStudentWithID:idNumber.integerValue];
            
            if (currentStudent == nil){
                NSString *stamp = [studentDictionary objectForKey:@"stamp"];
                NSString * fname = [studentDictionary objectForKey: @"fname"];
                NSString * lname = [studentDictionary objectForKey: @"lname"];
                
                currentStudent = [[student alloc] init];
                [currentStudent setId:idNumber.integerValue];
                [currentStudent setSerial:stamp];
                [currentStudent setFirstName:fname];
                [currentStudent setLastName:lname];
                
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


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


@end
