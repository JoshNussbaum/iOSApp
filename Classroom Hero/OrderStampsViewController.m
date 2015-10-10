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
#import "Stripe.h"


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
        if (stamps < 10 && ![input isEqualToString:@""]){
            price = stamps;
            self.costLabel.text = @"Must  order  at  least  10  stamps";
            return;
        }
        
        self.costLabel.text = [NSString stringWithFormat:@"$%.02f/year", [self getPrice]];
    }
    else {
        self.costLabel.text = errorMessage;
    }
}


-(NSInteger)getPrice{
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
    return price;
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
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
    if ([self canMakePayments]){
        
    }
    NSString *stampString = self.stampsTextfield.text;
    NSString *errorMessage = [Utilities isNumeric:stampString];
    if(!errorMessage){
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
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];

    if ([successNumber boolValue] == YES){
        NSString *packageName;
        if (type == ORDER_HERO) {
            packageName = [NSString stringWithFormat:@"Hero package with %ld stamps", (long)stamps];
        }
        else if (type == ORDER_RECRUIT){
            packageName = @"Recruit package";
        }
        else if (type == ORDER_HEROIC){
            packageName = @"Heroic package";
        }
        else if (type == ORDER_LEGENDARY){
            packageName = @"Legendary package";
        }
        PKPaymentRequest *request = [Stripe
                                     paymentRequestWithMerchantIdentifier:merchant_id];
        // Configure your request here.
        NSString *label = packageName;
        NSString *costAmount = [NSString stringWithFormat:@"%li", (long)price];
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:costAmount];
        request.paymentSummaryItems = @[
                                        [PKPaymentSummaryItem summaryItemWithLabel:label
                                                                            amount:amount]
                                        ];
        
        if ([Stripe canSubmitPaymentRequest:request]) {
            NSLog(@"In here can submit");
            PKPaymentAuthorizationViewController *paymentController;
            
            paymentController = [[PKPaymentAuthorizationViewController alloc]
                                 initWithPaymentRequest:request];
            paymentController.delegate = self;
            
            [self presentViewController:paymentController animated:YES completion:nil];
        } else {
            NSLog(@"NAh you can't homei");
            // Show the user your own credit card form (see options 2 or 3)
        }

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


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


- (bool)canMakePayments{
    if ([PKPaymentAuthorizationViewController canMakePayments]) {
        NSLog(@"Can Make Payments");
    }
    else {
        NSLog(@"Can't Make payments");
        return NO;
    }
    NSArray *paymentNetworks = [NSArray arrayWithObjects:PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkAmex, nil];
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:paymentNetworks]) {
        return YES;
    }
    else {
        if ([PKPassLibrary isPassLibraryAvailable]){
            [Utilities alertStatusWithTitle:@"Set up your apple pay account" message:nil cancel:nil otherTitles:nil tag:0 view:self];
            return NO;
        }
    }
    return NO;
}



@end
