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


@interface MarketViewController (){
    user *currentUser;
    
    ConnectionHandler *webHandler;
    
    NSMutableArray *itemsData;
    NSInteger index;
    item *currentItem;
    student *currentStudent;
    
    NSString *newItemName;
    NSString *newItemCost;

    SystemSoundID sellSound;
    SystemSoundID failSound;
    
    MBProgressHUD *hud;
    
    bool isStamping;
}

@end

@implementation MarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
    currentUser = [user getInstance];
    
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    
    itemsData = [[DatabaseHandler getSharedInstance ] getItems:[currentUser.currentClass getId]];
    
    self.picker.dataSource = self;
    self.picker.delegate = self;
    
    sellSound = [Utilities getAwardAllSound];
    failSound = [Utilities getFailSound];
    
    if (itemsData.count == 0){
        self.itemNameLabel.text = @"Add  items  above";
        self.picker.hidden = YES;
        self.editItemButton.hidden = YES;
        self.pointsLabel.text = @"";

    }
    else {
        self.picker.hidden = NO;
        [self.picker reloadAllComponents];
        [self.picker selectRow:index inComponent:0 animated:YES];
        currentItem = [itemsData objectAtIndex:0];
        [currentItem printItem];
        self.itemNameLabel.text= [NSString stringWithFormat:@"%@", [currentItem getName]];
        self.pointsLabel.text = [NSString stringWithFormat:@"%ld", (long)[currentItem getCost]];
    }
    
}


- (IBAction)addItemClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Add item" message:nil cancel:nil done:nil delete:NO textfields:@[@"Item name", @"Item cost"] tag:1 view:self];
}


- (IBAction)editItemClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Edit item" message:nil cancel:nil done:nil delete:YES textfields:@[[currentItem getName], [NSString stringWithFormat:@"%ld", (long)[currentItem getCost]]] tag:2 view:self];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    newItemName = [alertView textFieldAtIndex:0].text;
    newItemCost = [alertView textFieldAtIndex:1].text;
    
    if (alertView.tag == 1){
        NSString *errorMessage = [Utilities isInputValid:newItemName :@"Item Name"];
        
        if ([errorMessage isEqualToString:@""]){
            NSString *costErrorMessage = [Utilities isNumeric:newItemCost];
            if ([costErrorMessage isEqualToString:@""]){
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
            
            if ([errorMessage isEqualToString:@""]){
                NSString *costErrorMessage = [Utilities isNumeric:newItemCost];
                if ([costErrorMessage isEqualToString:@""]){
                    [self activityStart:@"Adding Item..."];
                    [currentItem setName:newItemName];
                    [webHandler editItem:[currentUser.currentClass getId] :newItemName :newItemCost.integerValue];
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
        [webHandler studentTransactionWithsid:[currentStudent getId] iid:[currentItem getId] cost:[currentItem getCost]];
    }
    else if (alertView.tag == 4){
        [webHandler deleteItem:[currentItem getId]];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type {
    NSLog(@"In market data ready -> %@", data);
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        isStamping = NO;
        self.studentNameLabel.hidden = YES;
        self.studentPointsLabel.hidden = YES;
        self.sackImage.hidden = YES;
        self.picker.hidden = NO;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == ADD_ITEM){
        
        if([successNumber boolValue] == YES){
            NSInteger itemId = [[data objectForKey:@"id"] integerValue];

            item *newItem = [[item alloc]init:itemId :[currentUser.currentClass getId] :newItemName :newItemCost.integerValue];
            self.picker.hidden = NO;
            self.editItemButton.hidden = NO;

            [[DatabaseHandler getSharedInstance] addItem:newItem];
            
            [itemsData insertObject:newItem atIndex:0];
            [self.picker reloadAllComponents];
            [self.picker selectRow:0 inComponent:0 animated:NO];
            [hud hide:YES];
            [self setItemLabel];

            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:message cancel:nil otherTitles:nil tag:0 view:nil];

            [hud hide:YES];
            return;
        }
    }
    else if (type == EDIT_ITEM){
        if([successNumber boolValue] == YES)
        {
            [currentItem setName:newItemName];
            [currentItem setCost:newItemCost.integerValue];
            [[DatabaseHandler getSharedInstance] editItem:currentItem];

            [itemsData replaceObjectAtIndex:index withObject:currentItem];
            [self.picker reloadAllComponents];

            self.itemNameLabel.text = newItemName;
            self.pointsLabel.text = [NSString stringWithFormat:@"%@", newItemCost];
            
            [hud hide:YES];
            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing item" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            
            [hud hide:YES];
            return;
        }
    }
    else if (type == DELETE_ITEM){
        if([successNumber boolValue] == YES)
        {
            [[DatabaseHandler getSharedInstance]deleteItem:[currentItem getId]];
            [itemsData removeObjectAtIndex:index];
            [self.picker reloadAllComponents];
            
            if (!itemsData || [itemsData count] == 0) {
                self.picker.hidden = YES;
                self.itemNameLabel.text=@"Add  items  above";
                self.pointsLabel.text = @"";
                self.editItemButton.enabled = NO;
            }
            else {
                [self setItemLabel];
            }

        }
    }
    else if (type == STUDENT_TRANSACTION){
        if([successNumber boolValue] == YES)
        {
            NSMutableArray *scores = [NSMutableArray array];
            NSInteger score = [currentStudent getPoints];
            NSInteger newScore = score - [currentItem getCost];
            [scores addObject:[NSNumber numberWithInteger:score]];
            [scores addObject:[NSNumber numberWithInteger:newScore]];
            [currentStudent setPoints:newScore];
            
            [[DatabaseHandler getSharedInstance] updateStudent:currentStudent];
            [self sellItemAnimation:scores];
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error selling item" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            return;
        }
    }

}




-(void)stampResultDidChange:(NSString *)stampResult{
    if (!isStamping){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                if ([[DatabaseHandler getSharedInstance] isValidStamp:stampSerial :[currentUser.currentClass getSchoolId]]){
                    isStamping = YES;
                    [self sellItem:stampSerial];
                    self.picker.hidden = YES;
                }
            }
            else{
                [Utilities failAnimation:self.stampImage];
            }
        }
    }
}


-(void)sellItem:(NSString*)stampSerial{
    NSInteger cost = [currentItem getCost];
    currentStudent = [[DatabaseHandler getSharedInstance] getStudentWithSerial:stampSerial];
    self.studentNameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.studentNameLabel.hidden = NO;
    NSString *scoreDisplay = [NSString stringWithFormat:@"%ld", (long)[currentStudent getPoints]];
    self.studentPointsLabel.text = scoreDisplay;
    self.studentPointsLabel.hidden = NO;
    self.sackImage.hidden = NO;
    if (cost <= [currentStudent getPoints]){
        
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
    else {
        [Utilities alertStatusWithTitle:@"Insufficient funds" message:@"Earn more coins first" cancel:nil otherTitles:nil tag:0 view:self];
    }
    
}


-(void) sellItemAnimation:(NSMutableArray *)scores{
    AudioServicesPlaySystemSound(sellSound);
    [Utilities wiggleImage:self.stampImage sound:NO];
    NSInteger score = [[scores objectAtIndex:0]integerValue];
    self.studentPointsLabel.layer.zPosition = 2;
    self.stampImage.layer.zPosition = 1;
    self.stampImage.layer.zPosition = 0;
    
    NSString *scoreDisplay = [NSString stringWithFormat:@"%ld", (long)score];
    self.studentPointsLabel.text = scoreDisplay;
    self.sackImage.hidden = NO;
    self.studentPointsLabel.hidden = NO;
    AudioServicesPlaySystemSound(sellSound);
    
    [self decrementScore:scores];
    
    double delayInSeconds = 2.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        isStamping = NO;
        self.studentNameLabel.hidden=YES;
        self.studentPointsLabel.hidden = YES;
        self.sackImage.hidden = YES;
        self.picker.hidden = NO;
        
    });
    
}


