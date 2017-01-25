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
#import "AwardMenuOptionTableViewCell.h"
#import <Google/Analytics.h>

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
    BOOL uncategorizedPoint;
    
    NSMutableDictionary *selectedStudentsWhenGenerateChestClicked;
}

@end


@implementation AwardViewController


- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Award"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [self getStudentsData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.studentsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImg1"]];
    self.studentsTableView.layer.borderWidth = 1.5;
    self.studentsTableView.layer.borderColor = [UIColor blackColor].CGColor;
    currentUser = [user getInstance];
    reinforcerData = [[DatabaseHandler getSharedInstance]getReinforcers:[currentUser.currentClass getId]];
    studentsData = [[NSMutableDictionary alloc]init];
    selectedStudentsWhenGenerateChestClicked = [[NSMutableDictionary alloc]init];
    [self getStudentsData];
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];
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
        self.reinforcerLabel.text=@"Add categories above";
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
    [Utilities makeRoundedButton:self.openStudentTableViewButton :nil];
    [Utilities makeRoundedLabel:self.notificationLabel :nil];
}


- (void)viewDidAppear:(BOOL)animated{
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
    
    [self.studentsTableView reloadData];
    
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    if (IS_IPAD_PRO) {
        NSArray *menuButtons = @[self.homeButton, self.jarButton, self.marketButton, self.awardButton];
        
        [Utilities setFontSizeWithbuttons:menuButtons font:@"GillSans-Bold" size:menuItemFontSize];
        
        self.reinforcerLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:52];
        self.reinforcerValue.font = [UIFont fontWithName:@"GillSans-Bold" size:45];
        
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Light" size:42];
        self.pointsLabel.font = [UIFont fontWithName:@"GillSans-Light" size:40];
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-Light" size:40];

    }
    
    if(![self.progressView isDescendantOfView:self.view]) {
        CGRect levelRect = CGRectMake(self.levelBar.frame.origin.x, self.levelBar.frame.origin.y, self.levelBar.frame.size.width, 16);
        
        self.progressView = [[YLProgressBar alloc]initWithFrame:levelRect];
        self.progressView.hidden = YES;
        self.progressView.hideStripes = YES;
        //self.progressView.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
        self.progressView.type = YLProgressBarTypeRounded;
        self.progressView.tintColor = [UIColor clearColor];
        self.progressView.progressTintColor = [Utilities CHBlueColor];
        self.progressView.indicatorTextLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:15.0];
        [self.view addSubview:self.progressView];
    }
}


- (void)getStudentsData{
    NSMutableArray *studentsDataArray = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES studentIds:currentUser.studentIds];
    
    for (student *tmpStudent in studentsDataArray){
        [studentsData setObject:tmpStudent forKey:[NSNumber numberWithInteger:[tmpStudent getId]]];
    }
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


- (IBAction)addReinforcerClicked:(id)sender {
    if (!chestTappable && !isStamping){
        [Utilities editAlertTextWithtitle:@"Add category" message:nil cancel:@"Cancel"  done:nil delete:NO textfields:@[@"e.g. Participation points", @"e.g. 2"] tag:2 view:self];
    }
}


