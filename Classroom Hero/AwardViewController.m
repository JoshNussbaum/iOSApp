//
//  AwardViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "AwardViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ClassJarViewController.h"
#import "MarketViewController.h"
#import "MBProgressHUD.h"
#import "StudentsTableViewController.h"
#import "StudentAwardTableViewCell.h"
#import "Flurry.h"


// make select all and deslect all buttons
// lets change studentsData to a dictionary

static NSInteger coinWidth = 250;
static NSInteger coinHeight = 250;

@interface AwardViewController (){
    NSMutableArray *reinforcerData;
    NSMutableDictionary *studentsData;
    reinforcer *currentReinforcer;
    NSString *tmpName;
    NSString *tmpValue;

    user *currentUser;
    ConnectionHandler *webHandler;
    MBProgressHUD *hud;

    NSInteger index;

    // 3 Coins Rects
    CGRect aOneRect;
    CGRect aTwoRect;
    CGRect aThreeRect;

    // 2 Coins Rects
    CGRect bOneRect;
    CGRect bTwoRect;

    // 1 Coin Rect
    CGRect cOneRect;

    // Any Coin Rect
    CGRect coinViewRect;
    CGRect coinLabelRect;

    CGRect coinRect;
    CGRect levelRect;
    CGRect awardRect;

    SystemSoundID failSound;
    SystemSoundID award;
    SystemSoundID coins;
    SystemSoundID levelUp;
    SystemSoundID awardAllStamp;
    SystemSoundID teacherStamp;

    bool isStamping;
    NSInteger studentIndex;
    student *currentStudent;
    NSInteger pointsAwarded;
    NSInteger tmpPoints;
    NSInteger center;

    NSInteger counter;

    BOOL showingStudents;
    NSMutableDictionary *selectedStudents;
    
    BOOL chestTappable;
    BOOL chestPoint;
    
    NSMutableDictionary *selectedStudentsWhenGenerateChestClicked;
}

@end


@implementation AwardViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    reinforcerData = [[DatabaseHandler getSharedInstance]getReinforcers:[currentUser.currentClass getId]];
    studentsData = [[NSMutableDictionary alloc]init];
    selectedStudentsWhenGenerateChestClicked = [[NSMutableDictionary alloc]init];

    [self getStudentsData];
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    selectedStudents = [[NSMutableDictionary alloc] init];
    self.categoryPicker.delegate = self;
    self.categoryPicker.dataSource = self;
    self.nameLabel.text=@"";
    showingStudents = NO;
    chestPoint = NO;
    chestTappable = NO;
    failSound = [Utilities getFailSound];
    award = [Utilities getAwardSound];
    coins = [Utilities getCoinShakeSound];
    levelUp = [Utilities getLevelUpSound];
    awardAllStamp = [Utilities getAwardAllSound];
    teacherStamp = [Utilities getTeacherStampSound];

    if (reinforcerData.count > 0){
        [self.categoryPicker selectRow:index inComponent:0 animated:YES];
        self.categoryPicker.hidden = NO;
        currentReinforcer = [reinforcerData objectAtIndex:0];
        self.reinforcerLabel.text= [NSString stringWithFormat:@"%@", [currentReinforcer getName]];
        self.reinforcerValue.text = [NSString stringWithFormat:@"+ %ld", (long)[currentReinforcer getValue]];
        [self.categoryPicker reloadAllComponents];

    }

    if (!reinforcerData || [reinforcerData count] == 0) {
        self.categoryPicker.hidden = YES;
        self.reinforcerLabel.text=@"Add reinforcers above";
        self.reinforcerValue.text = @"";
        self.editReinforcerButton.hidden = YES;

    }
    else {
        self.editReinforcerButton.hidden = NO;
    }
    center = self.stampImage.center.x;
    counter = 0;

    NSArray *menuButtons = @[self.homeButton, self.awardButton, self.jarButton, self.marketButton];
    for (UIButton *button in menuButtons){
        button.exclusiveTouch = YES;
    }

    CGRect levelRect = CGRectMake(self.levelBar.frame.origin.x, self.levelBar.frame.origin.y, self.levelBar.frame.size.width, 16);

    self.progressView = [[YLProgressBar alloc]initWithFrame:levelRect];
    self.progressView.hidden = YES;
    self.progressView.hideStripes = YES;
    //self.progressView.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    self.progressView.type = YLProgressBarTypeRounded;
    self.progressView.tintColor = [UIColor clearColor];
    self.progressView.progressTintColor = [Utilities CHBlueColor];
    self.progressView.indicatorTextLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:15.0];
    
    [Utilities makeRoundedLabel:self.notificationLabel :nil];
    [self.view addSubview:self.progressView];
}


- (void)viewDidLayoutSubviews{
    if (IS_IPAD_PRO) {
        NSArray *menuButtons = @[self.homeButton, self.jarButton, self.marketButton, self.awardButton];
        
        [Utilities setFontSizeWithbuttons:menuButtons font:@"GillSans-Bold" size:menuItemFontSize];
        
        self.reinforcerLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:52];
        self.reinforcerValue.font = [UIFont fontWithName:@"GillSans-Bold" size:45];
        
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Light" size:42];
        self.pointsLabel.font = [UIFont fontWithName:@"GillSans-Light" size:40];
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-Light" size:40];

    }
}


- (void)getStudentsData{
    NSMutableArray *studentsDataArray = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES];
    
    for (student *tmpStudent in studentsDataArray){
        [studentsData setObject:tmpStudent forKey:[NSNumber numberWithInteger:[tmpStudent getId]]];
    }
}


