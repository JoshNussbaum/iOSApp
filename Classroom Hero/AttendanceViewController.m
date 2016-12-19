//
//  AttendanceViewController.m
//  Classroom Hero
//
//  Created by Josh on 10/11/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import "AttendanceViewController.h"
#import "StudentAttendanceTableViewCell.h"
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import <Google/Analytics.h>

@interface AttendanceViewController (){
    BOOL showingStudents;
    BOOL isStamping;
    BOOL didManuallyCheckIn;
    NSMutableArray *studentsData;
    NSMutableDictionary *checkedOutStudents;
    user *currentUser;
    student *currentStudent;
    NSInteger studentIndex;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
    NSString *stampSerial;
    CGRect coinRect;
    SystemSoundID coins;
}

@end

@implementation AttendanceViewController


- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Attendance"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.studentsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImg1"]];
    currentUser = [user getInstance];
    showingStudents = NO;
    isStamping = NO;
    self.studentsTableView.delegate = self;
    [self.studentsTableView setBounces:NO];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    checkedOutStudents = [[NSMutableDictionary alloc] init];
    // Check to see if it's a different day.
    if (!([[Utilities getCurrentDate] isEqualToString:[currentUser.currentClass getCurrentDate]])){
        [[DatabaseHandler getSharedInstance]updateAllStudentsCheckedInWithclassId:[currentUser.currentClass getId] checkedIn:NO studentIds:currentUser.studentIds];
        [currentUser.currentClass setCurrentDay:[Utilities getCurrentDate]];
    }

    studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES studentIds:currentUser.studentIds];
    [self setCheckedOutStudents];

    if ([checkedOutStudents count] > 0){
        NSNumber *studentId = [[checkedOutStudents allKeys] objectAtIndex:0];
        
        student *selectedStudent = [checkedOutStudents objectForKey:studentId];
        currentStudent = selectedStudent;
    }
    
    coins = [Utilities getCoinShakeSound];

    self.studentNameLabel.hidden = YES;
    self.studentPointsLabel.hidden = YES;
    
    self.studentsPicker.dataSource = self;
    self.studentsPicker.delegate = self;
    
    if (checkedOutStudents.count > 0){
        self.studentsPicker.hidden = NO;
        [self setStudentPreTouchLabel];
    }
    else if (!checkedOutStudents || [checkedOutStudents count] == 0){
        self.studentsPicker.hidden = YES;
        self.studentNamePreStampLabel.hidden = YES;
        self.titleLabel.text = @"All students checked in";
    }
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    if ([self.studentsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.studentsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.studentsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.studentsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if (IS_IPAD_PRO) {
        self.studentNamePreStampLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:42.0];
        self.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:50.0];
        
        self.studentNameLabel.font = [UIFont fontWithName:@"GillSans-Light" size:35];
        self.studentPointsLabel.font = [UIFont fontWithName:@"GillSans-Light" size:35];

    }
}


- (void)setCheckedOutStudents{
    for (student *tmpStudent in studentsData){
        if (![tmpStudent getCheckedIn]){
            [checkedOutStudents setObject:tmpStudent forKey:[NSNumber numberWithInteger:[tmpStudent getId]]];
        }
    }
}


- (void)viewDidAppear:(BOOL)animated{
    [self checkNewDay];
}

// ATTENDANCE CLICKED

- (IBAction)attendanceClicked:(id)sender {
    if (checkedOutStudents.count > 0){
        NSInteger index = [self.studentsPicker selectedRowInComponent:0];
        NSNumber *studentId = [[checkedOutStudents allKeys] objectAtIndex:index];
        
        student *selectedStudent = [checkedOutStudents objectForKey:studentId];
        currentStudent = selectedStudent;
        if (showingStudents){
            [self animateTableView:YES];
        }
        else if (!isStamping){
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                                  action:@"Attendance Check In (Click)"
                                                                   label:[currentStudent fullName]
                                                                   value:@1] build]];
            isStamping = YES;
            self.studentsPicker.hidden = YES;
            [Utilities wiggleImage:self.stampImage sound:NO];
            [self setStudentLabels];
            didManuallyCheckIn = NO;
            [webHandler checkInStudentWithstudentId:[currentStudent getId] classId:[currentUser.currentClass getId] stamp:YES];
        }
    }
}


