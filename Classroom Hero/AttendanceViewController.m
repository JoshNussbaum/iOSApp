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
    NSInteger studentIndex;
}

@end

@implementation AttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    showingStudents = NO;
    self.studentsTableView.delegate = self;
    [self.studentsTableView setBounces:NO];

    studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES];

    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.studentsTableView]) {
        
        return NO;
    }
    if (self.studentsTableView.hidden == NO){
        [self animateTableView:YES];
    }
    return YES;
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
        [cell initializeWithStudent:student_];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (studentsData.count > 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        studentIndex = studentsData.count - indexPath.row - 1;
        currentStudent = [studentsData objectAtIndex:studentIndex];
        [currentStudent printStudent];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    
    if (alertView.tag == 1){
        [[DatabaseHandler getSharedInstance] updateStudentCheckedIn:[currentStudent getId] :YES];
        [currentStudent setCheckedIn:YES];
    }
    else if (alertView.tag == 2){
        [[DatabaseHandler getSharedInstance] updateStudentCheckedIn:[currentStudent getId] :NO];
        [currentStudent setCheckedIn:NO];
    }
    [studentsData replaceObjectAtIndex:studentIndex withObject:currentStudent];
    [studentsData sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"checkedin" ascending:NO],
      [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:NO],
      [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:NO], nil]
     ];
    [self.studentsTableView reloadData];
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
