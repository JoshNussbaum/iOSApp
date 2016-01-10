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

@interface AttendanceViewController (){
    BOOL showingStudents;
    BOOL isStamping;
    BOOL didManuallyCheckIn;
    NSMutableArray *studentsData;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    showingStudents = NO;
    isStamping = NO;
    self.studentsTableView.delegate = self;
    [self.studentsTableView setBounces:NO];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    // Check to see if it's a different day.
    if (!([[Utilities getCurrentDate] isEqualToString:[currentUser.currentClass getCurrentDate]])){
        [[DatabaseHandler getSharedInstance]updateAllStudentsCheckedInWithclassId:[currentUser.currentClass getId] checkedIn:NO];
        [currentUser.currentClass setCurrentDay:[Utilities getCurrentDate]];
    }
    
    studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES];
    coins = [Utilities getCoinShakeSound];

    self.studentNameLabel.hidden = YES;
    self.studentPointsLabel.hidden = YES;

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
                    
                    currentStudent = [Utilities getStudentWitharray:studentsData propertyName:@"serial" searchString:stampSerial];
                    if (currentStudent != nil){
                        if ([currentStudent getCheckedIn]){
                            [Utilities alertStatusWithTitle:[NSString stringWithFormat:@"%@ is already checked in", [currentStudent getFirstName]] message:nil cancel:nil otherTitles:nil tag:0 view:self];
                            isStamping = NO;
                        }
                        else {
                            [Utilities wiggleImage:self.stampImage sound:NO];
                            [self setStudentLabels];
                            [self checkNewDay];
                            didManuallyCheckIn = NO;
                            [webHandler checkInStudentWithstudentId:[currentStudent getId] classId:[currentUser.currentClass getId]];
                        }
                        
                    }
                    else {
                        [Utilities failAnimation:self.stampImage];
                        isStamping = NO;
                    }
                }
                else{
                    [Utilities failAnimation:self.stampImage];
                    isStamping = NO;
                }
                
            }
        }
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    if (alertView.tag == 1){
        didManuallyCheckIn = YES;
        [webHandler checkInStudentWithstudentId:[currentStudent getId] classId:[currentUser.currentClass getId]];
    }
    
    else if (alertView.tag == 2){
        didManuallyCheckIn = YES;
        [webHandler checkOutStudentWithstudentId:[currentStudent getId] classId:[currentUser.currentClass getId]];
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
    isStamping = NO;
    
    if (data == nil){
        [Utilities alertStatusNoConnection];
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    
    NSString *errorMessage = nil;
    NSString *message = [data objectForKey:@"message"];

    if (type == STUDENT_CHECK_IN){
        
        if([successNumber boolValue] == YES)
        {
            NSDictionary *studentDictionary = [data objectForKey:@"student"];
            
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
            [currentUser.currentClass addPoints:1];
            [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
            
            if (!didManuallyCheckIn){
                [self coinAnimation];
            }

            [self reloadTable];
        }
        else {
            [Utilities alertStatusWithTitle:@"Error checking student in" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            [self hideLabels];
            return;
        }
    }
    
    else if (type == STUDENT_CHECK_OUT){
        
        if([successNumber boolValue] == YES)
        {
            [[DatabaseHandler getSharedInstance] updateStudentCheckedIn:[currentStudent getId] :NO];
            [currentStudent setCheckedIn:NO];
            [self reloadTable];
            
        }
        else {
            [Utilities alertStatusWithTitle:@"Error checking student out" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            return;
        }
    }
    
    else if (type == ALL_STUDENT_CHECK_IN){
        
        if([successNumber boolValue] == YES)
        {
            
            
        }
        else {
            errorMessage = @"Error checking students in";
        }
    }
    else if (type == ALL_STUDENT_CHECK_OUT){
        
        if([successNumber boolValue] == YES)
        {
            
            
        }
        else {
            errorMessage = @"Error checking students out";
        }
    }
    
    if (errorMessage != nil){
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
    }
    [self hideLabels];


}


- (void)hideLabels{
    self.studentNameLabel.hidden = YES;
    self.studentPointsLabel.hidden = YES;
    self.sackImage.hidden = YES;
}


- (void)setStudentLabels{
    self.studentNameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.studentPointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];

    self.studentPointsLabel.hidden = NO;
    self.studentNameLabel.hidden = NO;
    self.sackImage.hidden = NO;
}


- (void)checkNewDay{
    
    if ([Utilities isNewDate:[currentUser.currentClass getCurrentDate]]){
        
        [[DatabaseHandler getSharedInstance] updateAllStudentsCheckedInWithclassId:[currentUser.currentClass getId] checkedIn:NO];
        
        [currentUser.currentClass setCurrentDay:[Utilities getCurrentDate]];
        [[DatabaseHandler getSharedInstance] editClass:currentUser.currentClass];
        
        [self.studentsTableView reloadData];
    }
}


- (void)checkOutAllStudents{
    for (student *stud in studentsData){
        [stud setCheckedIn:NO];
    }
}


- (void)checkInAllStudents{
    
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


- (void) activityStart :(NSString *)message {
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

- (void)animateCoinToSack:(UIImageView *)coin{
    [coin setFrame:CGRectMake(self.sackImage.frame.origin.x + self.sackImage.frame.size.width/2 - 30, self.sackImage.frame.origin.y+50, self.sackImage.frame.size.width-75, self.sackImage.frame.size.height-75)];
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


- (void)viewDidLayoutSubviews{
    if ([self.studentsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.studentsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.studentsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.studentsTableView setLayoutMargins:UIEdgeInsetsZero];
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
                     }
     ];
}



@end