- (IBAction)studentsClicked:(id)sender {
    if (self.studentsTableView.hidden){
        [self animateTableView:NO];
    }
    else{
        [self animateTableView:YES];
    }

}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)resetClicked:(id)sender {
    if (!isStamping && studentsData.count > 0 && checkedOutStudents.count != studentsData.count){
        [Utilities alertStatusWithTitle:@"Confirm action" message:@"Check out all students?" cancel:nil otherTitles:@[@"Confirm"] tag:3 view:self];
    }
}


- (IBAction)checkInAllClicked:(id)sender {
    if (checkedOutStudents.count > 0 && !isStamping){
     [Utilities alertStatusWithTitle:@"Confirm action" message:@"Check in all students?" cancel:nil otherTitles:@[@"Confirm"] tag:4 view:self];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }

    if (alertView.tag == 1){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                              action:@"Attendance Check In (Manual)"
                                                               label:[currentStudent fullName]
                                                               value:@1] build]];
        didManuallyCheckIn = YES;
        [webHandler checkInStudentWithstudentId:[currentStudent getId] classId:[currentUser.currentClass getId] stamp:NO];
    }

    else if (alertView.tag == 2){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                              action:@"Attendance Check Out (Manual)"
                                                               label:[currentStudent fullName]
                                                               value:@1] build]];
        didManuallyCheckIn = YES;
        [webHandler checkOutStudentWithstudentId:[currentStudent getId] classId:[currentUser.currentClass getId]];
    }
    else if (alertView.tag == 3){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                              action:@"Attendance Check Out All"
                                                               label:[currentUser.currentClass getName]
                                                               value:@1] build]];
        [self activityStart:@"Checking out all students"];
        
        [webHandler checkOutAllStudentsWithclassId:[currentUser.currentClass getId]];
    }
    else if (alertView.tag == 4){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                              action:@"Attendance Check In All"
                                                               label:[currentUser.currentClass getName]
                                                               value:@1] build]];
        [self activityStart:@"Checking in all students"];
        [webHandler checkInAllStudentsWithclassId:[currentUser.currentClass getId]];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.studentsTableView]) {

        return NO;
    }
    if (self.studentsTableView.hidden == NO){
        [self animateTableView:YES];
    }
    return YES;
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    [hud hide:YES];

    if (data == nil){
        isStamping = NO;
        [self hideLabels];
        [self setStudentPreTouchLabel];
        [Utilities alertStatusNoConnection];
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];

    if ([successNumber boolValue] == YES){
        //[self checkNewDay];
        if (type == STUDENT_CHECK_IN){
            NSDictionary *studentDictionary = [data objectForKey:@"student"];

            if (!didManuallyCheckIn){
                NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"currentCoins"];
                NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
                NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"lvl"];
                NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
                NSNumber * totalPoints = (NSNumber *)[studentDictionary objectForKey: @"totalCoins"];
                NSInteger lvlUpAmount = 2 + (2*(levelNumber.integerValue - 1));

                [currentStudent setPoints:pointsNumber.integerValue];
                [currentStudent setLevel:levelNumber.integerValue];
                [currentStudent setProgress:progressNumber.integerValue];
                [currentStudent setLevelUpAmount:lvlUpAmount];
                [currentStudent setCheckedIn:YES];
                [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
                [currentUser.currentClass addPoints:1];
                [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
                [checkedOutStudents removeObjectForKey:[NSNumber numberWithInteger:[currentStudent getId]]];
                
                [self coinAnimation];
                
                [self reloadTable];
                [self.studentsPicker reloadAllComponents];
            }
            else {
                [currentStudent setCheckedIn:YES];
                [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
                [checkedOutStudents removeObjectForKey:[NSNumber numberWithInteger:[currentStudent getId]]];
                
                [self reloadTable];
                [self.studentsPicker reloadAllComponents];
                [self setStudentPreTouchLabel];
            }

        }

        else if (type == STUDENT_CHECK_OUT){
            [[DatabaseHandler getSharedInstance] updateStudentCheckedIn:[currentStudent getId] :NO];
            [currentStudent setCheckedIn:NO];
            isStamping = NO;
            [checkedOutStudents setObject:currentStudent forKey:[NSNumber numberWithInteger:[currentStudent getId]]];
            self.studentsPicker.hidden = NO;
            [self.studentsPicker reloadAllComponents];
            [self setStudentPreTouchLabel];
            [self reloadTable];
        }

        else if (type == ALL_STUDENT_CHECK_IN || type == ALL_STUDENT_CHECK_OUT){
            BOOL checkedIn = (type == ALL_STUDENT_CHECK_IN ? YES: NO);
            [[DatabaseHandler getSharedInstance] updateAllStudentsCheckedInWithclassId:[currentUser.currentClass getId] checkedIn:checkedIn studentIds:currentUser.studentIds];

            [currentUser.currentClass setCurrentDay:[Utilities getCurrentDate]];
            [[DatabaseHandler getSharedInstance] editClass:currentUser.currentClass];
            studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES studentIds:currentUser.studentIds];
            [checkedOutStudents removeAllObjects];
            if (!checkedIn){
                [self setCheckedOutStudents];
            }
            
            [self.studentsTableView reloadData];
            [self.studentsPicker reloadAllComponents];
            self.studentsPicker.hidden = NO;
            [self setStudentPreTouchLabel];
            NSString *checkedInString;
            if (checkedIn) {
                checkedInString = @"in";

            }
            else {
                checkedInString = @"out";

            }
            [Utilities disappearingAlertView:[NSString stringWithFormat:@"Checked %@ all students", checkedInString] message:nil otherTitles:nil tag:0 view:self time:1.0];

        }
    }
    else {
        NSString *errorMessage = nil;
        NSString *message = [data objectForKey:@"message"];

        if (type == STUDENT_CHECK_IN){
            errorMessage = @"Error checking in";
        }
        else if (type == STUDENT_CHECK_OUT){
            errorMessage = @"Error checking out";
        }

        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
        self.studentNameLabel.hidden = YES;
        self.studentPointsLabel.hidden = YES;
        self.sackImage.hidden = YES;
        isStamping = NO;
    }

}


