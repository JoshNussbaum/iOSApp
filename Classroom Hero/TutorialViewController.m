//
//  TutorialViewController.m
//  Classroom Hero
//
//  Created by Josh on 7/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "TutorialViewController.h"
#import "Utilities.h"
#import "NSString+FontAwesome.h"
#import "Class.h"
#import <Google/Analytics.h>

@interface TutorialViewController (){
    user *currentUser;
    NSInteger flag;
    NSInteger pageIndex;
    class *tmpClass;
}

@end

@implementation TutorialViewController

- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Tutorial"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (flag == 1){
        _pageTitles = @[@"Welcome  to  Classroom  Hero!  Swipe  left  to  get  started", @"Create  a  class", @"Add  students  to  your  selected  class", @"Assign  point  values  to  categories", @"Add  items  for  students  to  spend  points  on", @"Add  a  jar  for  a  class-wide  reward", @"Click  continue  to  begin  your  adventure  with  Classroom  Hero!"];
        self.backButton.enabled = YES;
        self.backButton.hidden = NO;

    }
    if (flag == 2){
        [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
        [self.skipButton setHidden:YES];
        _pageTitles = @[@"Swipe  left  to  get  started", @"Create  a  class", @"Add  students  to  your  selected  class", @"Assign  point  values  to  categories", @"Add  items  for  students  to  spend  points  on", @"Add  a  jar  for  a  class-wide  reward", @"Click  back  to  return  to  the  settings  screen"];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    self.arrowLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    self.arrowLabel.text = [NSString fontAwesomeIconStringForEnum:FAArrowRight];
    self.arrowLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(arrowLabelTapped)];
    [self.arrowLabel addGestureRecognizer:tapGesture];

    currentUser = [user getInstance];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    TutorialContentViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    if (self.view.frame.size.height == 1366) {
        self.pageViewController.view.frame = CGRectMake(52, 0, self.view.frame.size.width - 104, self.view.frame.size.height-120);
    }
    else {
        self.pageViewController.view.frame = CGRectMake(52, 0, self.view.frame.size.width - 104, self.view.frame.size.height-60);
    }
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    NSArray *buttons = @[self.startOverButton, self.skipButton, self.backButton];
    for (UIButton *button in buttons){
        [Utilities makeRounded:button.layer color:nil borderWidth:0.5f cornerRadius:5];
    }
    tmpClass = currentUser.currentClass;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTmpClass:)
                                                 name:@"SetTmpClass"
                                               object:nil];
    

}


- (void)setTmpClass:(NSNotification *)notification{
    NSDictionary* userInfo = notification.object;
    class* tmpClass_ = userInfo[@"tmpClass"];
    tmpClass = tmpClass_;
}


- (void)arrowLabelTapped{
    if (pageIndex != 6){
        pageIndex += 1;
        TutorialContentViewController *initialViewController = [self viewControllerAtIndex:pageIndex];

        [self.pageViewController setViewControllers:@[initialViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}


- (IBAction)startTutorial:(id)sender {
    pageIndex = 0;
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
    pageIndex = index;
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])){
        return nil;
    }
    TutorialContentViewController *tutorialContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialContentViewController"];
    [tutorialContentViewController setTmpClass:tmpClass];
    tutorialContentViewController.pageIndex = index;
    tutorialContentViewController.titleText = self.pageTitles[index];
    if (index > 1 && index < 6){
        tutorialContentViewController.classData = [[DatabaseHandler getSharedInstance] getClasses];
    }
    if (index == [self.pageTitles count]-1){
        self.arrowLabel.hidden = YES;
    }
    else {
        self.arrowLabel.hidden = NO;
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
