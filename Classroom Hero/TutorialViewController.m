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
    _pageTitles = @[@"Welcome   to   Classroom   Hero!   Swipe   left   to   get   started", @"Add   a   class   that   belongs   to   your   school", @"Add   students   to   your   selected   class", @"Add   positive   reinforcers   to   categorize   points   awarded   to   students", @"Add   market   place   items   for   students   to   spend   their   points   on", @"Add   a   jar   that   only   your   teacher   stamp   can   add   points   to   for   a   class-wide   reward", @"Stamp   the   apple   to   register   your   teacher   stamp   and   begin   your   journey  with   Classroom   Hero!"];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    TutorialContentViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [Utilities makeRoundedButton:self.backButton :nil];
    [Utilities makeRoundedButton:self.startOverButton :nil];
    [Utilities makeRoundedButton:self.skipButton :nil];
}


#pragma mark - Page View Controller Data Source


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((TutorialContentViewController *) viewController).pageIndex;
    
    if ((index ==0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
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
    if (index > 1 && index < 6){
        tutorialContentViewController.classData = [[DatabaseHandler getSharedInstance] getClasses];
    }
    return tutorialContentViewController;
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return [self.pageTitles count];
}


- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}


- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
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
    if ((currentUser.currentClassId != 0)){
        [self performSegueWithIdentifier:@"tutorial_skip_to_class" sender:nil];
    }
    else {
        [Utilities alertStatusWithTitle:@"Slow down!" message:@"You must create a class before proceding" cancel:nil otherTitles:nil tag:0 view:nil];
    }
}

@end
