//
//  TutorialViewController.m
//  Classroom Hero
//
//  Created by Josh on 7/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "TutorialViewController.h"
#import "Utilities.h"

@interface TutorialViewController (){
    user *currentUser;
}

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    NSLog(@"In view did load Tutorial View");
    [super viewDidLoad];
    currentUser = [user getInstance];
    // Do any additional setup after loading the view.
    _pageTitles = @[@"Welcome  to  Classroom  Hero!  Swipe  left  to  navigate  this  tutorial  and  begin  your  adventure!", @"Create  a  class  to  get  started.  Enter  a  name  for  your  class  and  scroll  to  your  school.", @"Add  some  students  to  your  class.  Type  in  a  student  name  below", @"Create  some  Positive  Reinforcers  to  award  points  for.  Examples:  On  time,  Working  hard,  Setting  good  example.", @"Create  some  market  place  items  for  students  to  spend  their  points  on", @"Add  a  class  jar  for  a  class-wide  reward  achieved  over  a  longer  time.  Examples:  Pizza  Party,  Movie  Day,  Field  Trip.", @"Finally,  stamp  the  screen  to  register  yourself  as  a  teacher  and  begin  your  journey  with  Classroom  Hero!"];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    TutorialContentViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((TutorialContentViewController *) viewController).pageIndex;
    
    if ((index ==0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = ((TutorialContentViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    return [self viewControllerAtIndex:index];
}

- (TutorialContentViewController *)viewControllerAtIndex:(NSUInteger)index{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])){
        return nil;
    }
    TutorialContentViewController *tutorialContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialContentViewController"];
    tutorialContentViewController.pageIndex = index;
    tutorialContentViewController.titleText = self.pageTitles[index];
    if (index == 1){
        tutorialContentViewController.schoolData = [[DatabaseHandler getSharedInstance] getSchools];
    }
    return tutorialContentViewController;
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (IBAction)startTutorial:(id)sender {
    TutorialContentViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
}
- (IBAction)backClicked:(id)sender {
    [self performSegueWithIdentifier:@"tutorial_to_login" sender:self];
    
}

- (IBAction)skipClicked:(id)sender {
    if ((currentUser.currentClassId != 0) && ![currentUser.serial isEqualToString:@""]){
        [self performSegueWithIdentifier:@"tutorial_to_welcome" sender:nil];
    }
    else {
        [Utilities alertStatus:@"Slow down!" :@"You must create a class and register your stamp before proceeding" :@"Okay" :nil :1];
    }
}

@end