- (void)hideLabels{
    self.studentNameLabel.hidden = YES;
    self.studentPointsLabel.hidden = YES;
    self.sackImage.hidden = YES;
}


- (void)setStudentLabels{
    if (currentStudent == nil){
       self.studentNamePreStampLabel.text = @"All students checked in";
    }
    else {
        self.studentNameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
        self.studentPointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];
        
        self.studentPointsLabel.hidden = NO;
        self.studentNameLabel.hidden = NO;
        self.sackImage.hidden = NO;
    }
}


- (void)setStudentPreTouchLabel{
    if ([checkedOutStudents count] > 0){
        self.studentsPicker.hidden = NO;

        NSInteger index = [self.studentsPicker selectedRowInComponent:0];
        NSNumber *studentId = [[checkedOutStudents allKeys] objectAtIndex:index];
        
        student *selectedStudent = [checkedOutStudents objectForKey:studentId];
        currentStudent = selectedStudent;
        
        self.titleLabel.text = @"Tap to check in";

        self.studentNamePreStampLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
        self.studentNamePreStampLabel.hidden = NO;
        self.studentPointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];
    }
    else {
        self.studentsPicker.hidden = YES;
        self.studentNamePreStampLabel.hidden = YES;
        self.titleLabel.text = @"All students checked in";
    }

}


- (void)checkNewDay{

    if ([Utilities isNewDate:[currentUser.currentClass getCurrentDate]]){
        [self activityStart:@"Resetting attendance for new day"];
        [webHandler checkOutAllStudentsWithclassId:[currentUser.currentClass getId]];
        // Make web call to check out all students here. THen put this stuff in dataReady

    }
}


