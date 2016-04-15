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
#import "DatabaseHandler.h"
#import "Flurry.h"


@interface RegisterTeacherStampViewController (){
    user *currentUser;
    MBProgressHUD *hud;
    ConnectionHandler *webHandler;
    NSString *serial;
    bool isStamping;
}

@end

@implementation RegisterTeacherStampViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isStamping = NO;
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    
    [Utilities makeRoundedButton:self.unregisterStampButton :nil];
    
    [self setLabels];
}


- (IBAction)unreigsterClicked:(id)sender {
    if (currentUser.serial){
        [Utilities alertStatusWithTitle:@"Confirm unregister" message:@"Really unregister your teacher stamp?" cancel:@"Cancel" otherTitles:@[@"Unregister"] tag:0 view:self];
    }
}


- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)stampResultDidChange:(NSString *)stampResult{
    if (!currentUser.serial){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                isStamping = YES;
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                    if (![[DatabaseHandler getSharedInstance]isSerialRegistered:stampSerial]){
                        serial = stampSerial;
                        [self activityStart:@"Registering stamp..."];
                        [webHandler registerStamp:currentUser.id :stampSerial :[currentUser.currentClass getId]];
                    }
                    else {
                        [Utilities failAnimation:self.stampImage];
                        isStamping = NO;
                    }
                }
                else{
                    [Utilities failAnimation:self.stampImage];
                    isStamping = NO;
                }
                
            }
        }
    }
    
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
    [hud hide:YES];
    if (data == nil){
        [Utilities alertStatusNoConnection];
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    
    if([successNumber boolValue] == YES)
    {
        if (type == UNREGISTER_STAMP){
            currentUser.serial = nil;
            [self setLabels];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Unregister Teacher Stamp - Register Teacher" withParameters:params];
        }
        else if (type == REGISTER_STAMP){
            currentUser.serial = serial;
            currentUser.accountStatus = 2;
            [Utilities wiggleImage:self.stampImage sound:YES];
            [self setLabels];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Register Teacher Stamp - Register Teacher" withParameters:params];
        }
        
    }
    else {
        NSString *message = [data objectForKey:@"message"];
        NSString *errorMessage;
        
        if (type == UNREGISTER_STAMP){
            errorMessage = @"Error unregistering stamp";
        }
        else if (type == REGISTER_STAMP){
            errorMessage = @"Error registering stamp";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
    }
    isStamping = NO;
}


- (void)setLabels{
    if (!currentUser.serial){
        self.topLabel.text = [NSString stringWithFormat:@"%@, stamp to register your teacher stamp", currentUser.firstName];
        self.unregisterStampButton.hidden = YES;
    }
    else {
        self.topLabel.text = [NSString stringWithFormat:@"%@, click the unregister stamp button below to unregister your stamp", currentUser.firstName];
        self.unregisterStampButton.hidden = NO;
    }
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}



@end
