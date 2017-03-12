//
//  AddStudentViewController.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 2/7/17.
//  Copyright © 2017 Josh Nussbaum. All rights reserved.
//

#import "AddStudentViewController.h"
#import "Utilities.h"
#import "DatabaseHandler.h"
#import "StudentAwardTableViewCell.h"
#import "RootViewController.h"
#import "MBProgressHUD.h"

@interface AddStudentViewController (){
    user *currentUser;
    ConnectionHandler *webHandler;
    NSInteger flag;
    NSInteger selectedRow;
    student *selectedStudent;
    
    NSString *newStudentFirstName;
    NSString *newStudentLastName;
    
    MBProgressHUD *hud;
}

@end

@implementation AddStudentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];
    
    self.studentsTableView.delegate = self;
    self.studentsTableView.dataSource = self;
    
    if (flag == 1){
        self.continueButton.hidden = YES;
    }
    else {
        self.continueButton.hidden = NO;
    }
    self.studentsTableView.layer.borderWidth = 1.0;
    self.studentsTableView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.studentsTableView setAllowsSelection:YES];
    if (currentUser.students.count > 0){
        self.studentsTableView.hidden = NO;
    } else {
        self.studentsTableView.hidden = YES;
        [self.continueButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
        self.continueButton.enabled = NO;
    }
    
}


- (student *)getStudent:(NSIndexPath *)indexPath{
    NSInteger studentIndex = indexPath.row;
    NSNumber *studentId = [[currentUser.students allKeys] objectAtIndex:studentIndex];
    student *selectedStudent_ = [currentUser.students objectForKey:studentId];
    return selectedStudent_;
}


#pragma mark AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            newStudentFirstName = [alertView textFieldAtIndex:0].text;
            newStudentLastName = [alertView textFieldAtIndex:1].text;
            NSString *firstNameErrorMessage = [Utilities isInputValid:newStudentFirstName :@"First Name"];
            
            if (!firstNameErrorMessage){
                NSString *lastNameErrorMessage = [Utilities isInputValid:newStudentLastName :@"Last Name"];
                if (!lastNameErrorMessage){
                    [self activityStart:@"Editing student..."];
                    [webHandler editStudent:[selectedStudent getId] :newStudentFirstName :newStudentLastName];
                }
                else {
                    [Utilities editAlertAddStudentWithtitle:@"Error editing student" message:lastNameErrorMessage cancel:@"Cancel" done:@"Edit student" delete:NO textfields:@[[selectedStudent getFirstName], [selectedStudent getLastName]] tag:1 view:self];
                }
            }
            else {
                [Utilities editAlertAddStudentWithtitle:@"Error editing student" message:firstNameErrorMessage cancel:@"Cancel" done:@"Edit student" delete:NO textfields:@[[selectedStudent getFirstName], [selectedStudent getLastName]] tag:1 view:self];
            }
        }
        else if (buttonIndex == 2){
            [Utilities alertStatusWithTitle:@"Confirm delete" message:[NSString stringWithFormat:@"Really delete %@?", [selectedStudent getFirstName]] cancel:@"Cancel" otherTitles:@[@"Delete"] tag:2 view:self];
        }

    }
    else if (alertView.tag == 2){
        [self activityStart:@"Deleting student..."];
        [webHandler deleteStudent:[selectedStudent getId]];
    }
    
}


#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return currentUser.students.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([Utilities isIPhone]){
        return 45;
    }
    else {
        return 75;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StudentAwardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddStudentCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    
    NSNumber *studentId = [[currentUser.students allKeys] objectAtIndex:indexPath.row];
    
    student *student_ = [currentUser.students objectForKey:studentId];
    selectedStudent = student_;
    [cell initializeWithStudent:student_ selected:NO];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectStudent:)];
    [cell addGestureRecognizer:tap];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}


