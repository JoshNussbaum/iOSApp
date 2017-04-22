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
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];
    
    [self configureProgressBar];
    [self setStudentLabels];
    [Utilities makeRounded:self.addPointsButton.layer color:nil borderWidth:0.5f cornerRadius:5];
    [Utilities makeRounded:self.subtractPointsButton.layer color:nil borderWidth:0.5f cornerRadius:5];

    
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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            newStudentFirstName = [alertView textFieldAtIndex:0].text;
            newStudentLastName = [alertView textFieldAtIndex:1].text;
            NSString *errorMessage = [Utilities isInputValid:newStudentFirstName :@"First name"];
            
            if (!errorMessage){
                NSString *costErrorMessage = [Utilities isInputValid:newStudentLastName :@"Last name"];
                if (!costErrorMessage){
                    [self activityStart:@"Editing Student..."];
                    [webHandler editStudent:[currentStudent getId] :newStudentFirstName :newStudentLastName];
                }
                else {
                    [Utilities editAlertAddStudentWithtitle:@"Error editing student" message:errorMessage cancel:@"Cancel" done:nil delete:NO textfields:@[newStudentLastName, newStudentLastName] tag:1 view:self];
                    return;
                }
            }
            else {
                [Utilities editAlertAddStudentWithtitle:@"Error editing student" message:errorMessage cancel:@"Cancel" done:nil delete:NO textfields:@[newStudentLastName, newStudentLastName] tag:1 view:self];
            }
        }
        else if (buttonIndex == 2){
            [Utilities alertStatusWithTitle:@"Confirm delete" message:[NSString stringWithFormat:@"Really delete %@?", [currentStudent getFirstName]] cancel:@"Cancel" otherTitles:@[@"Delete"] tag:4 view:self];
        }
        
    }
    if (alertView.tag == 2){
        NSString *pointsToAdd = [alertView textFieldAtIndex:0].text;
        NSString *errorMessage = [Utilities isNumeric:pointsToAdd];
        if (!errorMessage){
            points = pointsToAdd.integerValue;
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                                  action:@"Add Points (Student Page)"
                                                                   label:[currentStudent fullName]
                                                                   value:@1] build]];
            [[alertView textFieldAtIndex:0] resignFirstResponder];
            [webHandler addPointsWithStudentId:[currentStudent getId] points:points];
        }
        else {
            [Utilities editAlertNumberWithtitle:@"Error adding points" message:errorMessage cancel:nil done:@"Add points" input:nil tag:2 view:self];
        }
        
    }
    if (alertView.tag == 3){
        NSString *pointsToSubtract = [alertView textFieldAtIndex:0].text;
        NSString *errorMessage = nil;//[Utilities isNumeric:pointsToSubtract];
        if (!errorMessage){
            points = pointsToSubtract.integerValue;
            
            if (points < [currentStudent getPoints]){
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                                      action:@"Subtract Points (Student Page)"
                                                                       label:[currentStudent fullName]
                                                                       value:@1] build]];
                [[alertView textFieldAtIndex:0] resignFirstResponder];

                [webHandler subtractPointsWithStudentId:[currentStudent getId] points:points];
            }
            else {
                
                [Utilities editAlertNumberWithtitle:@"Error subtracting points" message:[NSString stringWithFormat:@"%@ only has %ld points", [currentStudent getFirstName], [currentStudent getPoints]] cancel:nil done:@"Subtract points" input:nil tag:3 view:self];

            }
            
        }
        else {
            [Utilities editAlertNumberWithtitle:@"Error subtracting points" message:errorMessage cancel:nil done:nil input:nil tag:3 view:self];
        }
    }
    if (alertView.tag == 4){
        [self activityStart:@"Deleting student..."];
        [webHandler deleteStudent:[currentStudent getId]];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type {
    [hud hide:YES];
    
    if ([[data objectForKey: @"detail"] isEqualToString:@"Signature has expired."]) {
        [Utilities disappearingAlertView:@"Your session has expired" message:@"Logging out..." otherTitles:nil tag:10 view:self time:2.0];
        double delayInSeconds = 1.8;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"unwind_to_login" sender:self];
        });
        return;
        
    }
    
    else if (data == nil || [data objectForKey: @"detail"]){
        [Utilities alertStatusNoConnection];
        return;
    }
    
    else if (type == EDIT_STUDENT){
        [currentStudent setFirstName:newStudentFirstName];
        [currentStudent setLastName:newStudentLastName];
        [hud hide:YES];
        [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
        [self setStudentLabels];
        
    }
    else if (type == DELETE_STUDENT){
        [[DatabaseHandler getSharedInstance]deleteStudent:[currentStudent getId]];
        [currentUser.studentIds removeObject:[NSNumber numberWithInteger:[currentStudent getId]]];
        
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (type == ADD_POINTS || type == SUBTRACT_POINTS){
        if (type == ADD_POINTS){
            [Utilities disappearingAlertView:@"Successfully added points" message:nil otherTitles:nil tag:0 view:self time:1.0];
        }
        else {
            [Utilities disappearingAlertView:@"Successfully subtracted points" message:nil otherTitles:nil tag:0 view:self time:1.0];
        }
        NSNumber * pointsNumber = (NSNumber *)[data objectForKey: @"current_coins"];
        NSNumber * idNumber = (NSNumber *)[data objectForKey: @"student_id"];
        NSNumber * levelNumber = (NSNumber *)[data objectForKey: @"level"];
        NSNumber * progressNumber = (NSNumber *)[data objectForKey: @"progress"];
        NSNumber * totalPoints = (NSNumber *)[data objectForKey: @"total_coins"];
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
    

    isStamping = NO;
}


- (void)setStudentLabels{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld  Points", (long)[currentStudent getPoints]];
    [self.progressView setProgress:(float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount] animated:YES];
    self.classHashLabel.text = [NSString stringWithFormat:@"Class ID: %@", [currentUser.currentClass getHash]];
    self.studentHashLabel.text = [NSString stringWithFormat:@"Student ID: %@", [currentStudent getHash]];
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
    [self.progressView  setHintTextFont:[UIFont fontWithName:@"Gil Sans" size:25.0f]];
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
