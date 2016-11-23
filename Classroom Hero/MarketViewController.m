//
//  MarketViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/3/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "MarketViewController.h"
#import "Utilities.h"
#import "DatabaseHandler.h"
#import "MBProgressHUD.h"
#import "StudentsTableViewController.h"
#import "StudentAwardTableViewCell.h"
#import "Flurry.h"

@interface MarketViewController (){
    user *currentUser;
    
    ConnectionHandler *webHandler;
    NSMutableArray *studentsData;
    NSMutableArray *itemsData;
    NSInteger index;
    item *currentItem;
    student *currentStudent;
    
    NSString *newItemName;
    NSString *newItemCost;

    SystemSoundID failSound;
    SystemSoundID coinSound;
    
    MBProgressHUD *hud;
    
    BOOL showingStudents;
    BOOL studentSelected;
    NSInteger studentIndex;
    
    BOOL isBuying;
}

@end

@implementation MarketViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.studentsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImg1"]];

    isBuying = NO;
    showingStudents = NO;
    studentSelected = NO;
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    [Utilities makeRoundedButton:self.purchaseButton :nil];
    
    currentUser = [user getInstance];
    
    itemsData = [[DatabaseHandler getSharedInstance ] getItems:[currentUser.currentClass getId]];
    studentsData = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES];
    
    self.picker.dataSource = self;
    self.picker.delegate = self;
    
    failSound = [Utilities getFailSound];
    coinSound = [Utilities getCoinShakeSound];
    
    if (itemsData.count == 0){
        [self showNoItems];

    }
    else {
        [self showItems];
    }
    
    NSArray *menuButtons = @[self.homeButton, self.awardButton, self.jarButton, self.marketButton];
    for (UIButton *button in menuButtons){
        button.exclusiveTouch = YES;
    }
}


- (void)viewDidLayoutSubviews{
    if (IS_IPAD_PRO) {
        NSArray *menuButtons = @[self.homeButton, self.jarButton, self.marketButton, self.awardButton];
        
        [Utilities setFontSizeWithbuttons:menuButtons font:@"GillSans-Bold" size:menuItemFontSize];
        
        self.itemNameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:45.0];
        self.pointsLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:42.0];
    }

}


- (void)viewDidAppear:(BOOL)animated{
    self.awardButton.enabled = YES;
    self.awardIconButton.enabled = YES;
    self.jarButton.enabled = YES;
    self.classJarIconButton.enabled = YES;
    self.homeButton.enabled = YES;
    self.homeIconButton.enabled = YES;
}


- (IBAction)homeClicked:(id)sender {
    self.homeButton.enabled = NO;
    [self performSegueWithIdentifier:@"market_to_home" sender:nil];
}


- (IBAction)awardClicked:(id)sender {
    self.awardButton.enabled = NO;
    [self performSegueWithIdentifier:@"market_to_award" sender:nil];
}


- (IBAction)classJarClicked:(id)sender {
    self.jarButton.enabled = NO;
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)studentListClicked:(id)sender {
    if (!isBuying){
        if (studentsData.count > 0){
            if (itemsData.count > 0){
                if (self.studentsTableView.hidden){
                    [self animateTableView:NO];
                }
                else{
                    [self animateTableView:YES];
                }
            }
            else {
                [Utilities alertStatusWithTitle:@"Add items first" message:nil cancel:nil otherTitles:nil tag:0 view:self];
            }
        }
        else {
            [Utilities alertStatusWithTitle:@"Add students first" message:nil cancel:nil otherTitles:nil tag:0 view:self];
        }
        
    }
}


- (IBAction)purchaseClicked:(id)sender {
    if (!isBuying){
        isBuying = YES;
        [self displayStudent];
        
        if ([currentStudent getPoints] >= [currentItem getCost]){
            [self sellItem];
        }
        else {
            [Utilities alertStatusWithTitle:@"Error selling item" message:@"You must earn more coins first" cancel:nil otherTitles:nil tag:0 view:self];
        }
    }
}


- (IBAction)addItemClicked:(id)sender {
    if (!isBuying){
        [Utilities editAlertTextWithtitle:@"Add item" message:nil cancel:nil done:nil delete:NO textfields:@[@"Item name", @"Item cost"] tag:1 view:self];

    }
}


