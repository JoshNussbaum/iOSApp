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
#import "User.h"


@interface OrderStampsViewController (){
    NSInteger stamps;
    user *currentUser;
    float price;
    NSInteger orderId;
    MBProgressHUD *hud;
    NSInteger packageId;
}

@end

@implementation OrderStampsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *buttons = @[self.recruitButton, self.heroicButton, self.legendaryButton, self.placeOrderButton];
    currentUser = [user getInstance];
    for (UIButton *button in buttons){
        [Utilities makeRoundedButton:button :[UIColor whiteColor]];
    }
    [self.stampsTextfield addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    else{
        //[self activityStart:@"Placing order..."];
        
        PKPaymentRequest *request = [Stripe
                                     paymentRequestWithMerchantIdentifier:merchant_id];
        // Configure your request here.
        NSString *description;
        switch (packageId) {
            case 0:
                description = [NSString stringWithFormat:@"Hero package with %ld stamps", (long)stamps];
                break;
            case 1:
                description = [NSString stringWithFormat:@"Recruit package with 40 stamps"];
                break;
            case 2:
                description = [NSString stringWithFormat:@"Epic package with 120 stamps"];
                break;
            case 3:
                description = [NSString stringWithFormat:@"Legendary package with 500 stamps"];
                break;
            default:
                break;
        }
        NSString *amountString = [NSString stringWithFormat:@"%f", price];
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:amountString];
        request.paymentSummaryItems = @[
                                        [PKPaymentSummaryItem summaryItemWithLabel:description
                                                                            amount:amount]
                                        ];
        
        if ([Stripe canSubmitPaymentRequest:request]) {
            PKPaymentAuthorizationViewController *paymentController;
            paymentController = [[PKPaymentAuthorizationViewController alloc]
                                 initWithPaymentRequest:request];
            paymentController.delegate = self;
            [self presentViewController:paymentController animated:YES completion:nil];
            //
        } else {
            // Show the user your own credit card form (see options 2 or 3)
            NSLog(@"Er nah");
        }
        
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}


- (IBAction)recruitClicked:(id)sender {
    stamps = 40;
    packageId = 1;
    price = 40;
    [Utilities alertStatusWithTitle:@"Confirm purchase" message:@"Recruit package: 40 stamps for $40/year" cancel:@"Cancel" otherTitles:@[@"Confirm"] tag:1 view:self];
    
}


- (IBAction)heroicClicked:(id)sender {
    stamps = 120;
    packageId = 2;
    price = 96;
    [Utilities alertStatusWithTitle:@"Confirm purchase" message:@"Heroic package: 120 stamps for $96/year" cancel:@"Cancel" otherTitles:@[@"Confirm"] tag:2 view:self];
}


- (IBAction)legendaryClicked:(id)sender {
    stamps = 500;
    packageId = 3;
    price = 350;
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
            [Utilities alertStatusWithTitle:@"Confirm purchase" message:[NSString stringWithFormat:@"Basic package: %ld stamps for $%.02f/year", (long)stampString.integerValue, price] cancel:@"Cancel" otherTitles:@[@"Confirm"] tag:4 view:self];
        }
    }
    else {
        [Utilities alertStatusWithTitle:@"Error placing order" message:errorMessage cancel:nil otherTitles:nil tag:0 view:self];
    }
}


- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)backgroundTap:(id)sender{
    [self hideKeyboard];
}


- (void)textFieldDidChange:(UITextField *)textfield{
    NSString *input = textfield.text;
    if ([input isEqualToString:@""]){
        self.costLabel.text = @"";
        return;
    }
    NSString *errorMessage = [Utilities isNumeric:input];
    if (!errorMessage){
        stamps = input.integerValue;
        if (stamps < 10 && ![input isEqualToString:@""]){
            price = stamps;
            self.costLabel.text = @"Must  order  at  least  10  stamps";
            return;
        }
        
        self.costLabel.text = [NSString stringWithFormat:@"$%.2ld/year", (long)[self getPrice]];
    }
    else {
        self.costLabel.text = errorMessage;
    }
}


- (NSInteger)getPrice{
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


- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 if (error) {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     return;
                                                 }
                                                 /*
                                                  We'll implement this below in "Sending the token to your server".
                                                  Notice that we're passing the completion block through.
                                                  See the above comment in didAuthorizePayment to learn why.
                                                  */
                                                 NSLog(@"IN hurrr");
                                                 

                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
}


- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSLog(@"IN here bout to order stamps");
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    NSString *jsonRequest = [[NSString alloc] initWithFormat:@"{\"order\":{\"uid\":%ld, \"package\":%ld, \"numStamps\":%ld, \"schoolId\":%ld, \"source\":\"%@\", \"amount\":%ld, \"currency\":\"%@\", \"email\":\"%@\" }}", (long)currentUser.id, (long)packageId, (long)stamps, (long)[currentUser.currentClass getSchoolId], token, (long)price, @"USD", currentUser.email];
    NSURL *url = [NSURL URLWithString:@"http://73.231.27.167:8080/SynappWebServiceDemo/services/register/order"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   completion(PKPaymentAuthorizationStatusFailure);
                               } else {
                                   completion(PKPaymentAuthorizationStatusSuccess);
                                   [Utilities alertStatusWithTitle:@"Order successfully placed" message:@"Check your email for confirmation details" cancel:nil otherTitles:nil tag:0 view:self];
                               }
                           }];

    
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


- (void)hideKeyboard{
    [self.view endEditing:YES];
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.layer.zPosition = 200.0;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}



@end
