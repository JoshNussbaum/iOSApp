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
    NSMutableDictionary *studentsData;
    student *currentStudent;
    ConnectionHandler *webHandler;
    MBProgressHUD *hud;
    NSString *studentFirstName;
    NSString *studentLastName;
    bool editingStudent;
    bool clicked;
    BOOL editing_;
    NSMutableDictionary *selectedStudents;
    NSString *tmpValue;
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
    tmpValue = @"";
    selectedStudents = [[NSMutableDictionary alloc]init];
    studentsData = [[NSMutableDictionary alloc]init];
    editingStudent = NO;
    editing_ = NO;
    self.view.backgroundColor = [Utilities CHLightBlueColor];

    currentUser = [user getInstance];
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];
    [self getStudentsData];
    
    [self.tableView setBounces:NO];
}


- (void)viewDidAppear:(BOOL)animated{
    currentUser = [user getInstance];
    clicked = NO;
    if (editingStudent) {
        [self getStudentsData];

        [self.tableView reloadData];
        editingStudent = NO;
    }
    self.backButton.enabled = YES;

}


- (void)getStudentsData{
    studentsData = [[NSMutableDictionary alloc]init];
    NSMutableArray *studentsDataArray = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES studentIds:currentUser.studentIds];
    
    for (student *tmpStudent in studentsDataArray){
        [studentsData setObject:tmpStudent forKey:[NSNumber numberWithInteger:[tmpStudent getId]]];
    }
}


- (IBAction)addStudentClicked:(id)sender {
    [Utilities editAlertAddStudentWithtitle:@"Add student" message:nil cancel:@"Cancel" done:nil delete:NO textfields:@[@"e.g. John", @"e.g. Anderson"] tag:1 view:self];
}


