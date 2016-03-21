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
    BOOL isRegistered;
    BOOL isStamping;
    MBProgressHUD *hud;
    NSString *newStudentFirstName;
    NSString *newStudentLastName;
    ConnectionHandler *webHandler;
    
}

@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isStamping = NO;
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    
    [Utilities makeRoundedButton:self.studentButton :[UIColor blackColor]];
    [self configureProgressBar];
    [self setStudentLabels];
    
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)editStudentClicked:(id)sender {
    [Utilities editAlertEditStudentWithtitle:@"Edit student" message:nil cancel:@"Cancel" done:nil delete:YES textfields:@[[currentStudent getFirstName], [currentStudent getLastName]] tag:1 view:self];
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
    [hud hide:YES];
    if (data == nil){
        [Utilities alertStatusNoConnection];
    }
    
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if([successNumber boolValue] == YES){
        if (type == EDIT_STUDENT){
            [currentStudent setFirstName:newStudentFirstName];
            [currentStudent setLastName:newStudentLastName];
            [hud hide:YES];
            [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
            [self setStudentLabels];
        }
        else if (type == DELETE_STUDENT){
            [[DatabaseHandler getSharedInstance]deleteStudent:[currentStudent getId]];
            [hud hide:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (type == REGISTER_STAMP){
            [[DatabaseHandler getSharedInstance] registerStudent:[currentStudent getId] :[currentStudent getSerial]];
            
            [Utilities wiggleImage:self.stampImage sound:YES];
            self.studentButton.hidden = NO;
            self.stampToRegisterLabel.hidden = YES;
            self.stampIdLabel.text = [currentStudent getSerial];
            [currentUser.currentClass addPoints:1];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
            isRegistered = YES;
        }
        else if (type == UNREGISTER_STAMP){
            [[DatabaseHandler getSharedInstance] unregisterStudent:[currentStudent getId]];
            [Utilities wiggleImage:self.stampImage sound:YES];
            self.stampToRegisterLabel.hidden = NO;
            self.studentButton.hidden = YES;
            isRegistered = NO;
            self.stampIdLabel.text = @"No stamp registered";
        }
    }
    else {
        NSString *message = [data objectForKey:@"message"];
        NSString *errorMessage;
        
        if (type == EDIT_STUDENT){
            errorMessage = @"Error editing student";
        }
        else if (type == DELETE_STUDENT){
            errorMessage = @"Error deleting student";
        }
        else if (type == REGISTER_STAMP){
            errorMessage = @"Error registering student";
        }
        else if (type == UNREGISTER_STAMP){
            errorMessage = @"Error unregistering student";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
    }
    isStamping = NO;
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
                        [webHandler registerStamp:[currentStudent getId] :stampSerial :[currentUser.currentClass getId]];
                    }
                    else {
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


- (void)setStudentLabels{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld  Coins", (long)[currentStudent getPoints]];
    NSString *name = [currentStudent getSerial];
    if (![[currentStudent getSerial] isEqualToString:@""]){
        self.stampIdLabel.text = [currentStudent getSerial];
    }
    else {
        self.stampIdLabel.text = @"No stamp registered";
    }
    [self.progressView setProgress:(float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount] animated:YES];
    
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


- (void)configureProgressBar{
    BOOL customized = NO;
    [self.progressView setProgressBarTrackColor:[Utilities CHGreenColor]];
    [self.progressView setProgressBarWidth:(6.0f)];
    [self.progressView  setProgressBarProgressColor:[UIColor colorWithRed:233.0/255.0 green:195/255.0 blue:56.0/255.0 alpha:1.0]];
    [self.progressView setBackgroundColor:[UIColor clearColor]];
    
    [self.progressView  setHintViewSpacing:(customized ? 10.0f : 0)];
    [self.progressView  setHintViewBackgroundColor:[UIColor clearColor]];
    [self.progressView  setHintTextFont:[UIFont fontWithName:@"Gil Sans" size:12.0f]];
    [self.progressView  setHintTextColor:[UIColor blackColor]];
    [self.progressView  setHintViewSpacing:40.0f];
    [self.progressView  setHintTextGenerationBlock:(customized ? ^NSString *(CGFloat progress) {
        return [NSString stringWithFormat:@" %.0f / 255", progress * 255];
    } : nil)];
    
    
}


- (void)activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (void)setStudent:(student *)currentStudent_{
    currentStudent = currentStudent_;
}

@end
