//
//  StudentViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/23/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "StudentViewController.h"
#import "Utilities.h"
#import "MBProgressHUD.h"


@interface StudentViewController (){
    user *currentUser;
    student *currentStudent;
    bool isRegistered;
    MBProgressHUD *hud;
    bool isStamping;
    NSString *newStudentFirstName;
    NSString *newStudentLastName;
    
    ConnectionHandler *webHandler;
    
}

@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentUser = [user getInstance];
    
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    
    [currentStudent printStudent];
    
    [self setStudentLabels];
    
}


- (void)setStudentLabels{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld Points", (long)[currentStudent getPoints]];
    self.levelBar.progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
    self.progressLabel.text = [NSString stringWithFormat:@"+%ld  Points  to  Level  %ld", (long)([currentStudent getLvlUpAmount] - [currentStudent getProgress]), (long)([currentStudent getLvl]+1) ];
    isRegistered = ((![currentStudent.getSerial isEqualToString:@""]) || ![currentStudent getSerial]);
    
    if (isRegistered){
        self.studentButton.hidden = NO;
        self.stampToRegisterLabel.hidden = YES;
    }
    else {
        self.stampToRegisterLabel.hidden = NO;
        self.studentButton.hidden = YES;
    }
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setStudent:(student *)currentStudent_{
    currentStudent = currentStudent_;
}


- (IBAction)editStudentClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Edit student" message:nil cancel:@"Cancel" done:nil delete:YES textfields:@[[currentStudent getFirstName], [currentStudent getLastName]] tag:1 view:self];
}


- (IBAction)studentButtonClicked:(id)sender {
    if (isRegistered){
        [Utilities alertStatusWithTitle:@"Unregister student stamp" message:[NSString stringWithFormat:@"Really unregister %@?", [currentStudent getFirstName]] cancel:@"Cancel" otherTitles:@[@"Unregister"] tag:2 view:self];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    newStudentFirstName = [alertView textFieldAtIndex:0].text;
    newStudentLastName = [alertView textFieldAtIndex:1].text;
    
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            NSString *errorMessage = [Utilities isInputValid:newStudentFirstName :@"Student First Name"];
            
            if ([errorMessage isEqualToString:@""]){
                NSString *costErrorMessage = [Utilities isInputValid:newStudentLastName :@"Student Last Name"];
                if ([costErrorMessage isEqualToString:@""]){
                    [self activityStart:@"Editing Student..."];
                    [webHandler editStudent:[currentStudent getId] :[currentStudent getFirstName] :[currentStudent getLastName] :[currentStudent getSerial]];
                }
                else {
                    [Utilities alertStatusWithTitle:@"Error adding item" message:costErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                    return;
                }
            }
            else {
                [Utilities alertStatusWithTitle:@"Error adding item" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            }
        }
        else if (buttonIndex == 2){
            [Utilities alertStatusWithTitle:@"Confirm delete" message:[NSString stringWithFormat:@"Really delete %@?", [currentStudent getFirstName]] cancel:@"Cancel" otherTitles:@[@"Delete"] tag:3 view:self];
        }
        
    }
    if (alertView.tag == 2){
        [self activityStart:@"Unregistering student stamp..."];
        newStudentFirstName = [currentStudent getFirstName];
        newStudentLastName  = [currentStudent getLastName];
        [webHandler editStudent:[currentStudent getId] :[currentStudent getFirstName] :[currentStudent getLastName] :@""];
    }
    if (alertView.tag == 3){
        [self activityStart:@"Deleting student..."];
        [webHandler deleteStudent:[currentStudent getId]];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type {
    NSLog(@"In market data ready -> %@", data);
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        isStamping = NO;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == EDIT_STUDENT){
        
        if([successNumber boolValue] == YES){
            [currentStudent setFirstName:newStudentFirstName];
            [currentStudent setLastName:newStudentLastName];
            [hud hide:YES];
            [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
            [self setStudentLabels];
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing student" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            
            [hud hide:YES];
            return;
        }
    }
    else if (type == DELETE_STUDENT){
        [[DatabaseHandler getSharedInstance]deleteStudent:[currentStudent getId]];
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)stampResultDidChange:(NSString *)stampResult{
    if (!isStamping){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                isStamping = YES;
                [Utilities wiggleImage:self.stampImage sound:NO];
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                
                if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                    if (![[DatabaseHandler getSharedInstance] isSerialRegistered:stampSerial] && ![stampSerial isEqualToString:currentUser.serial]){
                        [currentStudent setSerial:stampSerial];
                        [self activityStart:@"Registering student..."];
                        [webHandler editStudent:[currentStudent getId] :[currentStudent getFirstName] :[currentStudent getLastName] :stampSerial];
                    }
                    else {
                        NSLog(@"Fail stamp");
                        [Utilities failAnimation:self.stampImage];
                        isStamping = NO;
                    }
                }
                else {
                    [Utilities alertStatusWithTitle:@"Invalid Stamp" message:@"You must use a Classroom Hero stamp" cancel:nil otherTitles:nil tag:0 view:nil];
                    isStamping = NO;
                }
            }
            else {
                [Utilities failAnimation:self.stampImage];
                self.stampToRegisterLabel.text=@"Try  Stamping  Again";
                self.nameLabel.hidden = NO;
                isStamping = NO;
            }
        }
        else {
            isStamping  =  NO;
        }
    }
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
    
    

- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


@end