- (void)checkOutAllStudents{
    for (student *stud in studentsData){
        [stud setCheckedIn:NO];
    }
}


- (void)reloadTable{
    [studentsData sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"checkedin" ascending:NO],
      [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:NO],
      [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:NO], nil]
     ];
    [self.studentsTableView reloadData];
}


- (void)activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];

}


- (void)coinAnimation{
    [UIView animateWithDuration:.4
                     animations:^{
                         self.coinImage.alpha = 1.0;

                     }
                     completion:^(BOOL finished) {
                         double delayInSeconds = .5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.5
                                              animations:^{

                                                  [self animateCoinToSack:self.coinImage];

                                              }
                                              completion:^(BOOL finished) {
                                                  self.studentPointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];
                                                  [Utilities sackWiggle:self.sackImage];
                                                  AudioServicesPlaySystemSound(coins);

                                                  [UIView animateWithDuration:.3
                                                                   animations:^{
                                                                       [self.coinImage setFrame:coinRect];
                                                                       float progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
                                                                       self.studentPointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];

                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       double delayInSeconds = 1.0;
                                                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                           [UIView animateWithDuration:.5
                                                                                            animations:^{
                                                                                                [self hideLabels];
                                                                                            }
                                                                                            completion:^(BOOL finished) {
                                                                                                isStamping = NO;
                                                                                                [self.studentsPicker reloadAllComponents];
                                                                                                self.studentsPicker.hidden = NO;
                                                                                                [self setStudentPreTouchLabel];
                                                                                                if (checkedOutStudents.count == 0){
                                                                                                    currentStudent = nil;
                                                                                                }
                                                                                            }
                                                                            ];
                                                                       });
                                                                   }
                                                   ];
                                              }
                              ];
                         });

                     }
     ];

}


- (void)animateCoinToSack:(UIView *)coin{
    [coin setFrame:CGRectMake(self.sackImage.frame.origin.x + self.sackImage.frame.size.width/2 - 30, self.sackImage.frame.origin.y+self.sackImage.frame.size.height/2, 25, 25)];
    coin.alpha = 0.0;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return studentsData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StudentAttendanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StudentAttendanceCell" forIndexPath:indexPath];
    if (studentsData.count > 0){
        student *student_ = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
        [cell initializeWithStudent:student_];
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (studentsData.count > 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        studentIndex = studentsData.count - indexPath.row - 1;
        currentStudent = [studentsData objectAtIndex:studentIndex];
        if (![currentStudent getCheckedIn]){
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Check in %@?", [currentStudent getFirstName]]
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Yes", nil];
            [alertView setTag:1];
            [alertView show];

        }
        else{
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Check out %@?", [currentStudent getFirstName]]
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Yes", nil];
            [alertView setTag:2];
            [alertView show];
        }
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



- (void)animateTableView:(BOOL)open{
    if (!open){
        self.studentsTableView.alpha = 0.0;
    }
    [UIView animateWithDuration:.2
                     animations:^{

                         if (open){
                             self.studentsTableView.alpha = 0.0;
                         }else{
                             self.studentsTableView.alpha = 1.0;
                             self.studentsTableView.hidden = open;
                         }
                     }
                     completion:^(BOOL finished) {
                         self.studentsTableView.hidden = open;
                         if (open){
                             showingStudents = NO;
                         }
                         else {
                             showingStudents = YES;
                         }
                     }
     ];
}


#pragma mark - Picker view

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return checkedOutStudents.count;
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSNumber *studentId = [[checkedOutStudents allKeys] objectAtIndex:row];

    student *tmpStudent = [checkedOutStudents objectForKey:studentId];
    return [NSString stringWithFormat:@"%@ %@", [tmpStudent getFirstName], [tmpStudent getLastName]];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    // do stuff here
    [self setStudentPreTouchLabel];
    
}


- (IBAction)unwindToAward:(UIStoryboardSegue *)unwindSegue {
    
}



@end
