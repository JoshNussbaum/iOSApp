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

@interface AttendanceViewController (){
    bool showingStudents;
    NSMutableArray *studentsData;
    user *currentUser;
    student *currentStudent;
}

@end

@implementation AttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    showingStudents = NO;
    self.studentsTableView.delegate = self;
    
    studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES];
    
    //self.studentsTableView.layer.zPosition = 10;
    
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
    NSLog(@"In table view cell for row");
    if (studentsData.count > 0){
        student *student_ = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
        [student_ printStudent];
        [cell initializeWithStudent:student_];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (studentsData.count > 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        currentStudent = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
        [currentStudent printStudent];
        if (![currentStudent getCheckedIn]){
            [Utilities editAlertTextWithtitle:[NSString stringWithFormat:@"Check in %@?", [currentStudent getFirstName]] message:nil cancel:@"Cancel" done:@"Check in" delete:NO textfields:nil tag:1 view:self];

        }
        else{
            [Utilities editAlertTextWithtitle:[NSString stringWithFormat:@"Check out %@?", [currentStudent getFirstName]] message:nil cancel:@"Cancel" done:@"Check out" delete:NO textfields:nil tag:2 view:self];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    
    if (alertView.tag == 1){
        [[DatabaseHandler getSharedInstance] updateStudentCheckedIn:[currentStudent getId] :YES];
    }
    else if (alertView.tag == 2){
        [[DatabaseHandler getSharedInstance] updateStudentCheckedIn:[currentStudent getId] :NO];

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
@end
