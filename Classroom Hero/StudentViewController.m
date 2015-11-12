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
    [Utilities makeRoundedButton:self.studentButton :[UIColor blackColor]];
    
    currentUser = [user getInstance];
    
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    
    [currentStudent printStudent];
    
    [self setStudentLabels];
    
}


- (void)setStudentLabels{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level  %ld", (long)[currentStudent getLvl]];
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld  Coins", (long)[currentStudent getPoints]];
    self.levelBar.progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
    self.progressLabel.text = [NSString stringWithFormat:@"+%ld  to  Level  %ld", (long)([currentStudent getLvlUpAmount] - [currentStudent getProgress]), (long)([currentStudent getLvl]+1) ];
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
    [Utilities editAlertAddStudentWithtitle:@"Edit student" message:nil cancel:@"Cancel" done:nil delete:YES textfields:@[[currentStudent getFirstName], [currentStudent getLastName]] tag:1 view:self];
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
            
            if (!errorMessage){
                NSString *costErrorMessage = [Utilities isInputValid:newStudentLastName :@"Student Last Name"];
                if (!costErrorMessage){
                    [self activityStart:@"Editing Student..."];
                    [webHandler editStudent:[currentStudent getId] :newStudentFirstName :newStudentLastName];
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
        [webHandler unregisterStampWithid:[currentStudent getId]];
    }
    if (alertView.tag == 3){
        [self activityStart:@"Deleting student..."];
        [webHandler deleteStudent:[currentStudent getId]];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type {
    NSLog(@"In Student View Controller ready -> %@", data);
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
    else if (type == REGISTER_STAMP){
        if ([successNumber boolValue] == YES){
            [[DatabaseHandler getSharedInstance] registerStudent:[currentStudent getId] :[currentStudent getSerial]];

            [hud hide:YES];
            [Utilities wiggleImage:self.stampImage sound:YES];
            self.studentButton.hidden = NO;
            self.stampToRegisterLabel.hidden = YES;
            isRegistered = YES;
        }
        else {
            [Utilities failAnimation:self.stampImage];
        }
        isStamping = NO;
    }
    else if (type == UNREGISTER_STAMP){
        if ([successNumber boolValue] == YES){
            [[DatabaseHandler getSharedInstance] unregisterStudent:[currentStudent getId]];
            [hud hide:YES];
            [Utilities wiggleImage:self.stampImage sound:YES];
            self.stampToRegisterLabel.hidden = NO;
            self.studentButton.hidden = YES;
            isRegistered = NO;
        }
        else {
            [Utilities alertStatusNoConnection];
        }
    
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
                        [webHandler registerStamp:[currentStudent getId] :stampSerial];
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
