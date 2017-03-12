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
#import "HomeLeftViewController.h"
#import "HomeRightViewController.h"
#import "HomeMainViewController.h"
#import "HomeNavigationController.h"


@interface HomeViewController (){
    MBProgressHUD *hud;
    user *currentUser;
    ConnectionHandler *webHandler;
    student *selectedStudent;
    reinforcer *selectedCategory;
    
    UIVisualEffectView *blurEffectView;
    
    NSMutableDictionary *studentsData;
    NSMutableDictionary *selectedStudents;
    NSMutableDictionary *categories;
    
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
    
    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];
    self.navigationController.navigationBar.translucent = YES;
    
    isMakingWebCall = NO;
    chestTappable = NO;
    selecting = NO;
    chestPoint = NO;
    
    currentUser = [user getInstance];
    selectedStudents = [[NSMutableDictionary alloc]init];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];
    [self getStudentsData];
    [self getCategoryData];
//    
//    if (categories.count > 0){
//        [self.categoryPicker selectRow:0 inComponent:0 animated:YES];
//        selectedCategory = [categories objectForKey:[[categories allKeys]objectAtIndex:0] ];
//
//    }
//    else {
//        selectedCategory = nil;
//    }
//    [self setCategoryLabels];
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.sectionHeadersPinToVisibleBounds = YES;
//    flowLayout.sectionFootersPinToVisibleBounds = YES;
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width;
//    float cellWidth = screenWidth / 3.0; //Replace the divisor with the column count requirement. Make sure to have it in float.
//    CGSize size = CGSizeMake(cellWidth, cellWidth);
//    flowLayout.minimumLineSpacing = 10.0f;
//    flowLayout.minimumInteritemSpacing = 10.0f;
//    if ([Utilities isIPhone]){
//        [flowLayout setItemSize:CGSizeMake(80, 80)];
//    }
//    else {
//        [flowLayout setItemSize:CGSizeMake(145, 145)];
//    }
//    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
//    
//    self.studentCollectionView.collectionViewLayout = flowLayout;
//    self.studentCollectionView.allowsSelection = YES;
//    self.studentCollectionView.allowsMultipleSelection= YES;
//    
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    blurEffectView.frame = self.view.bounds;
//    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    NSArray *categoryButtons = @[self.categoryAddButton, self.categoryBackButton, self.categoryAddPointsButton, self.categoryEditCategoryButton];
//    [Utilities makeRounded:self.categoryAddButton.layer color:nil borderWidth:.8 cornerRadius:.5];
//
//    for (UIButton *button in categoryButtons){
//        [Utilities makeRounded:button.layer color:nil borderWidth:.8 cornerRadius:.5];
//        button.clipsToBounds = YES;
//    }
//    
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    
//    self.categoryView.hidden = YES;
    
}