- (IBAction)editReinforcerClicked:(id)sender {
    if (reinforcerData.count > 0 && !chestTappable && !isStamping){
        index = [self.categoryPicker selectedRowInComponent:0];
        currentReinforcer = [reinforcerData objectAtIndex:index];
        [Utilities editTextWithtitle:@"Edit Category" message:nil cancel:nil done:nil delete:YES textfields:@[[currentReinforcer getName], [NSString stringWithFormat:@"%ld", (long)[currentReinforcer getValue]]] tag:1 view:self];
    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.view endEditing:YES];
    [[alertView textFieldAtIndex:0] resignFirstResponder];
    [[alertView textFieldAtIndex:1] resignFirstResponder];

    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            NSString *newReinforcerName = [alertView textFieldAtIndex:0].text;
            NSString *newReinforcerValue = [alertView textFieldAtIndex:1].text;

            NSString *errorMessage = [Utilities isInputValid:newReinforcerName :@"Category name"];

            if (!errorMessage){
                NSString *valueErrorMessage = [Utilities isNumeric:newReinforcerValue];
                if (!valueErrorMessage){
                    [self activityStart:@"Editing Reinforcer..."];
                    [currentReinforcer setName:newReinforcerName];
                    [currentReinforcer setValue:newReinforcerValue.integerValue];
                    [webHandler editReinforcer:[currentReinforcer getId] :newReinforcerName :newReinforcerValue.integerValue];
                }
                else {
                    [Utilities editTextWithtitle:@"Error edting category" message:valueErrorMessage cancel:nil done:nil delete:YES textfields:@[newReinforcerName, newReinforcerValue] tag:1 view:self];
                }
            }
            else {
                [Utilities editTextWithtitle:@"Error edting category" message:errorMessage cancel:nil done:@"Add Category" delete:YES textfields:@[newReinforcerValue, newReinforcerValue] tag:1 view:self];
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

        NSString *errorMessage = [Utilities isInputValid:tmpName :@"Category name"];

        if (!errorMessage){
            NSString *valueErrorMessage = [Utilities isNumeric:tmpValue];
            if (!valueErrorMessage){
                [self activityStart:@"Adding Category..."];
                [webHandler addReinforcer:[currentUser.currentClass getId] :tmpName :tmpValue.integerValue];
            }
            else {
                [Utilities editTextWithtitle:@"Error adding category" message:valueErrorMessage cancel:@"Cancel"  done:@"Add Category" delete:NO textfields:@[tmpName, tmpValue] tag:2 view:self];

            }

        }
        else {
            [Utilities editTextWithtitle:@"Error adding category" message:errorMessage cancel:@"Cancel"  done:@"Add Category" delete:NO textfields:@[tmpName, tmpValue] tag:2 view:self];
        }
    }
    else if (alertView.tag == 3){
        [webHandler deleteReinforcer:[currentReinforcer getId]];
    }
    else if (alertView.tag == 4){
        tmpValue = [alertView textFieldAtIndex:0].text;

        NSInteger studentCount = selectedStudents.count;
        NSString *errorMessage = [Utilities isNumeric:tmpValue];

        if (!errorMessage) {
            if (studentCount > 0){
                uncategorizedPoint = YES;
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                                      action:@"Add Uncategorized Points (Manual)"
                                                                       label:@"Uncategorized points"
                                                                       value:@1] build]];
                isStamping = YES;
                
                NSMutableArray *selectedStudentIds = [[NSMutableArray alloc]init];
                
                for (NSNumber *studentId in selectedStudents) {
                    [selectedStudentIds addObject:studentId];
                }
                [[alertView textFieldAtIndex:0] resignFirstResponder];

                [webHandler addPointsWithStudentIds:selectedStudentIds points:tmpValue.integerValue];
                return;
                
            }

        }
        else {
            [Utilities editAlertNumberWithtitle:@"Error adding points" message:errorMessage cancel:nil done:@"Add Points" input:nil tag:4 view:self];
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
    else if (type == EDIT_REINFORCER){
        [[DatabaseHandler getSharedInstance] editReinforcer:currentReinforcer];
        [reinforcerData replaceObjectAtIndex:index withObject:currentReinforcer];
        [self.categoryPicker reloadAllComponents];
        [self setReinforcerName];
        
    }
    else if (type == ADD_REINFORCER){
        if (chestTappable){
            [self hideStudent];
            [self setReinforcerName];
            self.categoryPicker.hidden = NO;
            chestTappable = NO;
        }
        
        NSInteger reinforcerId = [[data objectForKey:@"reinforcer_id"] integerValue];
        reinforcer *rr = [[reinforcer alloc] init:reinforcerId :[currentUser.currentClass getId] :tmpName :tmpValue.integerValue];
        
        [[DatabaseHandler getSharedInstance] addReinforcer:rr];
        [reinforcerData insertObject:rr atIndex:0];
        [self.categoryPicker reloadAllComponents];
        
        [self.categoryPicker selectRow:0 inComponent:0 animated:NO];
        
        [self setReinforcerName];
        
        self.editReinforcerButton.hidden = NO;
        self.categoryPicker.hidden = NO;
        
    }
    else if (type == DELETE_REINFORCER){
        [[DatabaseHandler getSharedInstance]deleteReinforcer:[currentReinforcer getId]];
        [reinforcerData removeObjectAtIndex:index];
        [self.categoryPicker reloadAllComponents];
        
        if (!reinforcerData || [reinforcerData count] == 0) {
            self.categoryPicker.hidden = YES;
            self.reinforcerLabel.text=@"Add  categories  above";
            self.reinforcerValue.text = @"";
            self.editReinforcerButton.hidden = YES;
            
        }
        else {
            [self setReinforcerName];
        }
    }
    else if (type == REWARD_STUDENT){
        
        pointsAwarded = [currentReinforcer getValue];
        
        NSNumber * pointsNumber = (NSNumber *)[data objectForKey: @"current_coins"];
        NSNumber * idNumber = (NSNumber *)[data objectForKey: @"student_id"];
        NSNumber * levelNumber = (NSNumber *)[data objectForKey: @"level"];
        NSNumber * progressNumber = (NSNumber *)[data objectForKey: @"progress"];
        NSNumber * totalPoints = (NSNumber *)[data objectForKey: @"total_coins"];
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
        
        
        if (chestPoint){
            self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
            [self addPoints:[currentReinforcer getValue] levelup:(progressNumber.integerValue == 0) ? YES : NO];
        }
        
        else {
            AudioServicesPlaySystemSound(award);
            [self manuallyAddPointsSuccess];
        }
    }
    
    else if (type == REWARD_STUDENT_BULK){
        pointsAwarded = tmpValue.integerValue;
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
        
        [currentUser.currentClass addPoints:1];
        [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
        
        tmpPoints = ([currentStudent getPoints] - pointsAwarded);
        
        if (chestPoint){
            self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
            [self addPoints:[currentReinforcer getValue] levelup:NO ];
        }
        else {
            AudioServicesPlaySystemSound(award);
            [self manuallyAddPointsSuccess];
        }
    }
    else if (type == ADD_POINTS_BULK){
        pointsAwarded = tmpValue.integerValue;
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
        
        AudioServicesPlaySystemSound(award);
        [self manuallyAddPointsSuccess];
    }
    
    else {
        isStamping = NO;
    }
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


- (void)displayStudent:(BOOL)chest{
    NSInteger studentsCount = selectedStudents.count;

    if (studentsCount == 0){
        self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
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
            self.progressView.progress = (float)(([selectedStudent getProgress]) / (float)[selectedStudent getLvlUpAmount]);
            
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
            self.pointsLabel.text = @"Tap the chest to unlock";
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


- (IBAction)openStudentTableViewClicked:(id)sender {
    if (!chestPoint){
        [self animateTableView:NO];
        [self hideStudent];
        self.categoryPicker.hidden = NO;
    }
}


- (IBAction)chestClicked:(id)sender {
    if (chestTappable && !showingStudents){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                              action:@"Add Points (Chest)"
                                                               label:[currentReinforcer getName]
                                                               value:@1] build]];
        chestTappable = NO;
        chestPoint = YES;
        isStamping = YES;
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
            
            [webHandler rewardStudentsWithids:selectedStudentIds reinforcerId:reinforcerId];
        }
        else {
            [webHandler rewardStudentWithid:[currentStudent getId] reinforcerId:reinforcerId];
            
        }
        
        
    }
}