- (void)viewDidAppear:(BOOL)animated{
    levelRect = CGRectMake(self.levelView.frame.origin.x, self.levelView.frame.origin.y, self.levelView.frame.size.width, self.levelView.frame.size.height);
    isStamping = NO;

    // 3 Coins Rects
    aOneRect = self.aOne.frame;
    aTwoRect = self.aTwo.frame;
    aThreeRect = self.aThree.frame;

    // 2 Coins Rects
    bOneRect = self.bOne.frame;
    bTwoRect = self.bTwo.frame;

    // 1 Coin Rect
    cOneRect = self.cOne.frame;
    coinViewRect = self.coinImage.frame;
    coinLabelRect = self.coinPointsLabel.frame;

    coinRect = self.aTwo.frame;

    self.jarButton.enabled = YES;
    self.classJarIconButton.enabled = YES;
    self.homeButton.enabled = YES;
    self.homeIconButton.enabled = YES;
    self.marketButton.enabled = YES;
    self.marketIconButton.enabled = YES;

}


- (IBAction)homeClicked:(id)sender {
    self.homeButton.enabled = NO;
    self.homeIconButton.enabled = NO;
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)classJarClicked:(id)sender {
    self.jarButton.enabled = NO;
    self.classJarIconButton.enabled = NO;

    [self performSegueWithIdentifier:@"award_to_class_jar" sender:nil];
}


- (IBAction)marketClicked:(id)sender {
    self.marketButton.enabled = NO;
    self.marketIconButton.enabled = NO;
    UIStoryboard *storyboard = self.storyboard;

    ClassJarViewController *cjvc = [storyboard instantiateViewControllerWithIdentifier:@"ClassJarViewController"];
    MarketViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"MarketViewController"];
    [self.navigationController pushViewController:cjvc animated:NO];
    [self.navigationController pushViewController:mvc animated:NO];
}


- (IBAction)studentListClicked:(id)sender {
    if (studentsData.count > 0){
        if (reinforcerData.count > 0){
            if (self.studentsTableView.hidden){
                [self animateTableView:NO];
            }
            else{
                
                [self animateTableView:YES];
            }
        }
        else {
            [Utilities alertStatusWithTitle:@"Add reinforcers first" message:nil cancel:nil otherTitles:nil tag:0 view:self];
        }

    }
    else {
        [Utilities alertStatusWithTitle:@"Add students first" message:nil cancel:nil otherTitles:nil tag:0 view:self];
    }
}


- (IBAction)addReinforcerClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Add Reinforcer" message:nil cancel:@"Cancel"  done:nil delete:NO textfields:@[@"Reinforcer name", @"Reinforcer value"] tag:2 view:self];
}