#pragma mark <UIPickerView Delegate>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return categories.count;
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSNumber *categoryId = [[[categories allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:row];
    reinforcer *category = [categories objectForKey:categoryId];
    return [category getName];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSNumber *categoryId = [[[categories allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:row];

    selectedCategory = [categories objectForKey:categoryId];
    self.categoryNameLabel.text = [selectedCategory getName];
    if (categoryId.integerValue != 0){
        self.categoryPointsTextField.text = [NSString stringWithFormat:@"%ld points", (long)[selectedCategory getValue]];
        [self.categoryPointsTextField resignFirstResponder];
        self.categoryPointsTextField.userInteractionEnabled = NO;
    }
    else {
        self.categoryPointsTextField.userInteractionEnabled = YES;
        self.categoryPointsTextField.text = @"";

    }
    // set the textfields here yadidimean
    // also gotta set the initial one

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
        cell.layer.borderColor = [UIColor blackColor].CGColor;
    }
    else {
        cell.layer.borderColor = [UIColor clearColor].CGColor;
    }
    [cell addGestureRecognizer:selectGesture];
    if (cell.selected || [selectedStudents objectForKey:[NSNumber numberWithInteger:[student_ getId]]]){
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
    if ([Utilities isIPhone]){
        return CGSizeMake(0., 40.);
    }
    else {
        return CGSizeMake(0., 60.);
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ([Utilities isIPhone]){
        return CGSizeMake(0., 60);
    }
    else {
        return CGSizeMake(0., 150);
    }
}


// make the squares rounded, 


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *cell = nil;

    
    if (kind == UICollectionElementKindSectionHeader){
        cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:reuseIdentifierHeader
                                                         forIndexPath:indexPath];
        
        float width = collectionView.frame.size.width / 3;
        float height;
        
        if ([Utilities isIPhone]){
            height = 40;
        }
        else {
            height = 60;
        }
        
        UIView *attendanceSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        UIView *classJarSection = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, height)];
        UIView *marketSection = [[UIView alloc] initWithFrame:CGRectMake(width * 2, 0, width, height)];
        
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
        

        
        UILabel *attendanceLabel = [[UILabel alloc]init];
        attendanceLabel.text = @"Attendance";
        
        UILabel *classJarLabel = [[UILabel alloc]init];
        classJarLabel.text = @"Class Jar";
        
        UILabel *marketLabel = [[UILabel alloc]init];
        marketLabel.text = @"Market";
        
        NSArray *labels = @[attendanceLabel, classJarLabel, marketLabel];
        
        for (UILabel *label in labels){
            if ([Utilities isIPhone]){
                label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:16];
            }
            else {
                label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:22];
            }
            [label setFrame:CGRectMake(4,4,width-8, height-8)];
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
        for(UIView *view in cell.subviews)
        {
            for(UIView *subView in view.subviews)
            {
                
                [subView removeFromSuperview];
            }
            [view removeFromSuperview];
        }
        float width4 = collectionView.frame.size.width / 4;
        float width3 = collectionView.frame.size.width / 3;
        float height;
        
        if ([Utilities isIPhone]){
            height = 60;
        }
        else {
            height = 120;
        }
        
        UIView *addPointsSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width4, height/2)];
        UIView *subtractPointsSection = [[UIView alloc] initWithFrame:CGRectMake(width4, 0, width4, height/2)];
        UIView *plusOneSection = [[UIView alloc] initWithFrame:CGRectMake(width4 * 2, 0, width4, height/2)];
        UIView *subtractOneSection = [[UIView alloc] initWithFrame:CGRectMake(width4 * 3, 0, width4, height/2)];
                                                                                 
        UIView *selectSection;
        UIView *selectAllSection;
        UIView *deselectAllSection;
        if (selecting){
            deselectAllSection = [[UIView alloc] initWithFrame:CGRectMake(0, 2 + height/2, width3, (height/2) - 6)];
            selectAllSection = [[UIView alloc] initWithFrame:CGRectMake(width3, 2 + height/2, width3, (height/2) - 6)];
            selectSection = [[UIView alloc] initWithFrame:CGRectMake(width3 * 2, 2 + height/2, width3, (height/2) - 6)];
        }
        else {
            selectSection = [[UIView alloc] initWithFrame:CGRectMake(0, 2 + height/2, width4 * 4, (height/2) - 6)];
        }
        
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
        
        if (selecting){
            UITapGestureRecognizer *selectAllGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(selectAllClicked)];
            [selectAllSection addGestureRecognizer:selectAllGesture];
            
            UITapGestureRecognizer *deselectAllGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(deselectAllClicked)];
            [deselectAllSection addGestureRecognizer:deselectAllGesture];
        }
        
        UILabel *addPointsLabel = [[UILabel alloc]init];
        addPointsLabel.text = @"Add";
        
        UILabel *subtractPointsLabel = [[UILabel alloc]init];
        subtractPointsLabel.text = @"Subtract";
        
        
        UILabel *plusOneLabel = [[UILabel alloc]init];
        plusOneLabel.text = @"+ 1";
        
        UILabel *subtractOneLabel = [[UILabel alloc]init];
        subtractOneLabel.text = @"- 1";
    
        
        NSArray *labels = @[addPointsLabel, subtractPointsLabel, plusOneLabel, subtractOneLabel];
        
        for (UILabel *label in labels){
            [label setFrame:CGRectMake(4,4,width4-8,height/2 -8)];
        }

        UILabel *selectLabel = [[UILabel alloc]init];
        selectLabel.text = @"Select Students";
        
        UILabel *deselectAllLabel = [[UILabel alloc]init];
        deselectAllLabel.text = @"Deselect All";
        
        UILabel *selectAllLabel = [[UILabel alloc]init];
        selectAllLabel.text = @"Select All";
  
        if (selecting){
            NSArray *labels = @[selectLabel, selectAllLabel, deselectAllLabel];
            
            for (UILabel *label in labels){
                [label setFrame:CGRectMake(4,0,width3 -8, height/2 -6)];
            }
            selectLabel.text = @"Done";
        }
        else {
            selectLabel.text = @"Select";
            [selectLabel setFrame:CGRectMake(0,0,collectionView.frame.size.width,height/2 -6)];

        }
        
        NSArray *footerLabels = @[addPointsLabel, subtractPointsLabel, plusOneLabel, subtractOneLabel, selectLabel, selectAllLabel, deselectAllLabel];
        
        for (UILabel *label in footerLabels){
            if ([Utilities isIPhone]){
                int size = 16;
//                if (label == selectLabel || label == deselectAllLabel || label == selectAllLabel){
//                    size = 20;
//                }
                label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:size];
            }
            else {
                label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:22];
            }
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
        [selectAllSection addSubview:selectAllLabel];
        [deselectAllSection addSubview:deselectAllLabel];
        NSMutableArray *sections;
        if (selecting){
            sections = [[NSMutableArray alloc]initWithArray:@[addPointsSection, subtractPointsSection, plusOneSection, subtractOneSection, selectSection, selectAllSection, deselectAllSection]];
        }
        else {
            sections = [[NSMutableArray alloc]initWithArray:@[addPointsSection, subtractPointsSection, plusOneSection, subtractOneSection, selectSection]];
        }
        
        for (UIView *view in sections){
            [view setBackgroundColor:[Utilities CHGreenColor]];
            
            [cell addSubview:view];
        }
    }
    [Utilities makeRounded:cell.layer color:nil borderWidth:0.8 cornerRadius:0.5];
    return cell;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