- (void)addPoints:(NSInteger)points levelup:(bool)levelup{
    self.pointsLabel.text = [Utilities getRandomCompliment];

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
    if (selectedStudents.count == 1){
        while (pointsAwarded > 0)
        {
            NSString *scoreDisplay = [NSString stringWithFormat:@"%ld points", (long)++tmpPoints];
            [self.pointsLabel setText:scoreDisplay];
            [self performSelector:@selector(incrementPoints) withObject:nil afterDelay:0.15 ];
            pointsAwarded -- ;
        }
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
    chestTappable = NO;
    self.nameLabel.hidden=YES;
    self.pointsLabel.hidden=YES;
    self.levelLabel.hidden=YES;
    self.sackImage.hidden=YES;
    self.progressView.hidden=YES;
    [self animateTableView:NO];

}


- (void)completeCoinAnimation{
    self.reinforcerLabel.text = [currentReinforcer getName];
    self.categoryPicker.hidden = NO;
    isStamping = NO;
    chestPoint = NO;
    [self.coinPointsLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:42.0]];
    [self animateTableView:NO];
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
    NSString *successString;
    float time = 0;
    if (uncategorizedPoint){
        time = 1.7;
        successString = [NSString stringWithFormat:@"+%@ to %@", tmpValue, [self displayStringForMultipleSelectedStudents]];
    }
    else {
        time = 2.2;
        successString = [NSString stringWithFormat:@"+%ld for %@ to %@", (long)[currentReinforcer getValue], [currentReinforcer getName], [self displayStringForMultipleSelectedStudents]];
    }
    
    [Utilities disappearingAlertView:successString message:nil otherTitles:nil tag:0 view:self time:time];
    isStamping = NO;
    chestTappable = NO;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.studentsTableView]) {
        
        return NO;
    }
