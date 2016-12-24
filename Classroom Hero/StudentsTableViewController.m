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
    BOOL editing_;
    NSMutableArray *selectedStudentIds;
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
    selectedStudentIds = [[NSMutableArray alloc]init];
    editingStudent = NO;
    editing_ = NO;
    self.view.backgroundColor = [Utilities CHLightBlueColor];

    currentUser = [user getInstance];
    
    studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :NO studentIds:currentUser.studentIds];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token];
    
    [self.tableView setBounces:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    clicked = NO;
    if (editingStudent) {
        studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :NO studentIds:currentUser.studentIds];
        [self.tableView reloadData];
        editingStudent = NO;
    }
    self.backButton.enabled = YES;

}

- (IBAction)addStudentClicked:(id)sender {
    [Utilities editAlertAddStudentWithtitle:@"Add student" message:nil cancel:@"Cancel" done:nil delete:NO textfields:@[@"First name", @"Last name"] tag:1 view:self];
}

- (IBAction)editButtonClicked:(id)sender {
    if (editing_){
        editing_ = NO;
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
                [Utilities editAlertAddStudentWithtitle:@"Error adding student" message:errorMessage cancel:@"Cancel" done:nil delete:NO textfields:@[@"First name", @"Last name"] tag:1 view:self];

            }
        }
        else {
            [Utilities editAlertAddStudentWithtitle:@"Error adding student" message:errorMessage cancel:@"Cancel" done:nil delete:NO textfields:@[@"First name", @"Last name"] tag:1 view:self];
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
            [[DatabaseHandler getSharedInstance]addStudent:newStudent :[currentUser.currentClass getId]];
            [studentsData addObject:newStudent];
            [currentUser.studentIds addObject:[NSNumber numberWithInteger:studentId]];
            [self.tableView reloadData];
        }
        else {
            [Utilities disappearingAlertView:@"Error adding student" message:message otherTitles:nil tag:0 view:self time:2.0];
            return;
        }
    }
    else if (type == DELETE_STUDENT){
        if([successNumber boolValue] == YES)
        {
            [studentsData removeObject:currentStudent];
            [currentUser.studentIds removeObject:[NSNumber numberWithInteger:[currentStudent getId]]];

            currentStudent = nil;
            [self.tableView reloadData];
        }
        else {
            [Utilities disappearingAlertView:@"Error deleting student" message:message otherTitles:nil tag:0 view:self time:2.0];
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


- (void)subtractPointsClicked{
    if (editing_ && selectedStudentIds.count > 0){
        
    }
    else {
        [Utilities disappearingAlertView:@"Click edit and select students first" message:nil otherTitles:nil tag:0 view:self time:1.8];
    }
    
}


- (void)addPointsClicked{
    NSLog(@"Here is the selected student count %d", selectedStudentIds.count);
    if (editing_ && selectedStudentIds.count > 0){
        
    }
    else {
        [Utilities disappearingAlertView:@"Click edit and add students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
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
//    sectionView.layer.borderWidth = 1.5;
//    sectionView.layer.borderColor = [UIColor blackColor].CGColor;
    
    // Make the sections
    
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
    
    UILabel *addPointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,8,86,44)];
    addPointsLabel.text = @"Add Points";
    
    UILabel *subtractPointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,8,86,44)];
    subtractPointsLabel.text = @"Subtract Points";
    
    
    NSArray *labels = @[addPointsLabel, subtractPointsLabel];
    
    for (UILabel *label in labels){
        label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:18];
        label.shadowColor = [UIColor blackColor];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor whiteColor];
        [Utilities makeRoundedLabel:label :nil];
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
        student *student_ = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
        [cell initializeWithStudent:student_];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    currentStudent = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
    NSNumber *studentId = [NSNumber numberWithInteger:[currentStudent getId]];
    if ([selectedStudentIds containsObject:studentId]){
        [selectedStudentIds removeObject:studentId];
    }

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editing_ && studentsData.count > 0){
        NSLog(@"We did select while editing");
        currentStudent = [studentsData objectAtIndex:studentsData.count - indexPath.row - 1];
        NSNumber *studentId = [NSNumber numberWithInteger:[currentStudent getId]];
        if ([selectedStudentIds containsObject:studentId]){
            [selectedStudentIds removeObject:studentId];
        }
        else {

            [selectedStudentIds addObject:studentId];
        }
    }
    else if (studentsData.count > 0 && !clicked){
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
