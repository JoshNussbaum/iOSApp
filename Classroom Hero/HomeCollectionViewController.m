//
//  HomeCollectionViewController.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 1/28/17.
//  Copyright © 2017 Josh Nussbaum. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "StudentCollectionViewCell.h"
#import "DatabaseHandler.h"
#import "ConnectionHandler.h"
#import "Utilities.h"


@interface HomeCollectionViewController (){
    user *currentUser;
    ConnectionHandler *webHandler;
    NSMutableDictionary *studentsData;
    NSMutableDictionary *selectedStudents;
}

@end

@implementation HomeCollectionViewController

static NSString * const reuseIdentifier = @"StudentCollectionViewCell";
static NSString * const reuseIdentifierHeader = @"HeaderCollectionViewCell";
static NSString * const reuseIdentifierFooter = @"FooterCollectionViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    selectedStudents = [[NSMutableDictionary alloc]init];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];
    [self getStudentsData];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[StudentCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionHeadersPinToVisibleBounds = YES;
    flowLayout.sectionFootersPinToVisibleBounds = YES;
    [flowLayout setItemSize:CGSizeMake(190, 190)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.collectionView.collectionViewLayout = flowLayout;
    
    // Do any additional setup after loading the view.
}

- (void)getStudentsData{
    studentsData = [[NSMutableDictionary alloc]init];
    NSMutableArray *studentsDataArray = [[DatabaseHandler getSharedInstance]getStudents:[currentUser.currentClass getId] :YES studentIds:currentUser.studentIds];
    
    for (student *tmpStudent in studentsDataArray){
        [studentsData setObject:tmpStudent forKey:[NSNumber numberWithInteger:[tmpStudent getId]]];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    if (cell.selected){
        cell.backgroundColor = [UIColor blueColor];
    }
    else {
        cell.backgroundColor = [UIColor redColor];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    StudentCollectionViewCell *datasetCell = (StudentCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.backgroundColor = [UIColor blueColor]; // highlight selection
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    StudentCollectionViewCell *datasetCell =(StudentCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.backgroundColor = [UIColor redColor]; // Default color
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
        //UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, collectionView.frame.size.width, 60)];

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
        
        
        UILabel *attendanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,8,width-16,44)];
        attendanceLabel.text = @"Attendance";
        
        UILabel *classJarLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,8,width-16,44)];
        classJarLabel.text = @"Class Jar";
        
        UILabel *marketLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,8,width-16,44)];
        marketLabel.text = @"Market";
        
        NSArray *labels = @[attendanceLabel, classJarLabel, marketLabel];
        
        for (UILabel *label in labels){
            label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:18];
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
            [view setBackgroundColor:[Utilities CHBlueColor]];
            
            [cell addSubview:view];
        }
        
        
    }
    else if (kind == UICollectionElementKindSectionFooter){
        cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:reuseIdentifierFooter
                                                         forIndexPath:indexPath];
        float width = collectionView.frame.size.width / 4;

        UIView *addPointsSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 60)];
        UIView *subtractPointsSection = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, 60)];
        UIView *chestSection = [[UIView alloc] initWithFrame:CGRectMake(width * 2, 0, width, 60)];
        UIView *selectSection = [[UIView alloc] initWithFrame:CGRectMake(width * 3, 0, width, 60)];
        
        // Add gestures to the sections
        UITapGestureRecognizer *addPointsGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(addPointsClicked)];
        [addPointsSection addGestureRecognizer:addPointsGesture];
        
        UITapGestureRecognizer *generateChestGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(generateChestClicked)];
        [chestSection addGestureRecognizer:generateChestGesture];
        
        UITapGestureRecognizer *subtractPointsGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(subtractPointsClicked)];
        [subtractPointsSection addGestureRecognizer:subtractPointsGesture];
        
        UITapGestureRecognizer *selectGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(selectClicked)];
        [selectSection addGestureRecognizer:selectGesture];
        
        
        
        UILabel *addPointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,8,width-16,44)];
        addPointsLabel.text = @"Add Points";
        
        UILabel *generateChestLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,8,width-16,44)];
        generateChestLabel.text = @"Generate Chest";
        
        UILabel *subtractPointsLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,8,width-16,44)];
        subtractPointsLabel.text = @"Subtract";
        
        UILabel *selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,8,width-16,44)];
        selectLabel.text = @"Select";
        
        NSArray *labels = @[addPointsLabel, generateChestLabel, subtractPointsLabel, selectLabel];
        
        for (UILabel *label in labels){
            label.font = [UIFont fontWithName:@"GillSans-SemiBold" size:18];
            label.textColor = [UIColor blackColor];
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor whiteColor];
            [Utilities makeRoundedLabel:label :nil];
        }
        
        [addPointsSection addSubview:addPointsLabel];
        [chestSection addSubview:generateChestLabel];
        [subtractPointsSection addSubview:subtractPointsLabel];
        [selectSection addSubview:selectLabel];
        
        NSArray *sections = @[addPointsSection, chestSection, subtractPointsSection, selectSection];
        
        for (UIView *view in sections){
            [view setBackgroundColor:[Utilities CHBlueColor]];
            
            [cell addSubview:view];
        }
    }
    
    return cell;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}



- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


- (void)selectClicked{
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
    
}

- (void)generateChestClicked{
    NSLog(@"Generate Chest Clicked");
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


@end
