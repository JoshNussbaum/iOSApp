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
#import <Google/Analytics.h>

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

- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Classes"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.tableView setSeparatorColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];
    [self.tableView setBounces:NO];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token];
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
            NSString *grade = newClassGrade;
            class *selectedClass = [classes objectAtIndex:index];
            [self activityStart:@"Editing class..."];
            [webHandler editClass:[selectedClass getId] :newClassName :grade];
            tmpClass = [[class alloc]init:[selectedClass getId] :newClassName :grade :[selectedClass getLevel] :[selectedClass getProgress] :[selectedClass getNextLevel] :[selectedClass getCurrentDate]];
         
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

    NSString *message = [data objectForKey:@"message"];

    if(!message)
    {
        if (type == EDIT_CLASS){
            [[DatabaseHandler getSharedInstance] editClass:tmpClass];
            [classes replaceObjectAtIndex:index withObject:tmpClass];
            [self.tableView reloadData];
        }

        else if (type == DELETE_CLASS){
            [[DatabaseHandler getSharedInstance]deleteClass:[tmpClass getId]];
            NSInteger row = index + 1;

            [classes removeObjectAtIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            NSArray *indexPaths = @[indexPath];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

        }
    }
    else {
        [Utilities alertStatusNoConnection];
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
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else {
        ClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classCell forIndexPath:indexPath];

        if (classes.count > 0){
            class *class_ = [classes objectAtIndex:indexPath.row-1];
            NSInteger classCount = [[studentNumberCountsByClassIds objectForKey:[NSNumber numberWithInteger:[class_ getId]]]integerValue];
            [cell initializeCellWithClass:class_ :classCount];
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
        flag = 2;
        [self performSegueWithIdentifier:@"class_to_add_class" sender:self];
        return;
    }
    if (!self.editing){
        if (classes.count > 0){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            class *selectedClass = [self getClassByIndexPath:indexPath];
            currentUser.currentClass = selectedClass;
            NSMutableArray *studentIds = [[DatabaseHandler getSharedInstance] getStudentIds:[selectedClass getId]];
            currentUser.studentIds = studentIds;
//            NSMutableArray *students = [[DatabaseHandler getSharedInstance] getStudents:[selectedClass getId] :NO studentIds:studentIds];
//            NSMutableDictionary *studentsDictionary = [[NSMutableDictionary alloc]init];
//            for (student *stud in students){
//                NSNumber *studentId = [NSNumber numberWithInteger:[stud getId]];
//                studentsDictionary[studentId] = stud;
//            }
//            currentUser.students = studentsDictionary;
            [self performSegueWithIdentifier:@"class_to_home" sender:nil];
        }
    }
    else {
        class *selectedClass = [self getClassByIndexPath:indexPath];
        NSString *gradeString = [NSString stringWithFormat:@"%@", [selectedClass getGradeNumber]];
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
