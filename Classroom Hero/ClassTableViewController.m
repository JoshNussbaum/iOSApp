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
}

@end


/* Before going to add class, set addingClass,
 
    Then on view did appear, if addingClass is set, unset it and re-query the 
    classes 
 
 */

@implementation ClassTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    currentUser = [user getInstance];
    // on load, pass all the class ids to DB function that
    // queries the number of students per class
    // and then returns that shit in a dictionary
    // then, we can parse out the number of students from the dictionary
    // when we initialize a new cell and pass that to it.
    
    
    classes = [[DatabaseHandler getSharedInstance] getClasses];
    NSMutableArray *classIds = [[NSMutableArray alloc]init];
    for (class *class_ in classes){
        NSNumber *classId = [NSNumber numberWithInteger:[class_ getId]];
        [classIds addObject:classId];
    }
    
    
    studentNumberCountsByClassIds = [[DatabaseHandler getSharedInstance] getNumberOfStudentsInClasses:classIds];
    
    NSLog(@"Student number counts by class ids -> %@", studentNumberCountsByClassIds);
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self.tableView addGestureRecognizer:longPressRecognizer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    if (addingClass){
        addingClass = NO;
        classes = [[DatabaseHandler getSharedInstance]getClasses];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataReady:(NSDictionary *)data :(NSInteger)type{
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatus:@"Connection error" :@"Please check your internet connection and try again." :@"Okay" :nil :0];
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == EDIT_CLASS){
        if([successNumber boolValue] == YES)
        {
            [[DatabaseHandler getSharedInstance] editClass:tmpClass];
            [classes replaceObjectAtIndex:index withObject:tmpClass];
            [self.tableView reloadData];
            
            
        } else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatus:@"Error editing class" :message :@"Okay" :nil :0];
            [hud hide:YES];
            return;
        }

    }

    else if (type == DELETE_CLASS){
        if([successNumber boolValue] == YES)
        {
            [[DatabaseHandler getSharedInstance]deleteClass:[tmpClass getId]];
            
            [classes removeObjectAtIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            NSArray *indexPaths = @[indexPath];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.tableView reloadData];
            
        } else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatus:@"Error editing class" :message :@"Okay" :nil :0];
            [hud hide:YES];
            return;
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    NSString *newClassName = [alertView textFieldAtIndex:0].text;
    NSString *newClassGrade = [alertView textFieldAtIndex:1].text;
    NSString *errorTitle;
    NSString *errorMessage = [Utilities isInputValid:newClassName :@"Class Name"];
    
    if (alertView.tag == 1){
        errorTitle = @"Error editing class";
    }else errorTitle = @"Error adding class";
    
    if (![errorMessage isEqualToString:@""]){
        NSString *gradeErrorMessage = [Utilities isNumeric:newClassGrade];
        if (![gradeErrorMessage isEqualToString:@""]){
            NSInteger grade = newClassGrade.integerValue;
            if (alertView.tag == 1){
                class *selectedClass = [classes objectAtIndex:index];
                [self activityStart:@"Editing class..."];
                [webHandler editClass:[selectedClass getId] :newClassName :grade :[selectedClass getSchoolId]];
                tmpClass = [[class alloc]init:[selectedClass getId] :newClassName :grade :[selectedClass getSchoolId] :[selectedClass getLevel] :[selectedClass getProgress] :[selectedClass getNextLevel] :[selectedClass getHasStamps]];
                
            }
        }
        else {
            [Utilities alertStatus:errorTitle :gradeErrorMessage :@"Okay" :nil :0];
        }
    }
    else {
        [Utilities alertStatus:errorTitle :errorMessage :@"Okay" :nil :0];
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


-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        tmpClass = [self getClassByIndexPath:indexPath];
        NSLog(@"About to delete this class ");
        [tmpClass printClass];
        [self activityStart:@"Deleting class..."];
        [webHandler deleteClass:[tmpClass getId]];
    }
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(void)viewDidLayoutSubviews{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classCell forIndexPath:indexPath];
    
    if (classes.count > 0){
        class *class_ = [classes objectAtIndex:classes.count - indexPath.row - 1];
        NSString *schoolName = [[DatabaseHandler getSharedInstance] getSchoolName:[class_ getSchoolId]];
        NSLog(@"school name is %@ for class %@", schoolName, [class_ getName]);
        NSInteger classCount = [[studentNumberCountsByClassIds objectForKey:[NSNumber numberWithInt:[class_ getId]]]integerValue];
        NSLog(@"Class count for %ld is %ld", (long)[class_ getId], (long)classCount);
        [cell initializeCellWithClass:class_ :classCount :schoolName];
    }
    
    return cell;
}


-(void)onLongPress:(UILongPressGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        UITableView* tableView = (UITableView*)self.view;
        CGPoint touchPoint = [gesture locationInView:self.view];
        NSIndexPath* row = [tableView indexPathForRowAtPoint:touchPoint];
        if (row != nil) {
            index =  [classes count] - row.row - 1;
            class *selectedClass = [classes objectAtIndex:index];
            NSLog(@"Long Press Class IS...");
            [selectedClass printClass];
            [Utilities editAlert:@"Edit Class" :nil :@"Cancel" :@"Done" :@[@"Class Name", @"Class Grade"] :1 ];
            
        }
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (classes.count > 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        class *selectedClass = [self getClassByIndexPath:indexPath];
        NSLog(@"Selected Class IS...");
        [selectedClass printClass];
        
        currentUser.currentClassId = [selectedClass getId];
        currentUser.currentClassName = [selectedClass getName];
        [self performSegueWithIdentifier:@"class_to_home" sender:nil];
    }
}


-(void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


-(IBAction)addClassClicked:(id)sender {
    addingClass = YES;
    [self performSegueWithIdentifier:@"class_to_add_class" sender:nil];
}

- (IBAction)unwindToClassTableView:(UIStoryboardSegue *)unwindSegue
{
    
}

-(class *)getClassByIndexPath:(NSIndexPath *)indexPath{
    NSInteger classIndex = [classes count] - indexPath.row - 1;
    class *selectedClass = [classes objectAtIndex:classIndex];
    return selectedClass;
}

@end