#pragma mark User Actions


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.view endEditing:YES];
    [[alertView textFieldAtIndex:0] resignFirstResponder];
    [[alertView textFieldAtIndex:1] resignFirstResponder];
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            NSString *newCategoryName = [alertView textFieldAtIndex:0].text;
            NSString *newCategoryValue = [alertView textFieldAtIndex:1].text;
            
            NSString *errorMessage = [Utilities isInputValid:newCategoryName :@"Category name"];
            
            if (!errorMessage){
                NSString *valueErrorMessage = [Utilities isNumeric:newCategoryValue];
                if (!valueErrorMessage){
                    [self activityStart:@"Editing Reinforcer..."];
                    [selectedCategory setName:newCategoryName];
                    [selectedCategory setValue:newCategoryValue.integerValue];
                    [webHandler editReinforcer:[selectedCategory getId] :newCategoryName :newCategoryValue.integerValue];
                }
                else {
                    [Utilities editTextWithtitle:@"Error edting category" message:valueErrorMessage cancel:nil done:nil delete:YES textfields:@[newCategoryName, newCategoryValue] tag:1 view:self];
                }
            }
            else {
                [Utilities editTextWithtitle:@"Error edting category" message:errorMessage cancel:nil done:@"Add Category" delete:YES textfields:@[newCategoryName, newCategoryValue] tag:1 view:self];
            }
        }
        else if (buttonIndex == 2){
            NSString *deleteMessage = [NSString stringWithFormat:@"Really delete %@?", [selectedCategory getName]];
            [Utilities alertStatusWithTitle:@"Confirm delete" message:deleteMessage cancel:@"Cancel" otherTitles:@[@"Delete"] tag:3 view:self];
        }
        
    }
    else if (alertView.tag == 2){
        tmpCategoryName = [alertView textFieldAtIndex:0].text;
        tmpCategoryValue = [alertView textFieldAtIndex:1].text;
        
        NSString *errorMessage = [Utilities isInputValid:tmpCategoryName :@"Category name"];
        
        if (!errorMessage){
            NSString *valueErrorMessage = [Utilities isNumeric:tmpCategoryValue];
            if (!valueErrorMessage){
                [self activityStart:@"Adding Category..."];
                [webHandler addReinforcer:[currentUser.currentClass getId] :tmpCategoryName :tmpCategoryValue.integerValue];
            }
            else {
                [Utilities editTextWithtitle:@"Error adding category" message:valueErrorMessage cancel:@"Cancel"  done:@"Add Category" delete:NO textfields:@[tmpCategoryName, tmpCategoryValue] tag:2 view:self];
                
            }
            
        }
        else {
            [Utilities editTextWithtitle:@"Error adding category" message:errorMessage cancel:@"Cancel"  done:@"Add Category" delete:NO textfields:@[tmpCategoryName, tmpCategoryValue] tag:2 view:self];
        }
    }
    else if (alertView.tag == 3){
        [webHandler deleteReinforcer:[selectedCategory   getId]];
    }
    else if (alertView.tag == 4){
        tmpCategoryValue = [alertView textFieldAtIndex:0].text;
        
        NSInteger studentCount = selectedStudents.count;
        NSString *errorMessage = [Utilities isNumeric:tmpCategoryValue];
        
        if (!errorMessage) {
            if (studentCount > 0){
//                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//                
//                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
//                                                                      action:@"Add Uncategorized Points (Manual)"
//                                                                       label:@"Uncategorized points"
//                                                                       value:@1] build]];
                isMakingWebCall = YES;
                NSMutableArray *selectedStudentIds = [[NSMutableArray alloc]init];
                
                for (NSNumber *studentId in selectedStudents) {
                    [selectedStudentIds addObject:studentId];
                }
                [[alertView textFieldAtIndex:0] resignFirstResponder];
                
                [webHandler addPointsWithStudentIds:selectedStudentIds points:tmpCategoryValue.integerValue];
                return;
                
            }
            
        }
        else {
            [Utilities editAlertNumberWithtitle:@"Error adding points" message:errorMessage cancel:nil done:@"Add Points" input:nil tag:4 view:self];
        }
    }
    
}


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
            datasetCell.backgroundColor = [Utilities CHGoldColor]; // highlight selection
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
    }
    else {
        selecting = YES;
    }
    [self.studentCollectionView reloadData];

    NSLog(@"Select Clicked");
}


