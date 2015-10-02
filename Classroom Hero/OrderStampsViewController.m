//
//  OrderStampsViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/27/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "OrderStampsViewController.h"
#import "Utilities.h"
#import "MBProgressHUD.h"


@interface OrderStampsViewController (){
    NSInteger stamps;
    ConnectionHandler *webHandler;
    user *currentUser;
    float price;
    NSInteger orderId;
    MBProgressHUD *hud;
}

@end

@implementation OrderStampsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *buttons = @[self.recruitButton, self.heroicButton, self.legendaryButton, self.placeOrderButton];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    currentUser = [user getInstance];
    for (UIButton *button in buttons){
        [Utilities makeRoundedButton:button :[UIColor whiteColor]];
    }
    [self.stampsTextfield addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}


- (void)textFieldDidChange:(UITextField *)textfield{
    NSString *input = textfield.text;
    NSString *errorMessage = [Utilities isNumeric:input];
    if ([errorMessage isEqualToString:@""]){
        stamps = input.integerValue;
        if (stamps < 10){
            price = stamps;
            self.costLabel.text = @"Must  order  at  least  10  stamps";
            return;
        }
        if (stamps > 60){
            price = stamps * .9;
        }
        else if (stamps > 120){
            price = stamps * .8;
        }
        else if (stamps > 300){
            price = stamps * .7;
        }
        else price = stamps;
        
        self.costLabel.text = [NSString stringWithFormat:@"$%.02f/year", price];
    }
    else {
        self.costLabel.text = errorMessage;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    else{
        [self activityStart:@"Placing order..."];
        [webHandler orderStampsWithid:currentUser.id packageId:alertView.tag :stamps :[currentUser.currentClass getSchoolId]];
    }
}


- (IBAction)recruitClicked:(id)sender {
    stamps = 40;
    [Utilities alertStatusWithTitle:@"Confirm purchase" message:@"Recruit package: 40 stamps for $40/year" cancel:@"Cancel" otherTitles:@[@"Confirm"] tag:1 view:self];
    
}


- (IBAction)heroicClicked:(id)sender {
    stamps = 120;

    [Utilities alertStatusWithTitle:@"Confirm purchase" message:@"Heroic package: 120 stamps for $96/year" cancel:@"Cancel" otherTitles:@[@"Confirm"] tag:2 view:self];
}


- (IBAction)legendaryClicked:(id)sender {
    stamps = 500;
    [Utilities alertStatusWithTitle:@"Confirm purchase" message:@"Legendary package: 500 stamps for $350/year" cancel:@"Cancel" otherTitles:@[@"Confirm"] tag:3 view:self];
}


- (IBAction)orderClicked:(id)sender {
    NSString *stampString = self.stampsTextfield.text;
    NSString *errorMessage = [Utilities isNumeric:stampString];
    if([errorMessage isEqualToString:@""]){
        stamps = stampString.integerValue;
        if (stamps >= 10){
            [Utilities alertStatusWithTitle:@"Confirm purchase" message:[NSString stringWithFormat:@"Hero package: %ld stamps for $%.02f/year", (long)stampString.integerValue, price] cancel:@"Cancel" otherTitles:@[@"Confirm"] tag:4 view:self];
        }
    }
    else {
        [Utilities alertStatusWithTitle:@"Error placing order" message:errorMessage cancel:nil otherTitles:nil tag:0 view:self];
    }
}




- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    NSLog(@"In order stamps -> %@", data);
    orderId = [[data objectForKey:@"id"] integerValue];
    [hud hide:YES];
    // NOW APPLE PAY TIME 
    if (type == ORDER_HERO) {
        
    }
    else if (type == ORDER_RECRUIT){
        
    }
    else if (type == ORDER_HEROIC){
    
    }
    
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)hideKeyboard{
    [self.view endEditing:YES];
}


- (IBAction)backgroundTap:(id)sender{
    [self hideKeyboard];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


@end