//    if (chestTappable && ![touch.view isDescendantOfView:self.chestButton]){
//        [self animateTableView:NO];
//        [self hideStudent];
//        self.categoryPicker.hidden = NO;
//    }
    return YES;
}


#pragma mark - Table view data source


- (void)deselectAllClicked{
    if (!isStamping && !chestPoint){
        currentStudent = nil;
        [selectedStudents removeAllObjects];
        for (NSInteger row = 0; row < [self.studentsTableView numberOfRowsInSection:0]; row++) {
            NSInteger index = row;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            StudentAwardTableViewCell *cell = (StudentAwardTableViewCell *)[self.studentsTableView cellForRowAtIndexPath:indexPath];
            cell.backgroundColor = [UIColor clearColor];
            
            [self.studentsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        
        if (chestTappable){
            [self displayStudent:chestTappable];
        }
    }
}


- (void)selectAllClicked{
    if (!isStamping && !chestPoint){
        if (selectedStudents.count == studentsData.count){
            [self deselectAllClicked];
            return;
        }
        for (NSInteger index = 0; index < studentsData.count; index++) {
            NSNumber *studentId = [[studentsData allKeys] objectAtIndex:index];
            
            student *selectedStudent = [studentsData objectForKey:studentId];
            [selectedStudents setObject:selectedStudent forKey:studentId];
        }
        for (NSInteger row = 0; row < [self.studentsTableView numberOfRowsInSection:0]; row++) {
            NSInteger index = row;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.studentsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            StudentAwardTableViewCell *cell = (StudentAwardTableViewCell *)[self.studentsTableView cellForRowAtIndexPath:indexPath];
            
            cell.backgroundColor = [Utilities CHGreenColor];
            
        }
        if (chestTappable){
            [self displayStudent:chestTappable];
        }
    }
}


- (void)generateChestClicked{
    if (reinforcerData.count > 0 ){
        if (!isStamping && !chestPoint){
            NSInteger studentCount = selectedStudents.count;
            
            if (chestTappable && [selectedStudents isEqualToDictionary:selectedStudentsWhenGenerateChestClicked]) {
                
                [selectedStudents removeAllObjects];
                
                for (NSIndexPath *indexPath in self.studentsTableView.indexPathsForSelectedRows) {
                    NSInteger index = indexPath.row;
                    [self.studentsTableView deselectRowAtIndexPath:indexPath animated:NO];
                }
                uncategorizedPoint = NO;
                chestTappable = NO;
                chestPoint = NO;
                [self hideStudent];
                self.categoryPicker.hidden = NO;
                [self setReinforcerName];
                return;
            }
            else {
                if (studentCount > 0){
                    [self animateTableView:YES];
                    
                    selectedStudentsWhenGenerateChestClicked = [NSMutableDictionary dictionaryWithDictionary:selectedStudents];
                    chestTappable = YES;
                    
                    
                    NSNumber *studentId = [[selectedStudents allKeys] objectAtIndex:0];
                    student *selectedStudent = [selectedStudents objectForKey:studentId];
                    currentStudent = selectedStudent;
                    
                    [self displayStudent:YES];
                    
                    // get all the student IDs and make the web call
                    
                }
            }
            
        }
    }
    else {
        [Utilities disappearingAlertView:@"Error generating chest" message:@"Add categories first" otherTitles:nil tag:0 view:self time:1.5];
    }

}


- (void)addPointsClicked{
    if (reinforcerData.count > 0 ){
        if (!isStamping && !chestPoint){
            if (chestTappable){
                [self hideStudent];
                [self setReinforcerName];
                self.categoryPicker.hidden = NO;
                chestTappable = NO;
            }
            // Add Points Manually
            NSInteger studentCount = selectedStudents.count;
            if (studentCount > 0){
                uncategorizedPoint = NO;
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                                      action:@"Add Categorized Points (Manual)"
                                                                       label:[currentReinforcer getName]
                                                                       value:@1] build]];
                isStamping = YES;
                NSInteger reinforcerId = [currentReinforcer getId];
                NSInteger pointsEarned = [currentReinforcer getValue];
                
                if (studentCount > 1){
                    NSMutableArray *selectedStudentIds = [[NSMutableArray alloc]init];
                    
                    for (NSNumber *studentId in selectedStudents) {
                        [selectedStudentIds addObject:studentId];
                    }
                    
                    [webHandler rewardStudentsWithids:selectedStudentIds reinforcerId:reinforcerId];
                }
                
                else {
                    NSNumber *studentId = [[selectedStudents allKeys] objectAtIndex:0];
                    
                    student *selectedStudent = [[DatabaseHandler getSharedInstance] getStudentWithID:studentId.integerValue];
                    
                    currentStudent = selectedStudent;
                    
                    
                    [webHandler rewardStudentWithid:[selectedStudent getId] reinforcerId:reinforcerId];
                    
                }
                
            }
            
        }
        
    }
    else {
        [Utilities disappearingAlertView:@"Error adding points" message:@"Add categories first" otherTitles:nil tag:0 view:self time:1.5];

    }
    
    
}


