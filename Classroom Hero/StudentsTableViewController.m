//
//  StudentsTableViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/23/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "StudentsTableViewController.h"
#import "DatabaseHandler.h"
#import "StudentTableViewCell.h"
#import "StudentViewController.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import <Google/Analytics.h>

@interface StudentsTableViewController (){
    user *currentUser;
    NSMutableArray *studentsData;
    student *currentStudent;
    ConnectionHandler *webHandler;
    MBProgressHUD *hud;
    NSString *studentFirstName;
    NSString *studentLastName;
    bool editingStudent;
    bool clicked;
}

@end

@implementation StudentsTableViewController

- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Students"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :NO];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
    [self.tableView setBounces:NO];
}


- (void)viewDidAppear:(BOOL)animated{
    clicked = NO;
    if (editingStudent) {
        studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :NO];
        [self.tableView reloadData];
        editingStudent = NO;
    }
    self.backButton.enabled = YES;

}


- (IBAction)addStudentClicked:(id)sender {
    [Utilities editAlertAddStudentWithtitle:@"Add student" message:nil cancel:@"Cancel" done:nil delete:NO textfields:@[@"First name", @"Last name"] tag:1 view:self];
}


- (IBAction)backClicked:(id)sender {
    self.backButton.enabled = NO;
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]){
        return;
    }
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            
        }
        studentFirstName = [alertView textFieldAtIndex:0].text;
        
        studentLastName = [alertView textFieldAtIndex:1].text;
        
        NSString *errorMessage = [Utilities isInputValid:studentFirstName :@"Student first name"];
        
        if (!errorMessage){
            errorMessage = [Utilities isInputValid:studentLastName :@"Student last name"];
            if (!errorMessage){
                [self activityStart:@"Adding Student..."];
                [webHandler addStudent:[currentUser.currentClass getId] :studentFirstName :studentLastName :[currentUser.currentClass getSchoolId]];
            }
            else {
                [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            }
        }
        else {
            [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
    }
    else if (alertView.tag == 2){
        [self activityStart:@"Deleting Student..."];
        [webHandler deleteStudent:[currentStudent getId]];
    }

}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    [hud hide:YES];

    if (data == nil){
        [Utilities alertStatusNoConnection];
        return;
    }
    
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    NSString *message = [data objectForKey:@"message"];

    if (type == ADD_STUDENT){
        
        if([successNumber boolValue] == YES)
        {
            NSInteger studentId = [[data objectForKey:@"id"] integerValue];
            student *newStudent = [[student alloc]initWithid:studentId firstName:studentFirstName lastName:studentLastName serial:@"" lvl:1 progress:0 lvlupamount:3 points:0 totalpoints:0 checkedin:NO];
            [[DatabaseHandler getSharedInstance]addStudent:newStudent :[currentUser.currentClass getId] :[currentUser.currentClass getSchoolId]];
            [studentsData addObject:newStudent];
            [self.tableView reloadData];
        }
        else {
            [Utilities alertStatusWithTitle:@"Error adding student" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            return;
        }
    }
    else if (type == DELETE_STUDENT){
        if([successNumber boolValue] == YES)
        {
            [studentsData removeObject:currentStudent];
            currentStudent = nil;
            [self.tableView reloadData];
        }
        else {
            [Utilities alertStatusWithTitle:@"Error deleting student" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            return;
        }
    }
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
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
    StudentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StudentCell" forIndexPath:indexPath];
    if (studentsData.count > 0){
        student *student_ = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
        [cell initializeWithStudent:student_];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (studentsData.count > 0 && !clicked){
        clicked = YES;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        currentStudent = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
        [self performSegueWithIdentifier:@"student_segue" sender:self];
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


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        currentStudent = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
        
        [Utilities alertStatusWithTitle:@"Confirm Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [currentStudent fullName]]  cancel:@"Cancel"  otherTitles:@[@"Delete"] tag:2 view:self];
    }
}



- (void)viewDidLayoutSubviews{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"student_segue"]){
        StudentViewController *vc = [segue destinationViewController];
        [vc setStudent:currentStudent];
        editingStudent = YES;
    }
}




@end