- (IBAction)editReinforcerClicked:(id)sender {
    if (reinforcerData.count > 0){
        index = [self.categoryPicker selectedRowInComponent:0];
        currentReinforcer = [reinforcerData objectAtIndex:index];
        [Utilities editTextWithtitle:@"Edit Reinforcer" message:nil cancel:nil done:nil delete:YES textfields:@[[currentReinforcer getName], [NSString stringWithFormat:@"%ld", (long)[currentReinforcer getValue]]] tag:1 view:self];
    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            NSString *newReinforcerName = [alertView textFieldAtIndex:0].text;
            NSString *newReinforcerValue = [alertView textFieldAtIndex:1].text;

            NSString *errorMessage = [Utilities isInputValid:newReinforcerName :@"Reinforcer Name"];

            if (!errorMessage){
                NSString *valueErrorMessage = [Utilities isNumeric:newReinforcerValue];
                if (!valueErrorMessage){
                    [self activityStart:@"Editing Reinforcer..."];
                    [currentReinforcer setName:newReinforcerName];
                    [currentReinforcer setValue:newReinforcerValue.integerValue];
                    [webHandler editReinforcer:[currentReinforcer getId] :newReinforcerName :newReinforcerValue.integerValue];
                }
                else {
                    [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:valueErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
                }
            }
            else {
                [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            }
        }
        else if (buttonIndex == 2){
            NSString *deleteMessage = [NSString stringWithFormat:@"Really delete %@?", [currentReinforcer getName]];
            [Utilities alertStatusWithTitle:@"Confirm delete" message:deleteMessage cancel:@"Cancel" otherTitles:@[@"Delete"] tag:3 view:self];
        }

    }
    else if (alertView.tag == 2){
        tmpName = [alertView textFieldAtIndex:0].text;
        tmpValue = [alertView textFieldAtIndex:1].text;

        NSString *errorMessage = [Utilities isInputValid:tmpName :@"Reinforcer Name"];

        if (!errorMessage){
            NSString *valueErrorMessage = [Utilities isNumeric:tmpValue];
            if (!valueErrorMessage){
                [self activityStart:@"Adding Reinforcer..."];
                [webHandler addReinforcer:[currentUser.currentClass getId] :tmpName :tmpValue.integerValue];
            }
            else {
                [Utilities alertStatusWithTitle:@"Error adding reinforcer" message:valueErrorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            }

        }
        else {
            [Utilities alertStatusWithTitle:@"Error adding reinforcer" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
    }
    else if (alertView.tag == 3){
        [webHandler deleteReinforcer:[currentReinforcer getId]];
    }

}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    [hud hide:YES];
    if (data == nil){
        if (chestPoint){
            chestTappable = YES;
        } else {
            chestTappable = NO;
            [self hideStudent];
            [self setReinforcerName];
            self.categoryPicker.hidden = NO;
        }
        [Utilities alertStatusNoConnection];
        isStamping = NO;
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if([successNumber boolValue] == YES)
    {
        if (type == EDIT_REINFORCER){
            [[DatabaseHandler getSharedInstance] editReinforcer:currentReinforcer];
            [reinforcerData replaceObjectAtIndex:index withObject:currentReinforcer];
            [self.categoryPicker reloadAllComponents];
            [self setReinforcerName];

            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];

            [Flurry logEvent:@"Edit Reinforcer" withParameters:params];


        }
        else if (type == ADD_REINFORCER){
            NSInteger reinforcerId = [[data objectForKey:@"id"] integerValue];
            reinforcer *rr = [[reinforcer alloc] init:reinforcerId :[currentUser.currentClass getId] :tmpName :tmpValue.integerValue];

            [[DatabaseHandler getSharedInstance] addReinforcer:rr];
            [reinforcerData insertObject:rr atIndex:0];
            [self.categoryPicker reloadAllComponents];

            [self.categoryPicker selectRow:0 inComponent:0 animated:NO];

            [self setReinforcerName];

            self.editReinforcerButton.hidden = NO;
            self.categoryPicker.hidden = NO;

            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];

            [Flurry logEvent:@"Add Reinforcer - Award View" withParameters:params];

        }
        else if (type == DELETE_REINFORCER){
            [[DatabaseHandler getSharedInstance]deleteReinforcer:[currentReinforcer getId]];
            [reinforcerData removeObjectAtIndex:index];
            [self.categoryPicker reloadAllComponents];

            if (!reinforcerData || [reinforcerData count] == 0) {
                self.categoryPicker.hidden = YES;
                self.reinforcerLabel.text=@"Add  reinforcers  above";
                self.reinforcerValue.text = @"";
                self.editReinforcerButton.hidden = YES;

                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];

                [Flurry logEvent:@"Delete Reinforcer" withParameters:params];
            }
            else {
                [self setReinforcerName];
            }
        }
        else if (type == REWARD_STUDENT){
            
            pointsAwarded = [currentReinforcer getValue];
            NSDictionary *studentDictionary = [data objectForKey:@"student"];

            NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"currentCoins"];
            NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
            NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"lvl"];
            NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
            NSNumber * totalPoints = (NSNumber *)[studentDictionary objectForKey: @"totalCoins"];
            NSInteger lvlUpAmount = 3 + (2*(levelNumber.integerValue - 1));

            [currentStudent setPoints:pointsNumber.integerValue];
            [currentStudent setLevel:levelNumber.integerValue];
            [currentStudent setProgress:progressNumber.integerValue];
            [currentStudent setLevelUpAmount:lvlUpAmount];
            [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];

            [currentUser.currentClass addPoints:1];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
            
            tmpPoints = ([currentStudent getPoints] - pointsAwarded);
            
            [studentsData setObject:currentStudent forKey:idNumber];
            [selectedStudents setObject:currentStudent forKey:idNumber];

            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [currentReinforcer getName], @"Reinforcer Name", [NSString stringWithFormat:@"%ld", (long)[currentReinforcer getId]], @"Reinforcer ID", [NSString stringWithFormat:@"%ld", (long)[currentReinforcer getValue]], @"Reinforcer Value", [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]],@"Student Name", [NSString stringWithFormat:@"%ld", (long)[currentStudent getId]], @"Student ID", [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            [Flurry logEvent:@"Reward Student" withParameters:params];

            if (chestPoint){
                self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
                [self addPoints:[currentReinforcer getValue] levelup:(progressNumber.integerValue == 0) ? YES : NO];
            }
            
            else {
                [self hideStudent];
                [self setReinforcerName];
                self.categoryPicker.hidden = NO;
                [self manuallyAddPointsSuccess];
            }
        }
        
        else if (type == REWARD_STUDENT_BULK){
            pointsAwarded = [currentReinforcer getValue];
            NSArray *studentsArray = [data objectForKey:@"students"];
            NSInteger studentCount = studentsArray.count;
            
            for (NSDictionary *studentDictionary in studentsArray){
                NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"currentCoins"];
                NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
                NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"lvl"];
                NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
                NSNumber * totalPoints = (NSNumber *)[studentDictionary objectForKey: @"totalCoins"];
                NSInteger lvlUpAmount = 3 + (2*(levelNumber.integerValue - 1));
                
                
                student *tmpStudent = [[DatabaseHandler getSharedInstance] getStudentWithID:idNumber.integerValue];
                
                [tmpStudent setPoints:pointsNumber.integerValue];
                [tmpStudent setLevel:levelNumber.integerValue];
                [tmpStudent setProgress:progressNumber.integerValue];
                [tmpStudent setLevelUpAmount:lvlUpAmount];
                [[DatabaseHandler getSharedInstance]updateStudent:tmpStudent];
                
                [studentsData setObject:tmpStudent forKey:idNumber];
                [selectedStudents setObject:currentStudent forKey:idNumber];
            }
            
            [currentUser.currentClass addPoints:studentCount];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
            
            tmpPoints = ([currentStudent getPoints] - pointsAwarded);
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [currentReinforcer getName], @"Reinforcer Name", [NSString stringWithFormat:@"%ld", (long)[currentReinforcer getId]], @"Reinforcer ID", [NSString stringWithFormat:@"%ld", (long)[currentReinforcer getValue]], @"Reinforcer Value", [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]],@"Student Name", [NSString stringWithFormat:@"%ld", (long)[currentStudent getId]], @"Student ID", [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            [Flurry logEvent:@"Reward Student Bulk" withParameters:params];
            
            if (chestPoint){
                self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
                self.pointsLabel.hidden = YES;
                [self addPoints:[currentReinforcer getValue] levelup:NO ];
            }
            else {
             [self manuallyAddPointsSuccess];
            }
        }
        
        
        else if (type == REWARD_ALL_STUDENTS){
            AudioServicesPlaySystemSound(teacherStamp);
            [[DatabaseHandler getSharedInstance] rewardAllStudentsInClassWithid:[currentUser.currentClass getId]];
            [self awardAllStudents];

            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            [currentUser.currentClass addPoints:1];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
            [self getStudentsData];
            
            [Flurry logEvent:@"Reward All Students" withParameters:params];

        }
        else {
            [Utilities alertStatusNoConnection];
            isStamping = NO;
        }
    }
    else {
        NSString *message = [data objectForKey:@"message"];
        NSString *errorMessage;

        if (type == ADD_REINFORCER){
            errorMessage = @"Error adding reinforcer";
        }
        else if (type == EDIT_REINFORCER){
            errorMessage = @"Error editing reinforcer";
        }
        else if (type == DELETE_REINFORCER){
            errorMessage = @"Error deleting reinforcer";
        }
        else if (type == REWARD_STUDENT){
            errorMessage = @"Error rewarding student";
        }
        else if (type == REWARD_ALL_STUDENTS){
            errorMessage = @"Error rewarding class";
        }

        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
        isStamping = NO;
        return;
    }

}


