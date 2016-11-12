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
    NSInteger flag;
}


@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (flag == 1){
        _pageTitles = @[@"Welcome  to  Classroom  Hero!  Swipe  left  to  get  started", @"Create  a  class", @"Add  students  to  your  selected  class", @"Assign  point  values  to  reinforcers", @"Add  items  for  students  to  spend  points  on", @"Add  a  jar  for  a  class-wide  reward", @"Click  continue  to  begin  your  adventure  with  Classroom  Hero!"];
        self.backButton.enabled = YES;
        self.backButton.hidden = NO;

    }
    if (flag == 2){
        [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
        [self.skipButton setHidden:YES];
        _pageTitles = @[@"Swipe  left  to  create  a  class  and  register  a  teacher  stamp", @"Create  a  class", @"Add  students  to  your  selected  class", @"Assign  point  values  to  reinforcers", @"Add  items  for  students  to  spend  points  on", @"Add  a  jar  for  a  class-wide  reward", @"Click  back  to  return  to  the  settings  screen"];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    currentUser = [user getInstance];
    // Do any additional setup after loading the view.

    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    TutorialContentViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    NSArray *buttons = @[self.startOverButton, self.skipButton, self.backButton];
    for (UIButton *button in buttons){
        [Utilities makeRoundedButton:button :[Utilities CHBlueColor]];
    }

}


- (IBAction)startTutorial:(id)sender {
    TutorialContentViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
}


- (IBAction)backClicked:(id)sender {
    if (flag == 1){
        [self performSegueWithIdentifier:@"tutorial_to_login" sender:self];
    }
    if (flag ==2){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}


- (IBAction)skipClicked:(id)sender {
    if (flag == 1){
        [self performSegueWithIdentifier:@"tutorial_skip_to_class" sender:nil];
    }
    if (flag ==2){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
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


@end