- (IBAction)editButtonClicked:(id)sender {
    if (editing_){
        editing_ = NO;
        [selectedStudents removeAllObjects];
    }else editing_ = YES;
    
    [self setEditing:editing_ animated:YES];
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
                [webHandler addStudent:[currentUser.currentClass getId] :studentFirstName :studentLastName];
            }
            else {
                [Utilities editAlertAddStudentWithtitle:@"Error adding student" message:errorMessage cancel:@"Cancel" done:nil delete:NO textfields:@[studentFirstName, studentLastName] tag:1 view:self];

            }
        }
        else {
            [Utilities editAlertAddStudentWithtitle:@"Error adding student" message:errorMessage cancel:@"Cancel" done:nil delete:NO textfields:@[studentFirstName, studentLastName] tag:1 view:self];
        }
    }
    else if (alertView.tag == 2){
        [self activityStart:@"Deleting Student..."];
        [webHandler deleteStudent:[currentStudent getId]];
    }
    else if (alertView.tag == 4){
        tmpValue = [alertView textFieldAtIndex:0].text;
        
        NSString *errorMessage = [Utilities isNumeric:tmpValue];
        
        if (!errorMessage) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                                  action:@"Add Uncategorized Points (Manual)"
                                                                   label:@"Uncategorized points"
                                                                   value:@1] build]];
            
            NSMutableArray *selectedStudentIds = [[NSMutableArray alloc]init];
            
            for (NSNumber *studentId in selectedStudents) {
                [selectedStudentIds addObject:studentId];
            }
            [[alertView textFieldAtIndex:0] resignFirstResponder];

            [webHandler addPointsWithStudentIds:selectedStudentIds points:tmpValue.integerValue];
        }
        else {
            [Utilities editAlertNumberWithtitle:@"Error adding points" message:errorMessage cancel:nil done:@"Add Points" input:nil tag:4 view:self];

        }
        
    }
    else if (alertView.tag == 5){
        tmpValue = [alertView textFieldAtIndex:0].text;
        
        NSString *errorMessage = [Utilities isNumeric:tmpValue];
        for (NSNumber *studentId in selectedStudents) {
            student *stud = [selectedStudents objectForKey:studentId];
            if ([stud getPoints] < tmpValue.integerValue){
                if (!errorMessage){
                    errorMessage = [NSString stringWithFormat:@"%@ only has %ld points", [stud getFirstName], (long)[stud getPoints]];
                }
                else {
                    errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@" and %@ only has %ld points", [stud getFirstName], (long)[stud getPoints]]];
                }
            }
        }
        if (!errorMessage) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                                  action:@"Subtract Points"
                                                                   label:@"Subtact points"
                                                                   value:@1] build]];
            NSMutableArray *selectedStudentIds = [[NSMutableArray alloc]init];
            
            for (NSNumber *studentId in selectedStudents) {
                [selectedStudentIds addObject:studentId];
            }
            [[alertView textFieldAtIndex:0] resignFirstResponder];

            [webHandler subtractPointsWithStudentIds:selectedStudentIds points:tmpValue.integerValue];
        }
        else {
            [Utilities editAlertNumberWithtitle:@"Error subtracting points" message:errorMessage cancel:nil done:@"Subtract Points" input:nil tag:5 view:self];
        }
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
        student *newStudent = [[student alloc]initWithid:studentId firstName:studentFirstName lastName:studentLastName  lvl:1 progress:0 lvlupamount:3 points:0 totalpoints:0 checkedin:NO hash:studentHash];
        [[DatabaseHandler getSharedInstance]addStudent:newStudent :[currentUser.currentClass getId]];
        //[studentsData addObject:newStudent];
        [studentsData setObject:newStudent forKey:[NSNumber numberWithInteger:[newStudent getId]]];
        [currentUser.studentIds addObject:[NSNumber numberWithInteger:studentId]];
        [self.tableView reloadData];
    }
    else if (type == DELETE_STUDENT){
        [studentsData removeObjectForKey:[NSNumber numberWithInteger:[currentStudent getId]]];
        //[studentsData removeObject:currentStudent];
        [currentUser.studentIds removeObject:[NSNumber numberWithInteger:[currentStudent getId]]];
        
        currentStudent = nil;
        [self.tableView reloadData];

    }
    else if (type == ADD_POINTS_BULK || SUBTRACT_POINTS_BULK){
        NSArray *studentsArray = [data objectForKey:@"students"];
        NSInteger studentCount = studentsArray.count;
        
        for (NSDictionary *studentDictionary in studentsArray){
            NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"current_coins"];
            NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"student_id"];
            NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"level"];
            NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
            NSNumber * totalPoints = (NSNumber *)[studentDictionary objectForKey: @"total_coins"];
            NSInteger lvlUpAmount = 3 + (2*(levelNumber.integerValue - 1));
            
            
            student *tmpStudent = [[DatabaseHandler getSharedInstance] getStudentWithID:idNumber.integerValue];
            
            [tmpStudent setPoints:pointsNumber.integerValue];
            [tmpStudent setLevel:levelNumber.integerValue];
            [tmpStudent setProgress:progressNumber.integerValue];
            [tmpStudent setLevelUpAmount:lvlUpAmount];
            [[DatabaseHandler getSharedInstance]updateStudent:tmpStudent];
            
            [studentsData setObject:tmpStudent forKey:idNumber];
            [selectedStudents setObject:tmpStudent forKey:idNumber];
            
        }
        [self manualPointsSuccessIsSubtract:type == ADD_POINTS_BULK ? NO : YES];
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];

        [self.tableView reloadData];
        
        for (NSIndexPath *row in selectedRows){
            [self.tableView selectRowAtIndexPath:row animated:NO scrollPosition:UITableViewScrollPositionNone];

        }
        
    }
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (void)subtractPointsClicked{
    if (editing_ && selectedStudents.count > 0){
        
        UIAlertView * av = [Utilities editAlertNumberWithtitle:@"Subtract Points" message:nil cancel:nil done:@"Subtract points" input:nil tag:5 view:self];
    }
    else {
        if (studentsData.count == 0){
            [Utilities disappearingAlertView:@"Add students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
        }
        else {
            [Utilities disappearingAlertView:@"Select students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
        }
    }
    
}


- (void)manualPointsSuccessIsSubtract:(BOOL)subtract{
    NSString *successString;
    float time = 0;
    time = 1.7;
    successString = [NSString stringWithFormat:@"%@ to %@", [NSString stringWithFormat:@"%@%@", subtract == YES ? @"-" : @"+", tmpValue], [self displayStringForMultipleSelectedStudents]];

    [Utilities disappearingAlertView:successString message:nil otherTitles:nil tag:0 view:self time:time];
}


- (NSString *)displayStringForMultipleSelectedStudents{
    int max = 55;
    NSString *displayString = @"";
    // length of ', and x others'
    int totalLength = 15;
    int skippedStudents = 0;
    for (NSInteger index = 0; index < selectedStudents.count; index++) {
        NSNumber *studentId = [[selectedStudents allKeys] objectAtIndex:index];
        
        student *selectedStudent = [studentsData objectForKey:studentId];
        NSString *firstName = [selectedStudent getFirstName];
        int len = firstName.length;
        
        if ([displayString isEqualToString:@""]){
            displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@"%@", firstName]];
        }
        
        else if ((len + totalLength) > max){
            if (index != (selectedStudents.count - 1)){
                skippedStudents += 1;
                len = 0;
                continue;
            }
            else {
                if (skippedStudents > 0) {
                    if (skippedStudents == 1){
                        displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@", and %i other", skippedStudents]];
                    }
                    else if (skippedStudents > 1){
                        displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@", %@ and %i  others", firstName, skippedStudents]];
                    }
                    
                }
                else {
                    displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@", and %@", firstName]];
                }
                return displayString;
            }
        }
        else if (index != (selectedStudents.count - 1)) {
            len += 4;
            displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@", %@", firstName]];
        }
        else {
            len += 7;
            if (skippedStudents == 1){
                displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@", %@ and %i other", firstName, skippedStudents]];
            }
            else if (skippedStudents > 1){
                displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@", %@ and %i others", firstName, skippedStudents]];
            }
            else {
                displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@", and %@", firstName]];
                
            }
        }
        totalLength += len;
        
    }
    
    return displayString;
}