- (IBAction)editItemClicked:(id)sender {
    if (!isBuying){
        [Utilities editTextWithtitle:@"Edit item" message:nil cancel:@"Cancel" done:nil delete:YES textfields:@[[currentItem getName], [NSString stringWithFormat:@"%ld", (long)[currentItem getCost]]] tag:2 view:self];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        isBuying = NO;
        return;
    }
    
    newItemName = [alertView textFieldAtIndex:0].text;
    newItemCost = [alertView textFieldAtIndex:1].text;
    
    if (alertView.tag == 1){
        NSString *errorMessage = [Utilities isInputValid:newItemName :@"Item Name"];
        
        if (!errorMessage){
            NSString *costErrorMessage = [Utilities isNumeric:newItemCost];
            if (!costErrorMessage){
                [self activityStart:@"Adding Item..."];
                [webHandler addItem:[currentUser.currentClass getId] :newItemName :newItemCost.integerValue];
            }
            else {
                [Utilities alertStatusWithTitle:@"Error adding item" message:costErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                return;
            }
        }
        else {
            [Utilities alertStatusWithTitle:@"Error adding item" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
        
    }
    else if (alertView.tag == 2){
        if (buttonIndex == 1){
            NSString *errorMessage = [Utilities isInputValid:newItemName :@"Item Name"];
            
            if (!errorMessage){
                NSString *costErrorMessage = [Utilities isNumeric:newItemCost];
                if (!costErrorMessage){
                    [self activityStart:@"Editing Item..."];
                    [currentItem setName:newItemName];
                    [webHandler editItem:[currentItem getId] :newItemName :newItemCost.integerValue];
                }
                else {
                    [Utilities alertStatusWithTitle:@"Error editing item" message:costErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                    return;
                }
            }
            else {
                [Utilities alertStatusWithTitle:@"Error editing item" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            }
        }
        else if (buttonIndex == 2){
            NSString *message = [NSString stringWithFormat:@"Really delete %@?", [currentItem getName]];
            [Utilities alertStatusWithTitle:@"Confirm delete" message:message cancel:@"Cancel" otherTitles:@[@"Delete"] tag:4 view:self];
        }
 
    }
    
    else if (alertView.tag == 3 ){
        //self.picker.hidden = YES;
        [webHandler studentTransactionWithsid:[currentStudent getId] iid:[currentItem getId] cost:[currentItem getCost] cid:[currentUser.currentClass getId]];
    }
    else if (alertView.tag == 4){
        [webHandler deleteItem:[currentItem getId]];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type {
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    
    if([successNumber boolValue] == YES)
    {
        
        if (type == ADD_ITEM){
            NSInteger itemId = [[data objectForKey:@"id"] integerValue];
            
            item *newItem = [[item alloc]init:itemId :[currentUser.currentClass getId] :newItemName :newItemCost.integerValue];
            self.picker.hidden = NO;
            self.editItemButton.hidden = NO;
            
            [[DatabaseHandler getSharedInstance] addItem:newItem];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add Item - Market View" withParameters:params];
            [itemsData insertObject:newItem atIndex:0];
            [self.picker reloadAllComponents];
            [self.picker selectRow:0 inComponent:0 animated:NO];
            [hud hide:YES];
            [self setItemLabel];

        }
        else if (type == EDIT_ITEM){
            [currentItem setName:newItemName];
            [currentItem setCost:newItemCost.integerValue];
            [[DatabaseHandler getSharedInstance] editItem:currentItem];
            
            [itemsData replaceObjectAtIndex:index withObject:currentItem];
            [self.picker reloadAllComponents];
            
            self.itemNameLabel.text = newItemName;
            self.pointsLabel.text = [NSString stringWithFormat:@"%@ points", newItemCost];
            [self setScore];
            [hud hide:YES];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Edit Item" withParameters:params];

        }
        else if (type == DELETE_ITEM){
            [[DatabaseHandler getSharedInstance]deleteItem:[currentItem getId]];
            [itemsData removeObjectAtIndex:index];
            [self.picker reloadAllComponents];
            
            if (!itemsData || [itemsData count] == 0) {
                currentStudent = nil;
                currentItem = nil;
                self.picker.hidden = YES;
                self.itemNameLabel.text=@"Add  items  above";
                self.pointsLabel.text = @"";
                self.editItemButton.enabled = NO;
                [self hideStudent];
                [self showNoItems];
                for (NSIndexPath *indexPath in self.studentsTableView.indexPathsForSelectedRows) {
                    NSInteger index = indexPath.row;
                    [self.studentsTableView deselectRowAtIndexPath:indexPath animated:NO];
                }
                
            }
            else {
                [self setItemLabel];
            }
            [hud hide:YES];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Delete Item" withParameters:params];

        }
        else if (type == STUDENT_TRANSACTION){
            
            NSDictionary *studentDictionary = [data objectForKey:@"student"];
            
            NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"currentCoins"];
            NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"lvl"];
            NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
            
            
            [currentStudent setProgress:progressNumber.integerValue];
            [currentStudent setLevel:levelNumber.integerValue];
            [currentStudent setPoints:pointsNumber.integerValue];
            NSInteger lvlUpAmount = 2 + (2*(levelNumber.integerValue - 1));
            [currentStudent setLevelUpAmount:lvlUpAmount];
            
            
            NSMutableArray *scores = [NSMutableArray array];
            NSInteger score = [currentStudent getPoints];
            NSInteger newScore = [currentStudent getPoints] - [currentItem getCost];
            [scores addObject:[NSNumber numberWithInteger:score]];
            [scores addObject:[NSNumber numberWithInteger:newScore]];
            [currentStudent setPoints:newScore];
            
            [[DatabaseHandler getSharedInstance] updateStudent:currentStudent];
            [self sellItemAnimation:scores];
            [currentUser.currentClass addPoints:1];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
            [Utilities wiggleImage:self.sackImage sound:NO];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [currentItem getName], @"Item Name", [NSString stringWithFormat:@"%ld", (long)[currentItem getId]], @"Item ID", [NSString stringWithFormat:@"%ld", (long)[currentItem getCost]], @"Item Cost", [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]],@"Student Name", [NSString stringWithFormat:@"%ld", (long)[currentStudent getId]], @"Student ID", [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Reward Student" withParameters:params];
            
        }

        else if (type == GET_STUDENT_BY_STAMP){
            NSDictionary *studentDictionary = [data objectForKey:@"student"];
            
            NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"currentCoins"];
            NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
            NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"lvl"];
            NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
            NSNumber * totalPoints = (NSNumber *)[studentDictionary objectForKey: @"totalCoins"];
            NSInteger lvlUpAmount = 2 + (2*(levelNumber.integerValue - 1));
            
            currentStudent = [[DatabaseHandler getSharedInstance] getStudentWithID:idNumber.integerValue];
            
            if (currentStudent != nil){
                [currentStudent setPoints:pointsNumber.integerValue];
                [currentStudent setLevel:levelNumber.integerValue];
                [currentStudent setProgress:progressNumber.integerValue];
                [currentStudent setLevelUpAmount:lvlUpAmount];
                [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
            }
            else{
                NSString *stamp = [studentDictionary objectForKey:@"stamp"];
                NSString * fname = [studentDictionary objectForKey: @"fname"];
                NSString * lname = [studentDictionary objectForKey: @"lname"];
                
                currentStudent = [[student alloc]initWithid:idNumber.integerValue firstName:fname lastName:lname serial:stamp lvl:levelNumber.integerValue progress:progressNumber.integerValue lvlupamount:lvlUpAmount points:pointsNumber.integerValue totalpoints:totalPoints.integerValue checkedin:NO];
                
                [[DatabaseHandler getSharedInstance]addStudent:currentStudent :-1 :[currentUser.currentClass getSchoolId]];
            }
            [self displayStudent];
            
            if (pointsNumber.integerValue >= [currentItem getCost]){
                [self sellItem];
            }
            else {
                [Utilities alertStatusWithTitle:@"Error selling item" message:@"You must earn more coins first" cancel:nil otherTitles:nil tag:0 view:self];
            }
            [hud hide:YES];
        }
    }
    else {
        NSString *errorMessage;
        NSString *message = [data objectForKey:@"message"];
        
        if (type == ADD_ITEM){
            errorMessage = @"Error adding item";
        }
        else if (type == EDIT_ITEM){
            errorMessage = @"Error editing item";
        }
        else if (type == DELETE_ITEM){
            errorMessage = @"Error deleting item";
        }
        else if (type == STUDENT_TRANSACTION){
            errorMessage = @"Error selling item";
        }
        else if (type == GET_STUDENT_BY_STAMP){
            errorMessage = @"Error identifying student";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
        [hud hide:YES];
    }
    
}


- (void)showItems{
    self.picker.hidden = NO;
    [self.picker reloadAllComponents];
    [self.picker selectRow:index inComponent:0 animated:YES];
    currentItem = [itemsData objectAtIndex:0];
    self.itemNameLabel.text= [NSString stringWithFormat:@"%@", [currentItem getName]];
    NSString *points = @"";
    if ([currentItem getCost] > 1){
        points = @"points";
    }
    else {
        points = @"point";
    }
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld %@", (long)[currentItem getCost], points];
}


- (void)showNoItems{
    currentItem = nil;
    self.itemNameLabel.text = @"Add items above";
    self.picker.hidden = YES;
    self.editItemButton.hidden = YES;
    self.pointsLabel.text = @"";
    self.stampImage.hidden = NO;
}


- (void)displayStudent{
    self.stampImage.hidden = YES;
    self.divider1.hidden = NO;
    self.divider2.hidden = NO;
    self.studentNameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.studentNameLabel.hidden = NO;
    [self setScore];
}


- (void)setScore{
    if (currentStudent != nil && currentItem != nil){
        NSInteger difference = [currentStudent getPoints] - [currentItem getCost];
        self.purchaseButton.hidden = NO;
        self.sackImage.hidden = NO;
        
        self.studentPointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];
        self.studentPointsLabel.hidden = NO;
    }
    
}


- (void)hideStudent{
    studentSelected = NO;
    self.studentNameLabel.hidden = YES;
    self.studentPointsLabel.hidden = YES;
    self.studentNameLabel.text= @"";
    self.studentPointsLabel.text = @"";
    self.divider1.hidden = YES;
    self.divider2.hidden = YES;
    self.purchaseButton.hidden = YES;
    self.sackImage.hidden = YES;
    self.stampImage.hidden = NO;
    
}


- (void)sellItem{
    NSString *alertMsg = [NSString stringWithFormat:@"%@, buy %@?",[currentStudent getFirstName], [currentItem getName]];
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Confirm Purchase"
                                                       message:alertMsg
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:nil];
    [alertView addButtonWithTitle:@"Yes"];
    [alertView setTag:3];
    [alertView show];
}


- (void)sellItemAnimation:(NSMutableArray *)scores{
    self.sackImage.hidden = NO;
    [Utilities wiggleImage:self.stampImage sound:NO];
    NSInteger score = [[scores objectAtIndex:0]integerValue];
    self.studentPointsLabel.layer.zPosition = 2;
    self.stampImage.layer.zPosition = 1;
    self.stampImage.layer.zPosition = 0;
    
    NSString *scoreDisplay = [NSString stringWithFormat:@"%ld points", (long)score];
    self.studentPointsLabel.text = scoreDisplay;
    self.studentPointsLabel.hidden = NO;
    AudioServicesPlaySystemSound(coinSound);
    
    [self decrementScore:scores];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        isBuying = NO;
        [self setScore];
    });
    
}


- (void) decrementScore:(NSMutableArray *)scores{
    NSInteger score = [[scores objectAtIndex:0]integerValue];
    NSInteger newScore = [[scores objectAtIndex:1]integerValue];
    if (score != newScore)
    {
        NSString *scoreDisplay = [NSString stringWithFormat:@"%ld points", (long)--score];
        [scores replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:score]];
        [self.studentPointsLabel setText:scoreDisplay];
        [self performSelector:@selector(decrementScore:) withObject:scores afterDelay:0.035];
    }
    else {
        self.studentPointsLabel.layer.zPosition = -2;

    }
    
}