-(void) decrementScore:(NSMutableArray *)scores{
    NSInteger score = [[scores objectAtIndex:0]integerValue];
    NSInteger newScore = [[scores objectAtIndex:1]integerValue];
    if (score != newScore)
    {
        NSString *scoreDisplay = [NSString stringWithFormat:@"%ld", (long)--score];
        [scores replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:score]];
        [self.studentPointsLabel setText:scoreDisplay];
        [self performSelector:@selector(decrementScore:) withObject:scores afterDelay:0.035];
    }
    
}





- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return itemsData.count;
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    item *tmpItem = [itemsData objectAtIndex:row];
    NSLog(@"At row %ld we have \n", (long)row);
    [tmpItem printItem];
    return [tmpItem getName];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self setItemLabel];
}


- (void)setItemLabel {
    index = [self.picker selectedRowInComponent:0];
    currentItem = [itemsData objectAtIndex:index];
    self.itemNameLabel.text= [NSString stringWithFormat:@"%@", [currentItem getName]];
    self.pointsLabel.text=[NSString stringWithFormat:@"%li", (long)[currentItem getCost]];
}


- (IBAction)homeClicked:(id)sender {
    [self performSegueWithIdentifier:@"market_to_home" sender:nil];
}


- (IBAction)awardClicked:(id)sender {
    [self performSegueWithIdentifier:@"market_to_award" sender:nil];
}


- (IBAction)classJarClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


- (IBAction)swipeDown:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    StudentsTableViewController *stvc = [storyboard instantiateViewControllerWithIdentifier:@"StudentsTableViewController"];
    [self.navigationController pushViewController:stvc animated:NO];
}

@end
