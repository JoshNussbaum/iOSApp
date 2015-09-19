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
#import "RegisterStudentsViewController.h"
#import "HomeViewController.h"

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
    bool editingClass;
    NSInteger flag;
}

@end

@implementation ClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *CHBlueColor = [UIColor colorWithRed:85.0/255.0 green:200.0/255.0 blue:255.0/255.0 alpha:1.0] ;

    [self.navigationController.navigationBar setBarTintColor:CHBlueColor];
    
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"Gill Sans" size:36.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];
    currentUser = [user getInstance];
    classes = [[DatabaseHandler getSharedInstance] getClasses];
    
    NSMutableArray *classIds = [[NSMutableArray alloc]init];
    for (class *class_ in classes){
        NSNumber *classId = [NSNumber numberWithInteger:[class_ getId]];
        [classIds addObject:classId];
    }
    
    
    studentNumberCountsByClassIds = [[DatabaseHandler getSharedInstance] getNumberOfStudentsInClasses:classIds];
    
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeRight];

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

- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    //NSLog(@"In class table and heres data -> %@", data);
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == EDIT_CLASS){
        if([successNumber boolValue] == YES)
        {
            [[DatabaseHandler getSharedInstance] editClass:tmpClass];
            [classes replaceObjectAtIndex:index withObject:tmpClass];
            [self.tableView reloadData];
            [hud hide:YES];

            
        } else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing class" message:message cancel:nil otherTitles:nil tag:0 view:nil];

            [hud hide:YES];
            return;
        }

    }

    else if (type == DELETE_CLASS){
        if([successNumber boolValue] == YES)
        {
      
            [[DatabaseHandler getSharedInstance]deleteClass:[tmpClass getId]];
            NSInteger row = [classes count] - index -1;

            [classes removeObjectAtIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            NSArray *indexPaths = @[indexPath];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [hud hide:YES];
            
        } else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error deleting class" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            [hud hide:YES];
            return;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        editingClass = NO;
        return;
    }
    if (alertView.tag == 1){
        // Edit class
        NSString *newClassName = [alertView textFieldAtIndex:0].text;
        NSString *newClassGrade = [alertView textFieldAtIndex:1].text;
        NSString *errorMessage = [Utilities isInputValid:newClassName :@"Class Name"];
        
        if ([errorMessage isEqualToString:@""]){
            NSString *gradeErrorMessage = [Utilities isNumeric:newClassGrade];
            if ([gradeErrorMessage isEqualToString:@""]){
                NSInteger grade = newClassGrade.integerValue;
                class *selectedClass = [classes objectAtIndex:index];
                [self activityStart:@"Editing class..."];
                [webHandler editClass:[selectedClass getId] :newClassName :grade :[selectedClass getSchoolId]];
                tmpClass = [[class alloc]init:[selectedClass getId] :newClassName :grade :[selectedClass getSchoolId] :[selectedClass getLevel] :[selectedClass getProgress] :[selectedClass getNextLevel] :[selectedClass getHasStamps]];
                
            }
            else {
                [Utilities alertStatusWithTitle:@"Error editing class" message:gradeErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            }
        }
        else {
            [Utilities alertStatusWithTitle:@"Error editing class" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
        editingClass = NO;
    }
    else if (alertView.tag == 2){
        // Delete class
        [tmpClass printClass];
        [self activityStart:@"Deleting class..."];
        [webHandler deleteClass:[tmpClass getId]];
    }

}



#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (classes.count > 0){
        return classes.count;
    }else return 0;
}


- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        tmpClass = [self getClassByIndexPath:indexPath];

        [Utilities alertStatusWithTitle:@"Confirm Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [tmpClass getName]]  cancel:@"Cancel"  otherTitles:@[@"Delete"] tag:2 view:self];
        
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
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classCell forIndexPath:indexPath];
    
    if (classes.count > 0){
        class *class_ = [classes objectAtIndex:classes.count - indexPath.row - 1];
        NSString *schoolName = [[DatabaseHandler getSharedInstance] getSchoolName:[class_ getSchoolId]];
        NSInteger classCount = [[studentNumberCountsByClassIds objectForKey:[NSNumber numberWithInt:[class_ getId]]]integerValue];
        [cell initializeCellWithClass:class_ :classCount :schoolName];
    }
    
    return cell;
}


- (void)onSwipeRight:(UILongPressGestureRecognizer*)gesture{
    if (!editingClass){
        editingClass = YES;
        UITableView* tableView = (UITableView*)self.view;
        CGPoint touchPoint = [gesture locationInView:self.view];
        NSIndexPath* row = [tableView indexPathForRowAtPoint:touchPoint];
        if (row != nil) {
            class *selectedClass = [self getClassByIndexPath:row];
            NSString *gradeString = [NSString stringWithFormat:@"%ld", (long)[selectedClass getGradeNumber]];
            [Utilities editAlertTextWithtitle:@"Edit Class" message:nil cancel:@"Cancel" done:@"Done" textfields:@[[selectedClass getName], gradeString] tag:1 view:self];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!editingClass){
        if (classes.count > 0){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            class *selectedClass = [self getClassByIndexPath:indexPath];
            [selectedClass printClass];
            currentUser.currentClass = selectedClass;
            NSInteger unregisteredStudents = [[DatabaseHandler getSharedInstance] getNumberOfUnregisteredStudentsInClass:[currentUser.currentClass getId]];
            if (unregisteredStudents == 0){
                flag = 2;
                [self performSegueWithIdentifier:@"class_to_home" sender:nil];

            }
            else {
                flag = 2;
                [self performSegueWithIdentifier:@"class_to_register_students" sender:nil];
            }
        }
    }
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


- (IBAction)addClassClicked:(id)sender {
    addingClass = YES;
    [self performSegueWithIdentifier:@"class_to_add_class" sender:nil];
}


- (IBAction)unwindToClassTableView:(UIStoryboardSegue *)unwindSegue{
    
}


- (class *)getClassByIndexPath:(NSIndexPath *)indexPath{
    index = [classes count] - indexPath.row - 1;
    class *selectedClass = [classes objectAtIndex:index];
    return selectedClass;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"class_to_register_students"]){
        RegisterStudentsViewController *vc = [segue destinationViewController];
        [vc setFlag:1];
    }
    else if ([segue.identifier isEqualToString:@"class_to_home"]){
        HomeViewController *vc = [segue destinationViewController];
        [vc setFlag:2];
    }
    
}

@end