- (void)awardAllStudents{
    awardRect = CGRectMake(self.stampImage.frame.origin.x, self.stampImage.frame.origin.y, self.stampImage.frame.size.width, self.stampImage .frame.size.height);
    self.nameLabel.text = @"+1 All Students";
    self.nameLabel.hidden = NO;
    double delayInSeconds = .6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.6
                         animations:^{
                             [Utilities wiggleImage:self.stampImage sound:NO];
                         }
                         completion:^(BOOL finished) {
                             double delayInSeconds = .5;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                                 AudioServicesPlaySystemSound([Utilities getAwardAllSound]);
                                 double delayInSeconds = 1.0;
                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                                     [UIView animateWithDuration:.3
                                                      animations:^{
                                                          [self.stampImage setFrame:awardRect];
                                                      }
                                      ];
                                     self.nameLabel.text = @"";
                                     isStamping = NO;

                                 });
                             });
                         }
         ];
    });
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
                        displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@",  and  %i  other", skippedStudents]];
                    }
                    else if (skippedStudents > 1){
                        displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@",  %@  and  %i  others", firstName, skippedStudents]];
                    }
                    
                }
                else {
                    displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@",  and  %@", firstName]];
                }
                return displayString;
            }
        }
        else if (index != (selectedStudents.count - 1)) {
            len += 4;
            displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@",  %@", firstName]];
        }
        else {
            len += 7;
            if (skippedStudents == 1){
                displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@",  %@  and  %i  other", firstName, skippedStudents]];
            }
            else if (skippedStudents > 1){
                displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@",  %@  and  %i  others", firstName, skippedStudents]];
            }
            else {
                displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@",  and  %@", firstName]];

            }
        }
        totalLength += len;
        
    }
        
    return displayString;
}


- (void)displayStudent:(BOOL)chest{
    NSInteger studentsCount = selectedStudents.count;

    if (studentsCount == 0){
        self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
        chestTappable = NO;
        [self hideStudent];
        self.categoryPicker.hidden = NO;
        [self setReinforcerName];
        return;
    }
    self.categoryPicker.hidden = YES;
   
    NSNumber *studentId = [[selectedStudents allKeys] objectAtIndex:0];
    student *selectedStudent = [selectedStudents objectForKey:studentId];
    NSString *studentString;
    if (studentsCount > 1) {
        studentString = [self displayStringForMultipleSelectedStudents];
        self.levelLabel.hidden = YES;
        self.sackImage.hidden = NO;
        self.progressView.hidden = YES;
    }
    else if (studentsCount == 1){
        studentString = [NSString stringWithFormat:@"%@ %@", [selectedStudent getFirstName], [selectedStudent getLastName]];
        self.pointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)([selectedStudent getPoints] - pointsAwarded)];
        self.pointsLabel.hidden = NO;
        
        NSInteger level;
        if ([selectedStudent getProgress] == 0 && [selectedStudent getLvl] != 1){
            level = [currentStudent getLvl] - 1;
            self.progressView.progress = (float)([selectedStudent getLvlUpAmount]-3)/(float)([selectedStudent getLvlUpAmount]-2);
        }
        else {
            level = [currentStudent getLvl];
            self.progressView.progress = (float)(([selectedStudent getProgress]-1) / (float)[selectedStudent getLvlUpAmount]);
            
        }
        self.progressView.hidden = NO;
        NSString * levelDisplay = [NSString stringWithFormat:@"Level %ld", (long)level];
        
        self.levelLabel.text=levelDisplay;
        self.levelLabel.hidden = NO;
        
        self.sackImage.hidden = NO;
    }
    else {
        return;
    }
    
    self.nameLabel.text = studentString;
    
    self.nameLabel.hidden = NO;
    if (chest) {
        
        if (studentsCount == 1){
            self.pointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];
            self.pointsLabel.hidden = NO;
        }
        else {
            self.pointsLabel.hidden = YES;
            self.pointsLabel.text = @"Tap to unlock";
            self.pointsLabel.hidden = NO;
        }

        double delayInSeconds = .5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.chestButton.enabled = YES;
        });

    }
    
}