- (void)selectStudent:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.studentsTableView];
    
    NSIndexPath *indexPath = [self.studentsTableView indexPathForRowAtPoint:point];
    selectedRow = indexPath.row;
    selectedStudent = [self getStudent:indexPath];
    [Utilities editTextWithtitle:@"Edit Student" message:nil cancel:@"Cancel" done:@"Edit student" delete:YES textfields:@[[selectedStudent getFirstName], [selectedStudent getLastName]] tag:1 view:self];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        student *selectedStudent_ = [self getStudent:indexPath];
        
        [Utilities alertStatusWithTitle:@"Confirm Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [selectedStudent_ getFirstName]]  cancel:@"Cancel"  otherTitles:@[@"Delete"] tag:2 view:self];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
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
    else if (type == ADD_STUDENT){
        NSInteger studentId = [[data objectForKey:@"student_id"] integerValue];
        NSString *studentHash = [data objectForKey:@"student_hash"];
        student *newStudent = [[student alloc]initWithid:studentId firstName:newStudentFirstName lastName:newStudentLastName lvl:1 progress:0 lvlupamount:3 points:0 totalpoints:0 checkedin:NO hash:studentHash];
        [[DatabaseHandler getSharedInstance] addStudent:newStudent :[currentUser.currentClass getId]];
        [currentUser.students setObject:newStudent forKey:[NSNumber numberWithInteger:studentId]];
        self.studentNameTextField.text = @"";
        [self.studentsTableView reloadData];
        self.studentsTableView.hidden = NO;
        [self.studentNameTextField becomeFirstResponder];
        [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.continueButton.enabled = YES;
    }
    else if (type == DELETE_STUDENT){
        [[DatabaseHandler getSharedInstance]deleteStudent:[selectedStudent getId]];
        [currentUser.students removeObjectForKey:[NSNumber numberWithInteger:[selectedStudent getId]]];
        selectedStudent = nil;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
        NSArray *indexPaths = @[indexPath];
        [self.studentsTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        if (currentUser.students.count == 0){
            self.studentsTableView.hidden = YES;
            [self.continueButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
            self.continueButton.enabled = NO;

        }
    }
    else if (type == EDIT_STUDENT){
        [selectedStudent setFirstName:newStudentFirstName];
        [selectedStudent setLastName:newStudentLastName];
        [hud hide:YES];
        [[DatabaseHandler getSharedInstance]updateStudent:selectedStudent];
        [currentUser.students setObject:selectedStudent forKey:[NSNumber numberWithInteger:[selectedStudent getId]]];
        [currentUser.students setObject:selectedStudent forKey:[NSNumber numberWithInteger:[selectedStudent getId]]];
        [self.studentsTableView reloadData];

    }
    
}


- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}


- (IBAction)backClicked:(id)sender {
    [self performSegueWithIdentifier:@"unwind_to_login" sender:self];
}


- (IBAction)continueClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StoryboardiPhone" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
    
    [navigationController setViewControllers:@[[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"]]];
    
    
    RootViewController *rootVC = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
    rootVC.rootViewController = navigationController;
    [rootVC initialize];
    
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    window.rootViewController = rootVC;
    
    [UIView transitionWithView:window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}


- (IBAction)addStudentClicked:(id)sender {
    NSString *fullName = self.studentNameTextField.text;
    NSRange range = [fullName rangeOfString:@" "];
    if (range.location == NSNotFound){
        [Utilities disappearingAlertView:@"Student must have first and last name separated by a space." message:nil otherTitles:nil tag:0 view:self time:2.0];
        return;
    }
    newStudentFirstName = [fullName substringToIndex:range.location];
    
    newStudentLastName = [fullName substringFromIndex:range.location+1];
    
    NSString *firstErrorMessage = [Utilities isInputValid:newStudentFirstName :@"First name"];
    if (!firstErrorMessage){
        NSString *lastErrorMessage = [Utilities isInputValid:newStudentLastName :@"Last name"];
        if (!lastErrorMessage) {
            [self activityStart:@"Adding student..."];
            [webHandler addStudent:[currentUser.currentClass getId] :newStudentFirstName :newStudentLastName];
            
        }
        else {
            [Utilities disappearingAlertView:@"Error adding student" message:lastErrorMessage otherTitles:nil tag:0 view:self time:2.0];
            
            return;
        }
    }
    else {
        [Utilities disappearingAlertView:@"Error adding student" message:firstErrorMessage otherTitles:nil tag:0 view:self time:2.0];
        
    }
}


- (void)activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
}


@end
