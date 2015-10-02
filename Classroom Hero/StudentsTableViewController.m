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

@interface StudentsTableViewController (){
    user *currentUser;
    NSMutableArray *studentsData;
    student *currentStudent;
    ConnectionHandler *webHandler;
    MBProgressHUD *hud;
    
    NSString *studentFirstName;
    NSString *studentLastName;
    bool editingStudent;
}

@end

@implementation StudentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setBounces:NO];
    
    currentUser = [user getInstance];
    
    studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId]];
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
    NSLog(@"In here with %ld students", (long)studentsData.count);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewDidAppear:(BOOL)animated{
    if (editingStudent) {
        studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId]];
        [self.tableView reloadData];
        editingStudent = NO;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (studentsData.count > 0){
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


- (void)viewDidLayoutSubviews{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (IBAction)addStudentClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Add student" message:nil cancel:@"Cancel" done:nil delete:NO textfields:@[@"First name", @"Last name"] tag:1 view:self];
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
        
        if ([errorMessage isEqualToString:@""]){
            errorMessage = [Utilities isInputValid:studentLastName :@"Student last name"];
            if ([errorMessage isEqualToString:@""]){
                [self activityStart:@"Adding Student..."];
                [webHandler addStudent:[currentUser.currentClass getId] :studentFirstName :studentLastName];
            }
        }
        else {
            [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
    }
}

- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    NSLog(@"In student table data ready -> %@", data);
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == ADD_STUDENT){
        
        if([successNumber boolValue] == YES)
        {
            NSInteger studentId = [[data objectForKey:@"id"] integerValue];
            student *newStudent = [[student alloc]initWithid:studentId firstName:studentFirstName lastName:studentLastName serial:@"" lvl:1 progress:0 lvlupamount:3 points:0 totalpoints:0];
            [[DatabaseHandler getSharedInstance]addStudent:newStudent :[currentUser.currentClass getId]];
            [studentsData addObject:newStudent];
            [self.tableView reloadData];
            [hud hide:YES];
            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error adding student" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            
            [hud hide:YES];
            return;
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"student_segue"]){
        StudentViewController *vc = [segue destinationViewController];
        [vc setStudent:currentStudent];
        editingStudent = YES;
    }
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}


@end
