//
//  RegisterStudentsViewController.m
//  Classroom Hero
//
//  Created by Josh on 8/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "RegisterStudentsViewController.h"
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "HomeViewController.h"

@interface RegisterStudentsViewController (){
    NSMutableArray *unregisteredStudents;
    user *currentUser;
    bool isStamping;
    NSInteger registerIndex;
    NSInteger flag;
}

@end

@implementation RegisterStudentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser =[user getInstance];
    unregisteredStudents = [[NSMutableArray alloc]init];
    unregisteredStudents = [[DatabaseHandler getSharedInstance]getUnregisteredStudents:[currentUser.currentClass getId]];
    
    NSLog(@"We got %d unregistered students", unregisteredStudents.count);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImg1"]];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    
    
    // Set up Snowshoe
    self.appKey = snowshoe_app_key ;
    self.appSecret = snowshoe_app_secret;
    
    [self displayName:registerIndex];

}


- (void)viewDidAppear:(BOOL)animated{
    unregisteredStudents = [[DatabaseHandler getSharedInstance]getUnregisteredStudents:[currentUser.currentClass getId]];
    
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self nextStudent];
        
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        [self previousStudent];
    }
    
}

- (void)previousStudent {
    if(registerIndex == 0){
        registerIndex = [unregisteredStudents count] - 1;
    }
    else registerIndex--;
    [self displayName:registerIndex];
    
}

- (void)nextStudent {
    if (++registerIndex >= [unregisteredStudents count]){
        registerIndex = 0;
    }
    [self displayName:registerIndex];
    
}

-(void) displayName:(NSInteger)index{
    if ([unregisteredStudents count] != 0)
    {
        student *ss = [unregisteredStudents objectAtIndex:index];
        NSString *name = [ss getFirstName];
        name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", [ss getLastName]]];
        self.studentNameLabel.text = name;
        self.stampToRegisterLabel.hidden = NO;

    }
    else{
        self.studentNameLabel.text=@"All  Students  Registered";
        self.stampToRegisterLabel.hidden = YES;
    }
    
}

- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
}



- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)skipButtonClicked:(id)sender {
    if (flag == 1){
        [self performSegueWithIdentifier:@"register_students_to_home" sender:self];

    }
    if (flag == 2){
        [self.navigationController popViewControllerAnimated:YES];
    }
}


 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"register_students_to_home"]){
         if (flag == 1){
             HomeViewController *vc = [segue destinationViewController];
             [vc setFlag:1];
         }
     }


 }
 


@end
