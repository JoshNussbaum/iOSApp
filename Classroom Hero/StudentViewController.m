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
#import <Google/Analytics.h>

@interface StudentViewController (){
    user *currentUser;
    student *currentStudent;
    BOOL isRegistered;
    BOOL isStamping;
    MBProgressHUD *hud;
    NSString *newStudentFirstName;
    NSString *newStudentLastName;
    ConnectionHandler *webHandler;
    NSInteger points;
    
}

@end

@implementation StudentViewController

- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Student"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    points = 0;
    [Utilities makeRoundedButton:self.addPointsButton :nil];
    [Utilities makeRoundedButton:self.subtractPointsButton :nil];
    
    isStamping = NO;
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
    [self configureProgressBar];
    [self setStudentLabels];
    
}


- (void)viewDidLayoutSubviews{
    if (IS_IPAD_PRO) {
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:45];
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:38];
        self.pointsLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:38];

        self.heroImage.frame = CGRectMake(335, 590, 356, 412);
    }
}


- (IBAction)addPointsClicked:(id)sender {
    [Utilities editAlertNumberWithtitle:@"Add points" message:@"Enter the number of points to add" cancel:nil done:@"Add points" input:nil tag:2 view:self];
}


- (IBAction)subtractPointsClicked:(id)sender {
    [Utilities editAlertNumberWithtitle:@"Subtract points" message:@"Enter the number of points to subtract" cancel:nil done:@"Subtract points" input:nil tag:3 view:self];
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
    
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            newStudentFirstName = [alertView textFieldAtIndex:0].text;
            newStudentLastName = [alertView textFieldAtIndex:1].text;
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
        NSString *pointsToAdd = [alertView textFieldAtIndex:0].text;
        NSString *errorMessage = [Utilities isNumeric:pointsToAdd];
        if (!errorMessage){
            points = pointsToAdd.integerValue;
            [webHandler addPointsWithStudentId:[currentStudent getId] points:points];
        }
        else {
            [Utilities alertStatusWithTitle:@"Error adding points" message:errorMessage cancel:nil otherTitles:nil tag:0 view:self];
        }
        
    }
    if (alertView.tag == 3){
        NSString *pointsToSubtract = [alertView textFieldAtIndex:0].text;
        NSString *errorMessage = [Utilities isNumeric:pointsToSubtract];
        if (!errorMessage){
            points = pointsToSubtract.integerValue;
            
            if (points < [currentStudent getPoints]){
                [webHandler subtractPointsWithStudentId:[currentStudent getId] points:points];
            }
            else {
                [Utilities alertStatusWithTitle:@"Error subtracting points" message:[NSString stringWithFormat:@"Student only has %ld points", (long)[currentStudent getPoints]] cancel:nil otherTitles:nil tag:0 view:self];
            }
            
        }
        else {
            [Utilities alertStatusWithTitle:@"Error subtracting points" message:errorMessage cancel:nil otherTitles:nil tag:0 view:self];
        }
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type {
    [hud hide:YES];
    if (data == nil){
        [Utilities alertStatusNoConnection];
        return;
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
        else if (type == ADD_POINTS || type == SUBTRACT_POINTS){
            NSDictionary *studentDictionary = [data objectForKey:@"student"];
            
            NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"currentCoins"];
            NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
            NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"lvl"];
            NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
            NSNumber * totalPoints = (NSNumber *)[studentDictionary objectForKey: @"totalCoins"];
            NSInteger lvlUpAmount = 3 + (2*(levelNumber.integerValue - 1));
            
            [currentStudent setPoints:pointsNumber.integerValue];
            [currentStudent setLevel:levelNumber.integerValue];
            [currentStudent setProgress:progressNumber.integerValue];
            [currentStudent setLevelUpAmount:lvlUpAmount];
            [currentUser.currentClass addPoints:1];
            [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
            
            [self setStudentLabels];

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
        else if (type == ADD_POINTS){
            errorMessage = @"Error adding points";
        }
        else if (type == SUBTRACT_POINTS){
            errorMessage = @"Error subtracting points";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
    }
    isStamping = NO;
}


- (void)setStudentLabels{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld  Points", (long)[currentStudent getPoints]];
    NSString *name = [currentStudent getSerial];
    [self.progressView setProgress:(float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount] animated:YES];
    
    isRegistered = ((![currentStudent.getSerial isEqualToString:@""]) || ![currentStudent getSerial]);
}


- (void)configureProgressBar{
    BOOL customized = NO;
    [self.progressView setProgressBarTrackColor:[UIColor blackColor]];
    [self.progressView setStartAngle:-90.0];

    [self.progressView setProgressBarWidth:(6.0f)];
    [self.progressView  setProgressBarProgressColor:[Utilities CHGoldColor]];
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
