//
//  RegisterTeacherStampViewController.m
//  Classroom Hero
//
//  Created by Josh on 10/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "RegisterTeacherStampViewController.h"
#import "Utilities.h"
#import "MBProgressHUD.h"


@interface RegisterTeacherStampViewController (){
    user *currentUser;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
}

@end

@implementation RegisterTeacherStampViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    
    [Utilities makeRoundedButton:self.unregisterStampButton :[UIColor blackColor]];
    
    [self setLabels];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    else{
        [self activityStart:@"Unregistering stamp..."];
        [webHandler unregisterStampWithid:currentUser.id];
    }
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    NSLog(@"In register teacher stamp -> %@", data);
    if (data == nil){
        [Utilities alertStatusNoConnection];
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == UNREGISTER_STAMP){
        
        if([successNumber boolValue] == YES)
        {
            currentUser.serial = nil;
            [self setLabels];
        }
        else{
            [Utilities failAnimation:self.stampImage];
        }
    }
}

- (void)setLabels{
    if (!currentUser.serial){
        self.topLabel.text = [NSString stringWithFormat:@"%@,  stamp  the  apple  to  register  your  teacher  stamp", currentUser.firstName];
    }
    else {
        self.topLabel.text = [NSString stringWithFormat:@"%@,  click  the   unregister  stamp  button  below  to  unregister  your  stamp", currentUser.firstName];
    }
}


- (IBAction)unreigsterClicked:(id)sender {
    [Utilities alertStatusWithTitle:@"Confirm unregister" message:@"Really unregister your teacher stamp?" cancel:@"Cancel" otherTitles:nil tag:0 view:self];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}



@end