- (void)addPointsClicked{
    if (editing_ && selectedStudents.count > 0){
        UIAlertView * av = [Utilities editAlertNumberWithtitle:@"Add Points" message:nil cancel:nil done:@"Add points" input:nil tag:4 view:self];

        // add points to selected students
    }
    else {
        if (studentsData.count == 0){
            [Utilities disappearingAlertView:@"Add students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
        }
        else {
            [Utilities disappearingAlertView:@"Select students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
        }
    }
    
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    // Section View
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
    
    float width = tableView.frame.size.width / 2;
    
    UIView *addPointsSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
    UIView *subtractPointsSection = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, 60)];
    
    // Add gestures to the sections
    UITapGestureRecognizer *addPointsGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(addPointsClicked)];
    [addPointsSection addGestureRecognizer:addPointsGesture];
    
    UITapGestureRecognizer *subtractPointsGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(subtractPointsClicked)];
    [subtractPointsSection addGestureRecognizer:subtractPointsGesture];

    
    
    float x = (width / 2) - 43;
    
    UILabel *addPointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
    addPointsLabel.text = @"Add Points";
    
    UILabel *subtractPointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
    subtractPointsLabel.text = @"Subtract Points";
    
    
    NSArray *labels = @[addPointsLabel, subtractPointsLabel];
    
    for (UILabel *label in labels){
        label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:23];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [Utilities CHGreenColor];
        label.layer.borderColor = [UIColor blackColor].CGColor;
        label.layer.borderWidth = 0.8;
        [Utilities makeRoundedLabel:label :[UIColor blackColor]];
    }
    
    [addPointsSection addSubview:addPointsLabel];
    [subtractPointsSection addSubview:subtractPointsLabel];
    
    NSArray *sections = @[addPointsSection, subtractPointsSection];
    for (UIView *view in sections){
        [view setBackgroundColor:[Utilities CHGreenColor]];
        
        [sectionView addSubview:view];
    }
    
    
    
    return sectionView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StudentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StudentCell" forIndexPath:indexPath];
    if (studentsData.count > 0){
        NSNumber *studentId = [[studentsData allKeys] objectAtIndex:indexPath.row];
        
        student *student_ = [studentsData objectForKey:studentId];
        [cell initializeWithStudent:student_];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:indexPath.row];
    
    currentStudent = [studentsData objectForKey:studentId];
    
    if ([selectedStudents objectForKey:studentId]){
        [selectedStudents removeObjectForKey:studentId];
    }

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:indexPath.row];
    student *tmpStudent = [studentsData objectForKey:studentId];
    currentStudent = tmpStudent;

    if (editing_ && studentsData.count > 0){
        if ([selectedStudents objectForKey:studentId]){
            [selectedStudents removeObjectForKey:studentId];
        }
        else {

            [selectedStudents setObject:tmpStudent forKey:studentId];
        }
    }
    else if (studentsData.count > 0 && !clicked){
        clicked = YES;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated { //Implement this method
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    editing_ = editing;

}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSNumber *studentId = [[studentsData allKeys] objectAtIndex:indexPath.row];

        currentStudent = [studentsData objectForKey:studentId];
        
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