- (void)showErrorMessageWithtitle:(NSString *)title message:(NSString *)message{
    [hud hide:YES];
    [Utilities alertStatusWithTitle:title message:message cancel:nil otherTitles:nil tag:0 view:nil];
    self.picker.hidden = NO;
}


- (void)setItemLabel {
    index = [self.picker selectedRowInComponent:0];
    currentItem = [itemsData objectAtIndex:index];
    if (studentSelected){
        [self setScore];
    }
    self.itemNameLabel.text= [NSString stringWithFormat:@"%@", [currentItem getName]];
    self.pointsLabel.text=[NSString stringWithFormat:@"%li", (long)[currentItem getCost]];
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
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
    return studentsData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StudentAwardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StudentAwardTableViewCell" forIndexPath:indexPath];
    student *student_ = [studentsData objectAtIndex:indexPath.row];
    NSNumber *studentId = [NSNumber numberWithInteger:[student_ getId]];
    [cell initializeWithStudent:student_ selected:NO];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (itemsData.count > 0){
        
        studentIndex = indexPath.row;
        student *selectedStudent = [studentsData objectAtIndex:studentIndex];
        if (selectedStudent == currentStudent){
            currentStudent = nil;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self hideStudent];
            [self animateTableView:YES];
            
        }
        else {
            currentStudent = selectedStudent;
            NSNumber *studentId = [NSNumber numberWithInteger:[selectedStudent getId]];
            studentSelected = YES;
            [self displayStudent];
            [self animateTableView:YES];
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [Utilities alertStatusWithTitle:@"Must add items first" message:nil cancel:nil otherTitles:nil tag:0 view:self];
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


# pragma Picker view


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return itemsData.count;
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    item *tmpItem = [itemsData objectAtIndex:row];
    return [tmpItem getName];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self setItemLabel];
}


@end
