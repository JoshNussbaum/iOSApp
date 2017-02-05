//
//  HomeViewController.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 1/30/17.
//  Copyright © 2017 Josh Nussbaum. All rights reserved.
//

#import "MBProgressHUD.h"
#import "HomeViewController.h"
#import "StudentCollectionViewCell.h"
#import "StudentViewController.h"


@interface HomeViewController (){
    MBProgressHUD *hud;
    user *currentUser;
    ConnectionHandler *webHandler;
    student *selectedStudent;
    reinforcer *selectedCategory;
    
    UIVisualEffectView *blurEffectView;
    
    NSMutableDictionary *studentsData;
    NSMutableDictionary *selectedStudents;
    NSMutableArray *categoryData;
    
    NSString *tmpCategoryName;
    NSString *tmpCategoryValue;
    
    NSInteger categoryIndex;
    NSInteger pointsAwarded;
    
    BOOL selecting;
    BOOL chestTappable;
    BOOL isMakingWebCall;
    BOOL chestPoint;
    
}

@end

@implementation HomeViewController

static NSString * const reuseIdentifier = @"StudentCollectionViewCell";
static NSString * const reuseIdentifierHeader = @"HeaderCollectionViewCell";
static NSString * const reuseIdentifierFooter = @"FooterCollectionViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    isMakingWebCall = NO;
    chestTappable = NO;
    selecting = NO;
    chestPoint = NO;
    
    currentUser = [user getInstance];
    selectedStudents = [[NSMutableDictionary alloc]init];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];
    [self getStudentsData];
    categoryData = [[DatabaseHandler getSharedInstance]getReinforcers:[currentUser.currentClass getId]];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionHeadersPinToVisibleBounds = YES;
    flowLayout.sectionFootersPinToVisibleBounds = YES;
    [flowLayout setItemSize:CGSizeMake(145, 145)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.studentCollectionView.collectionViewLayout = flowLayout;
    self.studentCollectionView.allowsSelection = YES;
    self.studentCollectionView.allowsMultipleSelection= YES;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return studentsData.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:indexPath.row];
    student *student_ = [studentsData objectForKey:studentId];
    StudentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.levelLabel.text = [NSString stringWithFormat:@"%ld", (long)[student_ getLvl]];
    cell.pointsLabel.text = [NSString stringWithFormat:@"%ld", (long)[student_ getPoints]];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [student_ getFirstName], [student_ getLastName]];
    cell.userInteractionEnabled = YES;
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    UITapGestureRecognizer *selectGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                        action:@selector(didSelectItem:)];
    cell.layer.borderWidth = 1.5f;
    if (selecting){
        cell.layer.borderColor = [Utilities CHGoldColor].CGColor;
    }
    else {
        cell.layer.borderColor = [UIColor clearColor].CGColor;
    }
    [cell addGestureRecognizer:selectGesture];
    if (cell.selected){
        cell.backgroundColor = [Utilities CHGoldColor];
    }
    else {
        cell.backgroundColor = [Utilities CHBlueColor];
    }
    
    return cell;
}