- (void)manualPointsClicked{
    NSInteger studentCount = selectedStudents.count;
    if (studentCount > 0){
        if (!isStamping && !chestPoint){
            [Utilities editAlertNumberWithtitle:@"Add Points" message:nil cancel:nil done:@"Add points" input:nil tag:4 view:self];
            
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return studentsData.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    // Section View
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
    sectionView.layer.borderWidth = 1.5;
    sectionView.layer.borderColor = [UIColor blackColor].CGColor;
    
    // Make the sections
    
    float width = tableView.frame.size.width / 5;
    
    UIView *addPointsSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
    UIView *manualPointsSection = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, 60)];
    UIView *chestSection = [[UIView alloc] initWithFrame:CGRectMake(width * 2, 0, width, 60)];
    UIView *selectAllSection = [[UIView alloc] initWithFrame:CGRectMake(width * 3, 0, width, 60)];
    UIView *deselectAllSection = [[UIView alloc] initWithFrame:CGRectMake(width * 4, 0, width, 60)];
    
    // Add gestures to the sections
    UITapGestureRecognizer *addPointsGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(addPointsClicked)];
    [addPointsSection addGestureRecognizer:addPointsGesture];
    
    UITapGestureRecognizer *manualPointsGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(manualPointsClicked)];
    [manualPointsSection addGestureRecognizer:manualPointsGesture];
    
    
    UITapGestureRecognizer *generateChestGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(generateChestClicked)];
    [chestSection addGestureRecognizer:generateChestGesture];
    
    UITapGestureRecognizer *selectAllGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(selectAllClicked)];
    [selectAllSection addGestureRecognizer:selectAllGesture];
    
    UITapGestureRecognizer *deselectAllGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(deselectAllClicked)];
    [deselectAllSection addGestureRecognizer:deselectAllGesture];
    
    
    float x = (width / 2) - 43;
    
    UILabel *addPointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,8,86,44)];
    addPointsLabel.text = @"Category Points";

    UILabel *manualPointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,8,86,44)];
    manualPointsLabel.text = @"Manual Points";
    
    UILabel *generateChestLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,8,86,44)];
    generateChestLabel.text = @"Generate Chest";

    UILabel *selectAllLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,8,86,44)];
    selectAllLabel.text = @"Select All";
    
    UILabel *deselectAllLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,8,86,44)];
    deselectAllLabel.text = @"Deselect All";
    
    NSArray *labels = @[addPointsLabel, manualPointsLabel, generateChestLabel, selectAllLabel, deselectAllLabel];
    
    for (UILabel *label in labels){
        label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:18];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor whiteColor];
        [Utilities makeRoundedLabel:label :nil];
    }
    
    [addPointsSection addSubview:addPointsLabel];
    [manualPointsSection addSubview:manualPointsLabel];
    [chestSection addSubview:generateChestLabel];
    [selectAllSection addSubview:selectAllLabel];
    [deselectAllSection addSubview:deselectAllLabel];
    
    NSArray *sections = @[addPointsSection, manualPointsSection, chestSection, selectAllSection, deselectAllSection];
    for (UIView *view in sections){
        [view setBackgroundColor:[Utilities CHBlueColor]];
        
        [sectionView addSubview:view];
    }
    

    
    return sectionView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StudentAwardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StudentAwardTableViewCell" forIndexPath:indexPath];
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:indexPath.row];
    
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


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    studentIndex = indexPath.row;
    
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:studentIndex];
    
    currentStudent = [studentsData objectForKey:studentId];
    
    StudentAwardTableViewCell *cell = (StudentAwardTableViewCell *)[self.studentsTableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];

    
    if ([selectedStudents objectForKey:studentId]){
        [selectedStudents removeObjectForKey:studentId];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    studentIndex = indexPath.row ;
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:studentIndex];
    student *selectedStudent = [studentsData objectForKey:studentId];
    StudentAwardTableViewCell *cell = (StudentAwardTableViewCell *)[self.studentsTableView cellForRowAtIndexPath:indexPath];
    
        
    if ([selectedStudents objectForKey:studentId]) {
        [selectedStudents removeObjectForKey:studentId];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    else {
        cell.backgroundColor = [Utilities CHGreenColor];
        [selectedStudents setObject:selectedStudent forKey:studentId];
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


- (IBAction)studentListClicked:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    StudentsTableViewController *stvc = [storyboard instantiateViewControllerWithIdentifier:@"StudentsTableViewController"];
    [self.navigationController pushViewController:stvc animated:NO];
}


-(void)printSelectedStudents{
    NSString *students = @"";
    for (NSNumber *index in selectedStudents){
        student *stud = [selectedStudents objectForKey:index];
        students = [students stringByAppendingString:[NSString stringWithFormat:@"Student -> %@, %@. Index -> %ld.\n", [stud getFirstName], [stud getLastName], (long)index.integerValue]];
    }
}


- (IBAction)unwindToAward:(UIStoryboardSegue *)unwindSegue {
}


@end
