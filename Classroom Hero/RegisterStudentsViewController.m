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
    unregisteredStudents = [[NSMutableArray alloc]init];
    unregisteredStudents = [[DatabaseHandler getSharedInstance]getUnregisteredStudents:[currentUser.currentClass getId]];
    if ([unregisteredStudents count] != 0)
    {
        self.stampToRegisterLabel.hidden = NO;
        self.swipeLabel.hidden = NO;
    }
    
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
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
                            [webHandler registerStamp:[ss getId] :stampSerial];
                            
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
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        isStamping = NO;
        return;
    }
    if (type == REGISTER_STAMP){
        NSInteger count = unregisteredStudents.count;
        student *ss = [unregisteredStudents objectAtIndex:registerIndex];
        [[DatabaseHandler getSharedInstance] registerStudent:[ss getId] :[ss getSerial]];
        [hud hide:YES];
        [unregisteredStudents removeObjectAtIndex:registerIndex];
        [Utilities wiggleImage:self.stampImage sound:YES];

        count--;
        if (count == 0) {
            self.swipeLabel.text = @"All  Students  Registered";
        }
        
        if (registerIndex >= count  && count  > 0){
            registerIndex = 0;
            [self displayName:registerIndex];
            
        }
        isStamping = NO;
        [self displayName:registerIndex];

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
 


@end
