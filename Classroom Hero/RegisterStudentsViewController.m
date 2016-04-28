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
#import "MBProgressHUD.h"
#import "SettingsViewController.h"
#import "Flurry.h"

@interface RegisterStudentsViewController (){
    NSMutableArray *unregisteredStudents;
    user *currentUser;
    bool isStamping;
    NSInteger registerIndex;
    NSInteger flag;
    ConnectionHandler *webHandler;
    MBProgressHUD *hud;
}

@end

@implementation RegisterStudentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentUser =[user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    self.appKey = snowshoe_app_key ;
    self.appSecret = snowshoe_app_secret;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImg1"]];

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    
    unregisteredStudents = [[NSMutableArray alloc]init];
    unregisteredStudents = [[DatabaseHandler getSharedInstance]getUnregisteredStudents:[currentUser.currentClass getId]];
    if ([unregisteredStudents count] != 0)
    {
        self.stampToRegisterLabel.hidden = NO;
        self.swipeLabel.hidden = NO;
    }
    
    [self displayName:registerIndex];
}


- (void)viewWillAppear:(BOOL)animated{
    unregisteredStudents = [[DatabaseHandler getSharedInstance]getUnregisteredStudents:[currentUser.currentClass getId]];
    registerIndex = 0;
    [self displayName:0];
    if (flag == 1){
        [self.skipButton setTitle:@"Continue" forState:UIControlStateNormal];
    }
    else if (flag == 3 || flag == 2){
        [self.skipButton setTitle:@"Settings" forState:UIControlStateNormal];
        [self.classesButton setHidden:YES];

    }
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
    if (flag == 3){
        UIStoryboard *storyboard = self.storyboard;
        
        HomeViewController *hvc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        SettingsViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        
        [hvc setFlag:1];
        [self.navigationController pushViewController:hvc animated:NO];
        
        [svc setFlag:1];
        [self.navigationController pushViewController:svc animated:NO];
    }
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


- (void)displayName:(NSInteger)index{
    if ([unregisteredStudents count] != 0)
    {
        student *ss = [unregisteredStudents objectAtIndex:index];
        NSString *name = [ss getFirstName];
        name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", [ss getLastName]]];
        
        
        [UIView animateWithDuration:.1
                         animations:^{
                             self.studentNameLabel.alpha = 0.0;
                         }completion:^(BOOL finished) {
                             self.studentNameLabel.text = name;

                             [UIView animateWithDuration:.1
                                              animations:^{
                                                  self.studentNameLabel.alpha = 1.0;
                                              }
                              ];
                         }
         ];

    }
    else{
        self.studentNameLabel.text=@"All  Students  Registered";
        self.stampToRegisterLabel.hidden = YES; 
        self.swipeLabel.hidden = YES;
    }
    
}


- (void)stampResultDidChange:(NSString *)stampResult{
    if (!isStamping){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                
                if ([Utilities isValidClassroomHeroStamp:stampSerial] && ![stampSerial isEqualToString:currentUser.serial]){
                    if (unregisteredStudents.count != 0){
                        if (![[DatabaseHandler getSharedInstance] isSerialRegistered:stampSerial] && ![stampSerial isEqualToString:currentUser.serial])
                        {
                            [self activityStart:@"Registering stamp..."];

                            isStamping = YES;
                            [Utilities wiggleImage:self.stampImage sound:NO];
                            student *ss = [unregisteredStudents objectAtIndex:registerIndex];
                            [ss setSerial:stampSerial];
                            [webHandler registerStamp:[ss getId] :stampSerial :[currentUser.currentClass getId]];
                            
                        }
                        else {
                            [Utilities failAnimation:self.stampImage];
                        }
                    }
                    else {
                        [Utilities failAnimation:self.stampImage];
                    }
                }else {
                    [Utilities failAnimation:self.stampImage];
                }
            }
            else {
                [Utilities failAnimation:self.stampImage];
            }
        }
    }

}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    isStamping = NO;
    [hud hide:YES];
    
    if (data == nil){
        [Utilities alertStatusNoConnection];
        return;
    }
    
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    NSString *message = [data objectForKey:@"message"];
    
    if (type == REGISTER_STAMP){
        if ([successNumber boolValue] == YES){
            [Utilities wiggleImage:self.stampImage sound:YES];
            NSInteger count = unregisteredStudents.count;

            student *ss = [unregisteredStudents objectAtIndex:registerIndex];
            [[DatabaseHandler getSharedInstance] registerStudent:[ss getId] :[ss getSerial]];
            [unregisteredStudents removeObjectAtIndex:registerIndex];
            
            count--;
            [currentUser.currentClass addPoints:1];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
            
            if (count == 0) {
                self.swipeLabel.text = @"All  Students  Registered";
            }
            
            if (registerIndex >= count  && count  > 0){
                registerIndex = 0;
                [self displayName:registerIndex];
                
            }
            [self displayName:registerIndex];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@ %@", [ss getFirstName], [ss getLastName]],@"Student Name", [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Register Student - Register Students" withParameters:params];
        }
        else{
            [Utilities alertStatusWithTitle:@"Error registering student" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            return;
        }

    }


    
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
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


- (IBAction)unwindToRegisterStudents:(UIStoryboardSegue *)unwindSegue {
    
}


- (void)setFlag:(NSInteger)flag_{
    flag = flag_;
}


@end
