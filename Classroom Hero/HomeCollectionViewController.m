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

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    selectedStudents = [[NSMutableDictionary alloc]init];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self token:currentUser.token classId:[currentUser.currentClass getId]];
    [self getStudentsData];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
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
    return studentsData.count-1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *studentId = [[studentsData allKeys] objectAtIndex:indexPath.row];
    student *student_ = [studentsData objectForKey:studentId];
    StudentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.levelLabel.text = [NSString stringWithFormat:@"%ld", (long)[student_ getLvl]];
    cell.pointsLabel.text = [NSString stringWithFormat:@"%ld", (long)[student_ getPoints]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


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

- (IBAction)selectClicked:(id)sender {
}

- (IBAction)attendanceClicked:(id)sender {
}

- (IBAction)marketClicked:(id)sender {
}

- (IBAction)jarClicked:(id)sender {
}

- (IBAction)addPointsClicked:(id)sender {
}

- (IBAction)subtractPointsClicked:(id)sender {
}
@end