- (void)setReinforcerName{
    index = [self.categoryPicker selectedRowInComponent:0];
    currentReinforcer = [reinforcerData objectAtIndex:index];
    self.reinforcerLabel.text= [NSString stringWithFormat:@"%@", [currentReinforcer getName]];
    self.reinforcerValue.text = [NSString stringWithFormat:@"+ %ld", (long)[currentReinforcer getValue]];
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];

}


/* Animations for Awarding Points */


- (IBAction)chestClicked:(id)sender {
    if (chestTappable && !showingStudents){
        chestTappable = NO;
        chestPoint = YES;
        [Utilities wiggleImage:self.stampImage sound:NO];
        // add the points now and do all the cool animations brah
        NSInteger reinforcerId = [currentReinforcer getId];
        NSInteger pointsEarned = [currentReinforcer getValue];
        
        NSInteger studentCount = selectedStudents.count;
        
        if (studentCount > 1){
            NSMutableArray *selectedStudentIds = [[NSMutableArray alloc]init];
            
            for (NSNumber *studentId in selectedStudents) {
                [selectedStudentIds addObject:studentId];
            }
            
            [webHandler rewardStudentsWithids:selectedStudentIds pointsEarned:pointsEarned reinforcerId:reinforcerId schoolId:[currentUser.currentClass getSchoolId] classId:[currentUser.currentClass getId]];
        }
        else {
            [webHandler rewardStudentWithid:[currentStudent getId] pointsEarned:pointsEarned reinforcerId:reinforcerId schoolId:[currentUser.currentClass getSchoolId] classId:[currentUser.currentClass getId]];
            
        }
        
        
    }
}


- (void)addPoints:(NSInteger)points levelup:(bool)levelup{
    AudioServicesPlaySystemSound(award);
    if (points == 3){
        [self threeCoinsAnimationWithlevelup:levelup];
    }
    else if (points == 2){
        [self twoCoinsAnimationWithlevelup:levelup];
    }
    else if (points == 1){
        [self oneCoinAnimationWithlevelup:levelup];
    }
    else if (points > 3){
        [self coinAnimationWithlevelup:levelup coins:points];
    }
    else {
        [Utilities alertStatusNoConnection];
        [self hideStudent];
    }

}


- (void)incrementPoints{
    while (pointsAwarded > 0)
    {
        NSString *scoreDisplay = [NSString stringWithFormat:@"%ld points", (long)++tmpPoints];
        [self.pointsLabel setText:scoreDisplay];
        [self performSelector:@selector(incrementPoints) withObject:nil afterDelay:0.15 ];
        pointsAwarded -- ;
    }
}


- (void)animateCoinToSack:(UIView *)coin :(BOOL)label{
    NSInteger sackImageX = self.sackImage.frame.origin.x;
    NSInteger sackImageY = self.sackImage.frame.origin.y;
    NSInteger sackImageWidth = self.sackImage.frame.size.width;

    [coin setFrame:CGRectMake(sackImageX + sackImageWidth/2, self.sackImage.frame.origin.y+self.sackImage.frame.size.height/1.8, 20, 20)];
    coin.alpha = 0.0;

    if (label){
        [self.coinPointsLabel setFrame:CGRectMake((sackImageX + sackImageWidth/2) - self.coinPointsLabel.frame.size.width/2.0, self.sackImage.frame.origin.y+self.sackImage.frame.size.height/2.5, self.coinPointsLabel.frame.size.width, self.coinPointsLabel.frame.size.height)];
        self.coinPointsLabel.alpha = 0.0;
    }
}


- (void)showLevelView{
    self.levelView.alpha = 0;
    self.levelUpLabel.text = [NSString stringWithFormat:@"Level %li", (long)[currentStudent getLvl]];
    self.levelView.hidden = NO;
    NSInteger levelViewXPosition = self.levelView.frame.origin.x;
    NSInteger levelViewWidth = self.levelView.frame.size.width;
    NSInteger levelViewHeight = self.levelView.frame.size.height;
    NSInteger levelViewYPosition2 = self.view.frame.size.height + 50;
    AudioServicesPlaySystemSound(levelUp);
    [UIView animateWithDuration:.3
                     animations:^{
                         self.levelView.alpha = 1.0;

                     }completion:^(BOOL finished) {

                         double delayInSeconds = 1.8;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.5
                                              animations:^{
                                                  [self.levelView setFrame:CGRectMake(levelViewXPosition,levelViewYPosition2, levelViewWidth, levelViewHeight)];
                                              }
                                              completion:^(BOOL finished) {
                                                  [self.progressView setProgress:0.0f animated:NO];
                                                  self.levelView.hidden = YES;
                                                  self.levelView.alpha = 0;
                                                  [self.levelView setFrame:levelRect];
                                              }
                              ];
                         });
                     }
     ];

}


- (CGRect)getRandomCoinRect:(NSInteger)coin{
    NSInteger randomX = 0;
    if (coin == 0){
        randomX = arc4random() % 100;
    }
    else if (coin == 1){
        randomX = center - (coinWidth/2)- 50 + (arc4random() % 100);
    }
    else if (coin == 2){
        randomX = self.view.frame.size.width - coinWidth  - arc4random() % 100;
    }
    NSInteger randomY;
    randomY = self.view.frame.size.height/2 - coinHeight/2;
    CGRect randomCoinRect = CGRectMake(randomX, randomY, coinWidth, coinHeight);
    return randomCoinRect;
}


