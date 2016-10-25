//
//  ClassTableViewController.m
//  Classroom Hero
//
//  Created by Josh on 8/19/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "ClassTableViewController.h"
#import "DatabaseHandler.h"
#import "ClassTableViewCell.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "HomeViewController.h"
#import "Flurry.h"

static NSString * const classCell = @"classCell";

@interface ClassTableViewController (){
    user *currentUser;
    NSMutableArray *classes;
    NSMutableDictionary *studentNumberCountsByClassIds;
    NSInteger index;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
    class *tmpClass;
    bool addingClass;
    NSInteger flag;
    bool editingEnabled;
}

@end

@implementation ClassTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];
    //[[UINavigationBar appearance] setTintColor:[Utilities CHBlueColor]];
    [self.tableView setBounces:NO];


    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    currentUser = [user getInstance];
    classes = [[DatabaseHandler getSharedInstance] getClasses];
    editingEnabled = NO;

    NSMutableArray *classIds = [[NSMutableArray alloc]init];
    for (class *class_ in classes){
        NSNumber *classId = [NSNumber numberWithInteger:[class_ getId]];
        [classIds addObject:classId];
    }

    studentNumberCountsByClassIds = [[DatabaseHandler getSharedInstance] getNumberOfStudentsInClasses:classIds];

}


- (void)viewDidAppear:(BOOL)animated{
    if (addingClass){
        addingClass = NO;
        classes = [[DatabaseHandler getSharedInstance]getClasses];
        [self.tableView reloadData];
    }
    if (flag == 2){
        currentUser = [user getInstance];
        classes = [[DatabaseHandler getSharedInstance] getClasses];

        NSMutableArray *classIds = [[NSMutableArray alloc]init];
        for (class *class_ in classes){
            NSNumber *classId = [NSNumber numberWithInteger:[class_ getId]];
            [classIds addObject:classId];
        }


        studentNumberCountsByClassIds = [[DatabaseHandler getSharedInstance] getNumberOfStudentsInClasses:classIds];
        [self.tableView reloadData];
    }
}


- (IBAction)addClassClicked:(id)sender {
    addingClass = YES;
    [self performSegueWithIdentifier:@"class_to_add_class" sender:nil];
}


- (IBAction)editClicked:(id)sender {
    if (self.editing) {
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.tableView setEditing:NO animated:YES];
        self.editing = NO;
    } else {
        [self.editButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
        self.editing = YES;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    if (alertView.tag == 1){
        NSString *newClassName = [alertView textFieldAtIndex:0].text;
        NSString *newClassGrade = [alertView textFieldAtIndex:1].text;
        NSString *errorMessage = [Utilities isInputValid:newClassName :@"Class Name"];

        if (!errorMessage){
            NSString *gradeErrorMessage = [Utilities isNumeric:newClassGrade];
            if (!gradeErrorMessage){
                NSInteger grade = newClassGrade.integerValue;
                class *selectedClass = [classes objectAtIndex:index];
                [self activityStart:@"Editing class..."];
                [webHandler editClass:[selectedClass getId] :newClassName :grade :[selectedClass getSchoolId]];
                tmpClass = [[class alloc]init:[selectedClass getId] :newClassName :grade :[selectedClass getSchoolId] :[selectedClass getLevel] :[selectedClass getProgress] :[selectedClass getNextLevel] :[selectedClass getCurrentDate]];
            }
            else {
                [Utilities alertStatusWithTitle:@"Error editing class" message:gradeErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            }
        }
        else {
            [Utilities alertStatusWithTitle:@"Error editing class" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
    }
    else if (alertView.tag == 2){
        [self activityStart:@"Deleting class..."];
        [webHandler deleteClass:[tmpClass getId]];
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
    if([successNumber boolValue] == YES)
    {
        if (type == EDIT_CLASS){
            [[DatabaseHandler getSharedInstance] editClass:tmpClass];
            [classes replaceObjectAtIndex:index withObject:tmpClass];
            [self.tableView reloadData];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];

            [Flurry logEvent:@"Edit Class" withParameters:params];
        }

        else if (type == DELETE_CLASS){
            [[DatabaseHandler getSharedInstance]deleteClass:[tmpClass getId]];
            NSInteger row = index + 1;

            [classes removeObjectAtIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            NSArray *indexPaths = @[indexPath];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[tmpClass getId]], @"Class ID", nil];

            [Flurry logEvent:@"Edit Class" withParameters:params];

        }
    }
    else {
        NSString *message = [data objectForKey:@"message"];
        NSString *errorMessage;

        if (type == EDIT_CLASS){
            errorMessage = @"Error editing class";
        }
        else if (type == DELETE_CLASS){
            errorMessage = @"Error deleting class";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
    }

}


- (class *)getClassByIndexPath:(NSIndexPath *)indexPath{
    index = indexPath.row - 1;
    class *selectedClass = [classes objectAtIndex:index];
    return selectedClass;
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
    if (classes.count > 0){
        return classes.count + 1;
    }else return 1;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addClassCell"];
        return cell;
    }
    else {
        ClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classCell forIndexPath:indexPath];

        if (classes.count > 0){
            class *class_ = [classes objectAtIndex:indexPath.row-1];
            NSString *schoolName = [[DatabaseHandler getSharedInstance] getSchoolName:[class_ getSchoolId]];
            NSInteger classCount = [[studentNumberCountsByClassIds objectForKey:[NSNumber numberWithInteger:[class_ getId]]]integerValue];
            [cell initializeCellWithClass:class_ :classCount :schoolName];
        }

        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 ) return 74;
    else return 150;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return NO;
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        tmpClass = [self getClassByIndexPath:indexPath];

        [Utilities alertStatusWithTitle:@"Confirm Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [tmpClass getName]]  cancel:@"Cancel"  otherTitles:@[@"Delete"] tag:2 view:self];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"class_to_add_class" sender:self];
        return;
    }
    if (!self.editing){
        if (classes.count > 0){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            class *selectedClass = [self getClassByIndexPath:indexPath];
            currentUser.currentClass = selectedClass;
            [self performSegueWithIdentifier:@"class_to_home" sender:nil];
        }
    }
    else {
        class *selectedClass = [self getClassByIndexPath:indexPath];
        NSString *gradeString = [NSString stringWithFormat:@"%ld", (long)[selectedClass getGradeNumber]];
        [Utilities editTextWithtitle:@"Edit Class" message:nil cancel:@"Cancel" done:@"Done" delete:NO textfields:@[[selectedClass getName], gradeString] tag:1 view:self];

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


- (IBAction)unwindToClassTableView:(UIStoryboardSegue *)unwindSegue{

}


@end
