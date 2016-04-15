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
#import "Flurry.h"



@interface StampIdentifierViewController (){
    user *currentUser;
    student *currentStudent;
    bool isStamping;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
    NSString *stampSerial;
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
                stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                    [Utilities wiggleImage:self.stampImage sound:NO];
                    [self activityStart:@"Examining stamp..."];
                    [webHandler getUserBySerialWithserial:stampSerial];
                }
                else{
                    [Utilities failAnimation:self.stampImage];
                    isStamping = NO;
                }
            }
            else {
                [Utilities failAnimation:self.stampImage];
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
    if (data == nil){
        [Utilities alertStatusNoConnection];
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if([successNumber boolValue] == YES)
    {
        if (type == UNREGISTER_STAMP){
            [Utilities wiggleImage:self.stampImage sound:YES];
            [[DatabaseHandler getSharedInstance]unregisterStudent:[currentStudent getId]];
            self.studentNameLabel.hidden = YES;
            self.stampSerialLabel.hidden = YES;
            self.unregisterStampButton.hidden = YES;
            [Utilities alertStatusWithTitle:@"Successfully unregistered stamp" message:nil cancel:nil otherTitles:nil tag:0 view:self];
            if ([stampSerial isEqualToString:currentUser.serial]){
                currentUser.serial = nil;
            }
            [Utilities wiggleImage:self.stampImage sound:NO];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Unregister Stamp - Stamp Identifier" withParameters:params];
            
        }
        else if (type == GET_USER_BY_STAMP){
            NSDictionary *studentDictionary = [data objectForKey:@"user"];
            
            NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
            currentStudent = [[DatabaseHandler getSharedInstance] getStudentWithID:idNumber.integerValue];
            NSString *stamp = [studentDictionary objectForKey:@"stamp"];
            
            if (currentStudent == nil){
                NSString * fname = [studentDictionary objectForKey: @"fname"];
                NSString * lname = [studentDictionary objectForKey: @"lname"];
                currentStudent = [[student alloc] init];
                [currentStudent setId:idNumber.integerValue];
                [currentStudent setSerial:stamp];
                [currentStudent setFirstName:fname];
                [currentStudent setLastName:lname];
                
            }
            if (![stampSerial isEqualToString:currentUser.serial]){
                [[DatabaseHandler getSharedInstance]addStudent:currentStudent :-1 :[currentUser.currentClass getSchoolId]];
            }
            [self displayStudent];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Get User - Stamp Identifier" withParameters:params];
        }
        
    }
    else {
        NSString *message = [data objectForKey:@"message"];
        NSString *errorMessage;
        
        if (type == UNREGISTER_STAMP){
            errorMessage = @"Error unregistering stamp";
        }
        else if (type == GET_USER_BY_STAMP){
            errorMessage = @"Error retrieving student";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
    }
    isStamping = NO;
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