#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0., 60.);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0., 60.);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *cell = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:reuseIdentifierHeader
                                                         forIndexPath:indexPath];
        
        float width = collectionView.frame.size.width / 3;
        
        UIView *attendanceSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
        UIView *classJarSection = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, 60)];
        UIView *marketSection = [[UIView alloc] initWithFrame:CGRectMake(width * 2, 0, width, 60)];
        
        // Add gestures to the sections
        UITapGestureRecognizer *attendanceGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(attendanceClicked)];
        [attendanceSection addGestureRecognizer:attendanceGesture];
        
        UITapGestureRecognizer *jarGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(jarClicked)];
        [classJarSection addGestureRecognizer:jarGesture];
        
        
        UITapGestureRecognizer *marketGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(marketClicked)];
        [marketSection addGestureRecognizer:marketGesture];
        
        
        UILabel *attendanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,8,width-8,44)];
        attendanceLabel.text = @"Attendance";
        
        UILabel *classJarLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,8,width-8,44)];
        classJarLabel.text = @"Class Jar";
        
        UILabel *marketLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,8,width-8,44)];
        marketLabel.text = @"Market";
        
        NSArray *labels = @[attendanceLabel, classJarLabel, marketLabel];
        
        for (UILabel *label in labels){
            label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:22];
            label.textColor = [UIColor blackColor];
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor whiteColor];
            [Utilities makeRoundedLabel:label :nil];
        }
        
        [attendanceSection addSubview:attendanceLabel];
        [classJarSection addSubview:classJarLabel];
        [marketSection addSubview:marketLabel];
        
        NSArray *sections = @[attendanceSection, classJarSection, marketSection];
        for (UIView *view in sections){
            [view setBackgroundColor:[Utilities CHGreenColor]];
            
            [cell addSubview:view];
        }
        
        
    }
    else if (kind == UICollectionElementKindSectionFooter){
        cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:reuseIdentifierFooter
                                                         forIndexPath:indexPath];
        float width = collectionView.frame.size.width / 5;
        
        UIView *addPointsSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
        UIView *subtractPointsSection = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, 60)];
        UIView *plusOneSection = [[UIView alloc] initWithFrame:CGRectMake(width * 2, 0, width, 60)];
        UIView *subtractOneSection = [[UIView alloc] initWithFrame:CGRectMake(width * 3, 0, width, 60)];
        UIView *selectSection = [[UIView alloc] initWithFrame:CGRectMake(width * 4, 0, width, 60)];
        
        // Add gestures to the sections
        UITapGestureRecognizer *addPointsGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(addPointsClicked)];
        [addPointsSection addGestureRecognizer:addPointsGesture];
        
        UITapGestureRecognizer *subtractPointsGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(subtractPointsClicked)];
        [subtractPointsSection addGestureRecognizer:subtractPointsGesture];
        
        UITapGestureRecognizer *plusOneGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(plusOneSelected)];
        [plusOneSection addGestureRecognizer:plusOneGesture];
        
        UITapGestureRecognizer *subtractOneGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(subtractOneSelected)];
        [subtractOneSection addGestureRecognizer:subtractOneGesture];

        
        UITapGestureRecognizer *selectGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(selectClicked:)];
        [selectSection addGestureRecognizer:selectGesture];
        
        
        
        UILabel *addPointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,8,width-8,44)];
        addPointsLabel.text = @"Add Points";
        
        UILabel *subtractPointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,8,width-8,44)];
        subtractPointsLabel.text = @"Subtract";
        
        
        UILabel *plusOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,8,width-8,44)];
        plusOneLabel.text = @"+ 1";
        
        UILabel *subtractOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,8,width-8,44)];
        subtractOneLabel.text = @"- 1";
        
        UILabel *selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(4,8,width-8,44)];
        if (selecting){
            selectLabel.text = @"Done";
        }
        else {
            selectLabel.text = @"Select";
        }
        
        NSArray *labels = @[addPointsLabel, subtractPointsLabel, plusOneLabel, subtractOneLabel, selectLabel];
        
        for (UILabel *label in labels){
            label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:22];
            label.textColor = [UIColor blackColor];
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor whiteColor];
            [Utilities makeRoundedLabel:label :nil];
        }
        
        [addPointsSection addSubview:addPointsLabel];
        [subtractPointsSection addSubview:subtractPointsLabel];
        [plusOneSection addSubview:plusOneLabel];
        [subtractOneSection addSubview:subtractOneLabel];
        [selectSection addSubview:selectLabel];
        
        NSArray *sections = @[addPointsSection, subtractPointsSection, plusOneSection, subtractOneSection, selectSection];
        
        for (UIView *view in sections){
            [view setBackgroundColor:[Utilities CHGreenColor]];
            
            [cell addSubview:view];
        }
    }
    
    return cell;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



#pragma mark User Actions


