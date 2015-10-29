//
//  StampIdentifierViewController.m
//  Classroom Hero
//
//  Created by Josh on 10/19/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import "StampIdentifierViewController.h"
#import "student.h"
#import "MBProgressHUD.h"
#import "Utilities.h"



@interface StampIdentifierViewController (){
    user *currentUser;
    student *currentStudent;
    bool isStamping;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
}

@end

@implementation StampIdentifierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    else{
        [self activityStart:@"Unregistering stamp..."];
        [webHandler unregisterStampWithid:[currentStudent getId]];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    NSLog(@"In stamp identifier-> %@", data);
    [hud hide:YES];
    isStamping = NO;
    if (data == nil){
        [Utilities alertStatusNoConnection];
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == UNREGISTER_STAMP){
        
        if([successNumber boolValue] == YES)
        {
            
            currentUser.serial = nil;
            [Utilities alertStatusWithTitle:@"Successfully unregistered stamp" message:nil cancel:nil otherTitles:nil tag:0 view:self];
            
        }
        else{
            [Utilities failAnimation:self.stampImage];
        }
    }

    
}



- (void)stampResultDidChange:(NSString *)stampResult{
    NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (resultObject != NULL) {
        if ([resultObject objectForKey:@"stamp"] != nil){
            isStamping = YES;
            NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
            if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                
            }
            else{
                [Utilities failAnimation:self.stampImage];
                isStamping = NO;
            }
            
        }
    }
}

- (IBAction)unregisterStampClicked:(id)sender {
}

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


@end