- (void)coinAnimationWithlevelup:(bool)levelup coins:(NSInteger)points{
    self.coinPointsLabel.text = [NSString stringWithFormat:@"%ld", (long)points];
    self.coinPointsLabel.alpha = 0.0;
    self.coinPointsLabel.hidden = NO;
    self.coinImage.alpha = 0.0;
    self.coinImage.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.coinImage.alpha = 1.0;
        self.coinPointsLabel.alpha = 1.0;
    }
     completion:^(BOOL finished) {
         double delayInSeconds = 1.0;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             [UIView animateWithDuration:1.0 animations:^{
                 self.coinPointsLabel.hidden = YES;
                 [self animateCoinToSack:self.coinImage :YES];

             }
                              completion:^(BOOL finished) {
                                  [Utilities sackWiggle:self.sackImage];
                                  AudioServicesPlaySystemSound(coins);
                                  float t = .15;
                                  if (levelup) {
                                      self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
                                      [self showLevelView];
                                      t = .5;
                                  }
                                  [UIView animateWithDuration:t
                                                   animations:^{
                                                       [self.coinImage setFrame:coinViewRect];
                                                       [self.coinPointsLabel setFrame:coinLabelRect];
                                                       if (IS_IPAD_PRO){
                                                           [self.coinPointsLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:45.0]];

                                                       }
                                                       else {
                                                           [self.coinPointsLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:42.0]];
                                                       }
                                                       if (levelup){
                                                           [self.progressView setProgress:1.0f animated:YES];
                                                       }
                                                       else {
                                                           float progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
                                                           [self.progressView setProgress:progress animated:YES];
                                                       }
                                                       [self incrementPoints];
                                                   }
                                                   completion:^(BOOL finished) {
                                                       double delayInSeconds = 1.5;
                                                       if (levelup) delayInSeconds = 2.6;
                                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                           [UIView animateWithDuration:.5
                                                                            animations:^{
                                                                                [self hideStudent];
                                                                            }
                                                                            completion:^(BOOL finished) {
                                                                                [self completeCoinAnimation];
                                                                            }
                                                            ];
                                                       });
                                                   }
                                   ];
                              }];
         });
     }];
}


- (void)hideStudent{
    self.nameLabel.hidden=YES;
    self.pointsLabel.hidden=YES;
    self.levelLabel.hidden=YES;
    self.sackImage.hidden=YES;
    self.progressView.hidden=YES;
}


- (void)completeCoinAnimation{
    self.reinforcerLabel.text = [currentReinforcer getName];
    self.categoryPicker.hidden = NO;
    isStamping = NO;
    chestPoint = NO;
    
    [self.coinPointsLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:42.0]];
}


- (void)oneCoinAnimationWithlevelup:(bool)levelup{
    [UIView animateWithDuration:.4
                     animations:^{
                         self.cOne.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         double delayInSeconds = .5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.5
                                              animations:^{

                                                  [self animateCoinToSack:self.cOne :NO];

                                              }
                                              completion:^(BOOL finished) {
                                                  [Utilities sackWiggle:self.sackImage];
                                                  AudioServicesPlaySystemSound(coins);
                                                  float t = .15;
                                                  if (levelup){
                                                      self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
                                                      [self showLevelView];
                                                      t = .5;
                                                  }
                                                  [UIView animateWithDuration:t
                                                                   animations:^{
                                                                       [self.cOne setFrame:cOneRect];
                                                                       [self incrementPoints];
                                                                       if (levelup){
                                                                           [self.progressView setProgress:1.0f animated:YES];
                                                                       }
                                                                       else {
                                                                           float progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
                                                                           [self.progressView setProgress:progress animated:YES];
                                                                       }
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       double delayInSeconds = 1.5;
                                                                       if (levelup) delayInSeconds = 2.6;
                                                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                           [UIView animateWithDuration:.5
                                                                                            animations:^{
                                                                                                [self hideStudent];
                                                                                            }
                                                                                            completion:^(BOOL finished) {
                                                                                                [self completeCoinAnimation];
                                                                                            }
                                                                            ];
                                                                       });
                                                                   }
                                                   ];
                                              }
                              ];
                         });

                     }
     ];

}