- (void)didSelectItem:(UITapGestureRecognizer *)recognizer{
    CGPoint touchPoint = [recognizer locationInView:self.studentCollectionView];
    NSIndexPath *indexPath = [self.studentCollectionView indexPathForItemAtPoint:touchPoint];
    
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:indexPath.row];
    student *ss = [studentsData objectForKey:studentId];
    
    // add the the dictionaries here.
    if (selecting){
        
        StudentCollectionViewCell *datasetCell = (StudentCollectionViewCell *)[self.studentCollectionView cellForItemAtIndexPath:indexPath];
        if (datasetCell.selected){
            datasetCell.selected = NO;
            [self.studentCollectionView deselectItemAtIndexPath:indexPath animated:YES];
            datasetCell.backgroundColor = [Utilities CHBlueColor]; // highlight selection
            [selectedStudents removeObjectForKey:[NSNumber numberWithInteger:[ss getId]]];
            
        }
        else {
            [self.studentCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            datasetCell.selected = YES;
            datasetCell.backgroundColor = [Utilities CHGoldColor]; // highlight selection
            [selectedStudents setObject:ss forKey:[NSNumber numberWithInteger:[ss getId]]];
            
        }
        NSLog(@"Here are the selected students -> %@", [self displayStringForMultipleSelectedStudents]);
    }
    else {
        selectedStudent = ss;
        [self performSegueWithIdentifier:@"home_to_student" sender:self];
        
    }
}


- (void)selectClicked:(UITapGestureRecognizer *)recognizer{
    if (selecting){
        selecting = NO;
        [selectedStudents removeAllObjects];
    }
    else {
        selecting = YES;
    }
    [self.studentCollectionView reloadData];

    NSLog(@"Select Clicked");
}


- (void)attendanceClicked{
    [self performSegueWithIdentifier:@"home_to_attendance" sender:self];
}


- (void)marketClicked{
    [self performSegueWithIdentifier:@"home_to_market" sender:self];
}


- (void)jarClicked{
    [self performSegueWithIdentifier:@"home_to_jar" sender:self];
}


- (void)addPointsClicked{
    if (selectedStudents.count > 0){
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            //self.studentCollectionView.backgroundColor = [UIColor clearColor];
            
            [self.studentCollectionView addSubview:blurEffectView];
            
        } else {
            self.studentCollectionView.backgroundColor = [UIColor blackColor];
        }
        //self.studentCollectionView.hidden = YES;
        self.categoryView.hidden = NO;
//        [UIView animateWithDuration:.1
//                         animations:^{
//                             self.studentCollectionView.layer.opacity = 0;
//                             self.categoryView.layer.opacity = 1.0;
//                             
//                         }completion:^(BOOL finished) {
//                             self.studentCollectionView.hidden = YES;
//                             self.categoryView.hidden = NO;
//                         }
//         ];
    }
    else {
        [Utilities disappearingAlertView:@"Select students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
    }
}


- (void)generateChestClicked{
    // Make sure that we aren't in the middle
    // of giving out a point
    
    if (!isMakingWebCall){
        if (!chestTappable){
            chestTappable = YES;
            
            NSNumber *studentId = [[selectedStudents allKeys] objectAtIndex:0];
            student *stud = [selectedStudents objectForKey:studentId];
            selectedStudent = stud;
        }
        else {
            chestTappable = NO;
            [selectedStudents removeAllObjects];
            [self.studentCollectionView reloadData];
        }
    }

    /*
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
            [self setCategoryLabels];
            return;
        }
        else {
            if (studentCount > 0){
                [self animateTableView:YES];
                
                selectedStudentsWhenGenerateChestClicked = [NSMutableDictionary dictionaryWithDictionary:selectedStudents];
                chestTappable = YES;
                
                
                NSNumber *studentId = [[selectedStudents allKeys] objectAtIndex:0];
                student *selectedStudent = [selectedStudents objectForKey:studentId];
                selectedStudent = selectedStudent;
                
                [self displayStudent:YES];
                
                // get all the student IDs and make the web call
                
            }
        }
        
    }
     */

}


- (void)plusOneSelected{
    
}


- (void)subtractOneSelected{
    
}


- (void)subtractPointsClicked{
    NSLog(@"Subtract Clicked");
}


- (IBAction)profileClicked:(id)sender {
    [self performSegueWithIdentifier:@"home_to_profile" sender:self];
}


- (IBAction)classListClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)categoryBackClicked:(id)sender {
    [blurEffectView removeFromSuperview];
    self.categoryView.hidden = YES;
//    [UIView animateWithDuration:.1
//                     animations:^{
//                         self.categoryView.layer.opacity = 0;
//                         self.studentCollectionView.layer.opacity = 1.0;
//                         
//                     }completion:^(BOOL finished) {
//                         self.categoryView.hidden = YES;
//                         self.studentCollectionView.hidden = NO;
//            
//                     }
//     ];
}