- (void)selectAllClicked{
    if (selectedStudents.count != studentsData.count){
        for (NSInteger index = 0; index < studentsData.count; index++) {
            NSNumber *studentId = [[studentsData allKeys] objectAtIndex:index];
            
            student *ss = [studentsData objectForKey:studentId];
            [selectedStudents setObject:ss forKey:studentId];
        }
        
        for (NSInteger row = 0; row < [self.studentCollectionView numberOfItemsInSection:0]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            StudentCollectionViewCell *cell = (StudentCollectionViewCell *)[self.studentCollectionView cellForItemAtIndexPath:indexPath];
            [cell setBackgroundColor:[Utilities CHGoldColor]];
            
            [self.studentCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
    
    else {
        [self deselectAllClicked];
    }
}


- (void)deselectAllClicked{
    [selectedStudents removeAllObjects];
    for (NSInteger row = 0; row < [self.studentCollectionView numberOfItemsInSection:0]; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        StudentCollectionViewCell *cell = (StudentCollectionViewCell *)[self.studentCollectionView cellForItemAtIndexPath:indexPath];
        [cell setBackgroundColor:[Utilities CHBlueColor]];

        [self.studentCollectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES];
    }
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
        [self showCategoryView];
    }
    else {
        [Utilities disappearingAlertView:@"Select students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
    }
}


- (void)showCategoryView{
    self.categoryStudentsNameLabel.text = [self displayStringForMultipleSelectedStudents];
    if (categories.count == 0){
        self.categoryPicker.hidden = YES;
        
    }
    
    
    self.categoryView.hidden = NO;
    
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
    if (selectedStudents.count > 0){
        // show a subtract dialog here - copy from student table view controller
    }
    else {
        [Utilities disappearingAlertView:@"Select students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
    }
}


- (void)subtractOneSelected{
    if (selectedStudents.count > 0){
        // show a subtract dialog here - copy from student table view controller
    }
    else {
        [Utilities disappearingAlertView:@"Select students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
    }
}


- (void)subtractPointsClicked{
    if (selectedStudents.count > 0){
        // show a subtract dialog here - copy from student table view controller
    }
    else {
        [Utilities disappearingAlertView:@"Select students first" message:nil otherTitles:nil tag:0 view:self time:1.0];
    }
}


- (IBAction)profileClicked:(id)sender {
    [self performSegueWithIdentifier:@"home_to_profile" sender:self];
}


- (IBAction)classListClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)categoryAddPointsClicked:(id)sender {
    if ([selectedCategory getId] != 0 ){
        isMakingWebCall = YES;
        [webHandler rewardStudentsWithids:[[NSMutableArray alloc]initWithArray:[selectedStudents allKeys]] reinforcerId:[selectedCategory getId]];
    }
    else {
        
        NSString *points = self.categoryPointsTextField.text;
        
        if ([points isEqualToString:@""] || !points){
            [Utilities alertStatusWithTitle:@"Points is required" message:nil cancel:nil otherTitles:nil tag:0 view:self];
            
            [self.categoryPointsTextField becomeFirstResponder];

        }
        else {
            NSString *comments = self.commentsTextField.text;
            
            NSString *pointsError = [Utilities isNumeric:points];
            
            if (!pointsError){
                isMakingWebCall = YES;
                NSInteger pointsInt = points.integerValue;
                [selectedCategory setValue:pointsInt];
                [webHandler addPointsWithStudentIds:[[NSMutableArray alloc]initWithArray:[selectedStudents allKeys]] points:pointsInt];
            }
            else {
                [Utilities alertStatusWithTitle:[NSString stringWithFormat:@"%@ is invalid. Points must be numeric.", points] message:nil cancel:nil otherTitles:nil tag:0 view:self];
            }
        }
    }
    
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
    [Utilities editAlertTextWithtitle:@"Add category" message:nil cancel:@"Cancel"  done:nil delete:NO textfields:@[@"e.g. Participation points", @"e.g. 2"] tag:2 view:self];
}


- (IBAction)categoryEditCategoryClicked:(id)sender {
    if (categories.count > 0 && !isMakingWebCall && !([selectedCategory getId] == 0)){
        NSInteger index = [self.categoryPicker selectedRowInComponent:0];
        NSNumber *categoryId = [[[categories allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:index];
        selectedCategory = [categories objectForKey:categoryId];
        [Utilities editTextWithtitle:@"Edit Category" message:nil cancel:nil done:nil delete:YES textfields:@[[selectedCategory getName], [NSString stringWithFormat:@"%ld", (long)[selectedCategory getValue]]] tag:1 view:self];
    }
}


#pragma mark <SlideMenuDelegate>

- (void)leftViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super leftViewWillLayoutSubviewsWithSize:size];
    
    if (!self.isLeftViewStatusBarHidden) {
        self.leftView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
    }
}

- (void)rightViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super rightViewWillLayoutSubviewsWithSize:size];
    
    if (!self.isRightViewStatusBarHidden ||
        (self.rightViewAlwaysVisibleOptions & LGSideMenuAlwaysVisibleOnPadLandscape &&
         UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
         UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation))) {
            self.rightView.frame = CGRectMake(0.0, 20.0, size.width, size.height-20.0);
        }
}

- (BOOL)isLeftViewStatusBarHidden {
    
    return super.isLeftViewStatusBarHidden;
}

- (BOOL)isRightViewStatusBarHidden {
    return super.isRightViewStatusBarHidden;
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
        [categories setObject:selectedCategory forKey:[NSNumber numberWithInteger:[selectedCategory getId]]];
        [self.categoryPicker reloadAllComponents];
        //selectedCategory = [categories objectForKey:[[categories allKeys] objectAtIndex:0]];
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
        [categories setObject:rr forKey:[NSNumber numberWithInteger:[rr getId]]];

        [self.categoryPicker reloadAllComponents];
        
        [self.categoryPicker selectRow:(categories.count-1) inComponent:0 animated:NO];
        selectedCategory = [categories objectForKey:[[categories allKeys] objectAtIndex:(categories.count-1)]];

        [self setCategoryLabels];
        
        self.categoryEditCategoryButton.hidden = NO;
        self.categoryPicker.hidden = NO;
        
    }
    else if (type == DELETE_REINFORCER){
        [[DatabaseHandler getSharedInstance]deleteReinforcer:[selectedCategory getId]];
        [categories removeObjectForKey:[NSNumber numberWithInteger:[selectedCategory getId]]];
        [self.categoryPicker reloadAllComponents];
        

            [self setCategoryLabels];
    }
    
    else if (type == REWARD_STUDENT_BULK){
        self.categoryView.hidden = YES;

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
        self.categoryView.hidden = YES;

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
    [blurEffectView removeFromSuperview];

    NSString *successString;
    float time = 0;
    if (!tmpCategoryName){
        time = 1.7;
        successString = [NSString stringWithFormat:@"+%ld to %@", (long)[selectedCategory getValue], [self displayStringForMultipleSelectedStudents]];
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
    NSAttributedString *str;
    if ([selectedCategory getId] == 0){
        str = [[NSAttributedString alloc] initWithString:@"Points" attributes:nil];
        self.categoryNameLabel.text = @"Uncategorized Points";
    }
    else {
        str = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld points", (long)[selectedCategory getValue]] attributes:nil];
        self.categoryNameLabel.text = [selectedCategory getName];
    }
    
    self.categoryPointsTextField.attributedPlaceholder = str;
    
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"Comments (Optional)" attributes:nil];
    
    self.commentsTextField.attributedPlaceholder = str2;
}


- (void)getStudentsData{
    studentsData = [[NSMutableDictionary alloc]init];
    NSMutableArray *studentsDataArray = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES studentIds:[currentUser.students allKeys]];
    
    for (student *tmpStudent in studentsDataArray){
        [studentsData setObject:tmpStudent forKey:[NSNumber numberWithInteger:[tmpStudent getId]]];
    }
}


- (void)getCategoryData{
    categories = [[NSMutableDictionary alloc]init];

    NSMutableArray *categoryData = [[DatabaseHandler getSharedInstance]getReinforcers:[currentUser.currentClass getId]];
    for (reinforcer *tmpCategory in categoryData){
        [categories setObject:tmpCategory forKey:[NSNumber numberWithInteger:[tmpCategory getId]]];
    }
    reinforcer *noneReinforcer = [[reinforcer alloc]init:0 :[currentUser.currentClass getId] :@"Uncategorized Points" :0];
    
    [categories setObject:noneReinforcer forKey:[NSNumber numberWithInt:0]];
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


- (IBAction)backClicked:(id)sender {
    [self performSegueWithIdentifier:@"unwind_to_classes" sender:self];
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}


@end