- (void)twoCoinsAnimationWithlevelup:(bool)levelup{
    [UIView animateWithDuration:.5
                     animations:^{
                         self.bOne.alpha = 1.0;
                         self.bTwo.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         double delayInSeconds = .5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.2
                                              animations:^{

                                                  [self animateCoinToSack:self.bOne :NO];
                                              }
                                              completion:^(BOOL finished) {
                                                  [Utilities sackWiggle:self.sackImage];
                                                  [UIView animateWithDuration:.2
                                                                   animations:^{
                                                                       [self animateCoinToSack:self.bTwo :NO];
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       [Utilities sackWiggle:self.sackImage];
                                                                       AudioServicesPlaySystemSound(coins);
                                                                       float t = pointsAwarded * .15;
                                                                       if (levelup) {
                                                                           self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
                                                                            [self showLevelView];
                                                                           t = .5;
                                                                       }
                                                                       [UIView animateWithDuration:t
                                                                                        animations:^{
                                                                                            [self.bOne setFrame:bOneRect];
                                                                                            [self.bTwo setFrame:bTwoRect];

                                                                                            [self incrementPoints];
                                                                                            if (levelup){
                                                                                                [self.progressView setProgress:1.0f animated:YES];
                                                                                            }
                                                                                            else {
                                                                                                float progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
                                                                                                [self.progressView setProgress:progress animated:YES];
                                                                                            }
                                                                                        }
                                                                                        completion:^(BOOL finished) {

                                                                                            double delayInSeconds = 1.5;
                                                                                            if (levelup) delayInSeconds = 2.6;
                                                                                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                                                [UIView animateWithDuration:.5
                                                                                                                 animations:^{
                                                                                                                     [self hideStudent];
                                                                                                                 }
                                                                                                                 completion:^(BOOL finished) {
                                                                                                                     [self completeCoinAnimation];
                                                                                                                     
                                                                                                                 }
                                                                                                 ];
                                                                                            });
                                                                                        }
                                                                        ];

                                                                   }
                                                   ];
                                              }
                              ];

                         });
                     }
     ];
}


- (void)threeCoinsAnimationWithlevelup:(bool)levelup{
    [UIView animateWithDuration:.4
                     animations:^{
                         self.aOne.alpha = 1.0;
                         self.aTwo.alpha = 1.0;
                         self.aThree.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         double delayInSeconds = .5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.2
                                              animations:^{
                                                  [self animateCoinToSack:self.aOne :NO];
                                              }
                                              completion:^(BOOL finished) {
                                                  [Utilities sackWiggle:self.sackImage];
                                                  [UIView animateWithDuration:.2
                                                                   animations:^{
                                                                       [self animateCoinToSack:self.aTwo :NO];
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       [UIView animateWithDuration:.2
                                                                                        animations:^{
                                                                                            [self animateCoinToSack:self.aThree :NO];
                                                                                        }
                                                                                        completion:^(BOOL finished) {
                                                                                            [Utilities sackWiggle:self.sackImage];
                                                                                            AudioServicesPlaySystemSound(coins);
                                                                                            float t = pointsAwarded * .15;
                                                                                            if (levelup) {
                                                                                                self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
                                                                                                [self showLevelView];
                                                                                                t = .5;
                                                                                            }
                                                                                            [UIView animateWithDuration:t
                                                                                                             animations:^{
                                                                                                                 [self.aOne setFrame:aOneRect];
                                                                                                                 [self.aTwo setFrame:aTwoRect];
                                                                                                                 [self.aThree setFrame:aThreeRect];
                                                                                                                 if (levelup){
                                                                                                                     [self.progressView setProgress:1.0f animated:YES];
                                                                                                                 }
                                                                                                                 else {
                                                                                                                     float progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
                                                                                                                     [self.progressView setProgress:progress animated:YES];
                                                                                                                 }
                                                                                                                 [self incrementPoints];
                                                                                                             }
                                                                                                             completion:^(BOOL finished) {
                                                                                                                 double delayInSeconds = 1.5;
                                                                                                                 if (levelup) delayInSeconds = 2.6;
                                                                                                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                                                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                                                                     [UIView animateWithDuration:.5
                                                                                                                                      animations:^{
                                                                                                                                          [self hideStudent];

                                                                                                                                      }
                                                                                                                                      completion:^(BOOL finished) {
                                                                                                                                          [self completeCoinAnimation];
                                                                                                                                      }
                                                                                                                      ];
                                                                                                                 });
                                                                                                             }
                                                                                             ];
                                                                                        }
                                                                        ];
                                                                   }
                                                   ];
                                              }
                              ];
                         });
                     }
     ];
}