- (IBAction)categoryAddCategoryClicked:(id)sender {
}


- (IBAction)categoryEditCategoryClicked:(id)sender {
}


- (IBAction)categoryContinueClicked:(id)sender {
}


- (IBAction)categoryGenerateChestClicked:(id)sender {
}



#pragma mark <ConnectionHandlerDelegate>

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
            [self setCategoryLabels];
            self.categoryPicker.hidden = NO;
        }
        [Utilities alertStatusNoConnection];
        return;
    }
    else if (type == EDIT_REINFORCER){
        [[DatabaseHandler getSharedInstance] editReinforcer:selectedCategory];
        [categoryData replaceObjectAtIndex:index withObject:selectedCategory];
        [self.categoryPicker reloadAllComponents];
        [self setCategoryLabels];
        
    }
    else if (type == ADD_REINFORCER){
        if (chestTappable){
            [self hideStudent];
            [self setCategoryLabels];
            self.categoryPicker.hidden = NO;
            chestTappable = NO;
        }
        
        NSInteger reinforcerId = [[data objectForKey:@"reinforcer_id"] integerValue];
        reinforcer *rr = [[reinforcer alloc] init:reinforcerId :[currentUser.currentClass getId] :tmpCategoryName :tmpCategoryValue.integerValue];
        
        [[DatabaseHandler getSharedInstance] addReinforcer:rr];
        [categoryData insertObject:rr atIndex:0];
        [self.categoryPicker reloadAllComponents];
        
        [self.categoryPicker selectRow:0 inComponent:0 animated:NO];
        
        [self setCategoryLabels];
        
        self.categoryEditCategoryButton.hidden = NO;
        self.categoryPicker.hidden = NO;
        
    }
    else if (type == DELETE_REINFORCER){
        [[DatabaseHandler getSharedInstance]deleteReinforcer:[selectedCategory getId]];
        [categoryData removeObjectAtIndex:categoryIndex];
        [self.categoryPicker reloadAllComponents];
        

            [self setCategoryLabels];
    }
    
    else if (type == REWARD_STUDENT_BULK){
        pointsAwarded = tmpCategoryValue.integerValue;
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
        
        if (chestPoint){
            self.stampImage.image = [UIImage imageNamed:@"treasure_chest.png"];
            //[self addPoints:[selectedCategory getValue] levelup:NO ];
        }
        else {
            [self manuallyAddPointsSuccess];
        }
    }
    else if (type == ADD_POINTS_BULK){
        pointsAwarded = tmpCategoryValue.integerValue;
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
        
        [self manuallyAddPointsSuccess];
    }
}


#pragma mark Utility Functions



- (void)manuallyAddPointsSuccess{
    NSString *successString;
    float time = 0;
    if (!tmpCategoryName){
        time = 1.7;
        successString = [NSString stringWithFormat:@"+%@ to %@", tmpCategoryName, [self displayStringForMultipleSelectedStudents]];
    }
    else {
        time = 2.2;
        successString = [NSString stringWithFormat:@"+%ld for %@ to %@", (long)[selectedCategory getValue], [selectedCategory getName], [self displayStringForMultipleSelectedStudents]];
    }
    
    [Utilities disappearingAlertView:successString message:nil otherTitles:nil tag:0 view:self time:time];
    AudioServicesPlaySystemSound([Utilities getTheSoundOfSuccess]);
    chestTappable = NO;
}


- (void)setCategoryLabels{
    
}


- (void)getStudentsData{
    studentsData = [[NSMutableDictionary alloc]init];
    NSMutableArray *studentsDataArray = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES studentIds:currentUser.studentIds];
    
    for (student *tmpStudent in studentsDataArray){
        [studentsData setObject:tmpStudent forKey:[NSNumber numberWithInteger:[tmpStudent getId]]];
    }
}


- (void)hideStudent{
    self.nameLabel.hidden=YES;
    self.pointsLabel.hidden=YES;
    self.levelLabel.hidden=YES;
    self.sackImage.hidden=YES;
    self.progressView.hidden=YES;
}


- (NSString *)displayStringForMultipleSelectedStudents{
    int max = 60;
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


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}


#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"home_to_student"]){
        StudentViewController *vc = [segue destinationViewController];
        [vc setStudent:selectedStudent];
        
    }
}

@end