- (void)manuallyAddPointsSuccess{
    [Utilities alertStatusWithTitle:@"Success" message:@"Added points" cancel:nil otherTitles:nil tag:0 view:self];
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
    // Return the number of rows in the section.
    if (studentsData.count > 0) {
        return studentsData.count + 4;
    }
    else return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddPointsTableViewCell"];
        cell.contentView.exclusiveTouch = YES;
        cell.exclusiveTouch = YES;
        return cell;
    }
    else if (indexPath.row == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GenerateChestTableViewCell"];
        cell.contentView.exclusiveTouch = YES;
        cell.exclusiveTouch = YES;
        return cell;
        
    }
    else if (indexPath.row == 2){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AwardStudentsSelectAllCell"];
        cell.contentView.exclusiveTouch = YES;
        cell.exclusiveTouch = YES;
        return cell;

    }
    else if (indexPath.row == 3){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AwardStudentsDeselectAllCell"];
        cell.contentView.exclusiveTouch = YES;
        cell.exclusiveTouch = YES;
        return cell;
        
    }
    else {
        StudentAwardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StudentAwardTableViewCell" forIndexPath:indexPath];
        NSNumber *studentId = [[studentsData allKeys] objectAtIndex:(indexPath.row-4)];

        student *student_ = [studentsData objectForKey:studentId];
        
        BOOL selected;
        if ([selectedStudents objectForKey:studentId]){
            selected = YES;
        }
        else {
            selected = NO;
        }
        [cell initializeWithStudent:student_ selected:selected];
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    studentIndex = indexPath.row - 4;
    
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:studentIndex];
    
    currentStudent = [studentsData objectForKey:studentId];
    
    if ([selectedStudents objectForKey:studentId]){
        [selectedStudents removeObjectForKey:studentId];
    }
    if ([selectedStudents count] > 0 && chestTappable){
        [self displayStudent:chestTappable];
    }
    else {
        chestTappable = NO;
        [self hideStudent];
        self.categoryPicker.hidden = NO;
        [self setReinforcerName];
        self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
        
    }
    if (chestPoint){
        [self printSelectedStudents];
    }

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        // Add Points Manually
        if (!isStamping){
            NSInteger studentCount = selectedStudents.count;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (studentCount > 0){
                NSInteger reinforcerId = [currentReinforcer getId];
                NSInteger pointsEarned = [currentReinforcer getValue];
                
                if (studentCount > 1){
                    NSMutableArray *selectedStudentIds = [[NSMutableArray alloc]init];
                    
                    for (NSNumber *studentId in selectedStudents) {
                        [selectedStudentIds addObject:studentId];
                    }
                    
                    [webHandler rewardStudentsWithids:selectedStudentIds pointsEarned:pointsEarned reinforcerId:reinforcerId schoolId:[currentUser.currentClass getSchoolId] classId:[currentUser.currentClass getId]];
                }
                
                else {
                    NSNumber *studentId = [[selectedStudents allKeys] objectAtIndex:0];
                    
                    student *selectedStudent = [[DatabaseHandler getSharedInstance] getStudentWithID:studentId.integerValue];
                    
                    currentStudent = selectedStudent;
                    
                    
                    [webHandler rewardStudentWithid:[selectedStudent getId] pointsEarned:pointsEarned reinforcerId:reinforcerId schoolId:[currentUser.currentClass getSchoolId] classId:[currentUser.currentClass getId]];
                    
                }
                
            }
            else {
                [Utilities alertStatusWithTitle:@"Select students first" message:nil cancel:nil otherTitles:nil tag:1 view:self];
            }
        }
    }
    else if (indexPath.row == 1){
        // Generate Chest
        NSInteger studentCount = selectedStudents.count;
        
        if (chestTappable && [selectedStudents isEqualToDictionary:selectedStudentsWhenGenerateChestClicked]) {
            self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [selectedStudents removeAllObjects];
            
            for (NSIndexPath *indexPath in self.studentsTableView.indexPathsForSelectedRows) {
                NSInteger index = indexPath.row;
                [self.studentsTableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            
            chestTappable = NO;
            chestPoint = NO;
            [self hideStudent];
            self.categoryPicker.hidden = NO;
            [self setReinforcerName];
            return;
        }
        else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (studentCount > 0){
                self.stampImage.image = [UIImage imageNamed:@"glowing_chest"];

                selectedStudentsWhenGenerateChestClicked = [NSMutableDictionary dictionaryWithDictionary:selectedStudents];
                chestTappable = YES;
                
                
                NSNumber *studentId = [[selectedStudents allKeys] objectAtIndex:0];
                student *selectedStudent = [selectedStudents objectForKey:studentId];
                currentStudent = selectedStudent;
                [self animateTableView:YES];
                [self displayStudent:YES];
                
                // get all the student IDs and make the web call
                
            }
            else {
                [Utilities alertStatusWithTitle:@"Select students first" message:nil cancel:nil otherTitles:nil tag:1 view:self];
            }
        }
        
    }
    else if (indexPath.row == 2){
        // select all
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        for (NSInteger index = 0; index < studentsData.count; index++) {
            NSNumber *studentId = [[studentsData allKeys] objectAtIndex:index];

            student *selectedStudent = [studentsData objectForKey:studentId];
            [selectedStudents setObject:selectedStudent forKey:studentId];
        }
        for (NSIndexPath *indexPath in tableView.indexPathsForVisibleRows) {
            NSInteger index = indexPath.row;
            if (index > 3){
                [self.studentsTableView selectRowAtIndexPath:indexPath
                                                    animated:NO
                                              scrollPosition:UITableViewScrollPositionNone];
            }
        }
        if (chestTappable){
            [self displayStudent:chestTappable];
        }
        
    }
    else if (indexPath.row == 3){
        // de select all
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        currentStudent = nil;
        [selectedStudents removeAllObjects];
        for (NSIndexPath *indexPath in self.studentsTableView.indexPathsForSelectedRows) {
            NSInteger index = indexPath.row;
            [self.studentsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        
        if (chestTappable){
            [self displayStudent:chestTappable];
        }
    }
    
    else {
        studentIndex = indexPath.row - 4;
        NSNumber *studentId = [[studentsData allKeys] objectAtIndex:studentIndex];

        student *selectedStudent = [studentsData objectForKey:studentId];

        [selectedStudents setObject:selectedStudent forKey:studentId];
        
        if ([selectedStudents count] > 0 && chestTappable){
            [self displayStudent:chestTappable];
        }

        
    }
    [self printSelectedStudents];
}



-(void)printSelectedStudents{
    NSString *students = @"";
    for (NSNumber *index in selectedStudents){
        student *stud = [selectedStudents objectForKey:index];
        students = [students stringByAppendingString:[NSString stringWithFormat:@"Student -> %@, %@. Index -> %ld.\n", [stud getFirstName], [stud getLastName], (long)index.integerValue]];
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
                         if (open){
                             showingStudents = NO;
                         }
                         else {
                             showingStudents = YES;
                         }
                     }
     ];
}


#pragma Picker view

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return reinforcerData.count;
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    reinforcer *tmpReinforcer = [reinforcerData objectAtIndex:row];
    return [tmpReinforcer getName];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

    [self setReinforcerName];
}


- (IBAction)unwindToAward:(UIStoryboardSegue *)unwindSegue {

}



@end
