//
//  AuthorizePaymentViewController.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 12/11/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//


// Give dictionaries of things to enter into State, Country, and City.


#import "AuthorizePaymentViewController.h"
#import "CheckoutInputTableViewCell.h"
#import "CreditCardTableViewCell.h"
#import "Utilities.h"
#import "CitiesAndStates.h"

@interface AuthorizePaymentViewController (){
    NSInteger packageType;
    float price;
    NSInteger stamps;
    NSArray *monthArray;
    NSArray *cardArray;
    
    NSArray *countryArray;
    NSArray *stateArray;
    NSArray *cityArray;
    
    NSInteger pickerFlag;
    
    NSNumber *selectedMonth;
    NSNumber *selectedYear;
    
    STPCard* stripeCard;
    STPCardParams *cardParams;
    STPCardBrand brand;
    
    UITextField *currentTextField;
    
    UITextField *nameTextField;
    UITextField *emailTextField;
    UITextField *address1TextField;
    UITextField *address2TextField;
    UITextField *cityTextField;
    UITextField *stateTextField;
    UITextField *countryTextField;
    UITextField *zipTextField;
    
    
    UITextField *cardNumberTextField;
    UITextField *expirationDateTextField;
    UITextField *CVCNumberTextField;
    UITextField *cardTypeTextField;
    
}

@end

@implementation AuthorizePaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pickerFlag = 1;
    self.packageTypeLabel.text = [Utilities getPackageDescriptionWithpackageId:packageType stamps:stamps];
    self.priceLabel.text = [NSString stringWithFormat:@"Total: $%.02f", price];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [Utilities makeRoundedButton:self.completeButton :nil];
    
    monthArray = @[@"01 - January", @"02 - February", @"03 - March",
                        @"04 - April", @"05 - May", @"06 - June", @"07 - July", @"08 - August", @"09 - September",
                        @"10 - October", @"11 - November", @"12 - December"];
    
    cardArray = @[@"Visa", @"MasterCard", @"Amex", @"Diners", @"JCB", @"Discover"];
    stateArray = [CitiesAndStates getAllStates];
    countryArray = @[@"USA", @"Russia"];
}


- (IBAction)completeClicked:(id)sender {
    stripeCard = [[STPCard alloc] init];
    
    cardParams.name = nameTextField.text;
    cardParams.number = cardNumberTextField.text;
    cardParams.cvc = CVCNumberTextField.text;
    cardParams.expMonth = [selectedMonth integerValue];
    cardParams.expYear = [selectedYear integerValue];
    cardParams.addressLine1 = address1TextField.text;
    cardParams.addressLine2 = address2TextField.text;
    cardParams.addressCity = cityTextField.text;
    cardParams.addressState = stateTextField.text;
    cardParams.addressCountry = countryTextField.text;
    
    brand = STPCardBrandUnknown;
    
    if ([self validateCustomerInfo]) {
        //[self performStripeOperation];
    }
}


- (BOOL)validateCustomerInfo {
    
    if (nameTextField.text.length == 0 ||
        emailTextField.text.length == 0) {
        [Utilities alertStatusWithTitle:@"Error validating information" message:@"Name and email are required" cancel:nil otherTitles:nil tag:0 view:self];
        return NO;
    }
    
    if (cardParams.addressCountry.length < 1 && cardParams.addressLine1.length < 1 && cardParams.addressCity.length < 1 && cardParams.addressState.length < 1 && cardParams.addressCountry.length < 1){
        [Utilities alertStatusWithTitle:@"Error validating information" message:@"Valid mailing address is required" cancel:nil otherTitles:nil tag:0 view:self];
    }
    
    
    if (brand == STPCardBrandUnknown){
        NSLog(@"No brand?");
        [Utilities alertStatusWithTitle:@"Error validating information" message:@"Please select a credit card brand and try again" cancel:nil otherTitles:nil tag:0 view:self];
        return NO;
    }
    STPCardValidationState cardState = [STPCardValidator validationStateForNumber:cardNumberTextField.text validatingCardBrand:brand];
    if (cardState == STPCardValidationStateIncomplete){
       [Utilities alertStatusWithTitle:@"Error validating information" message:@"Please enter a valid credit card number and brand and try again" cancel:nil otherTitles:nil tag:0 view:self];
        return NO;

    }
    else if (cardState == STPCardValidationStateInvalid){
        [Utilities alertStatusWithTitle:@"Error validating information" message:@"Please enter a valid credit card number and brand and try again" cancel:nil otherTitles:nil tag:0 view:self];
        return NO;

    }
    else if (cardState == STPCardValidationStateValid){
        NSLog(@"We good in the hood");
    }
    
    STPCardValidationState dateState = [STPCardValidator validationStateForExpirationYear:selectedYear.stringValue inMonth:selectedMonth.stringValue];

    if (dateState == STPCardValidationStateIncomplete){
        [Utilities alertStatusWithTitle:@"Error validating information" message:@"Please enter a valid date and try again" cancel:nil otherTitles:nil tag:0 view:self];
        return NO;

    }
    else if (dateState == STPCardValidationStateInvalid){
        [Utilities alertStatusWithTitle:@"Error validating information" message:@"Please enter a valid date and try again" cancel:nil otherTitles:nil tag:0 view:self];
        return NO;

    }
    else if (dateState == STPCardValidationStateValid){
        NSLog(@"We good in the hood 2");
    }
    
    STPCardValidationState cvcState = [STPCardValidator validationStateForCVC:cardParams.cvc cardBrand:brand];
    
    if (cvcState == STPCardValidationStateIncomplete){
        [Utilities alertStatusWithTitle:@"Error validating information" message:@"Please enter a valid CVC and brand and try again" cancel:nil otherTitles:nil tag:0 view:self];
        return NO;

    }
    else if (cvcState == STPCardValidationStateInvalid){
        [Utilities alertStatusWithTitle:@"Error validating information" message:@"Please enter a valid CVC and brand and try again" cancel:nil otherTitles:nil tag:0 view:self];
        return NO;

    }
    else if (cvcState == STPCardValidationStateValid){
        NSLog(@"We good in the hood 3");
    }
    
    return YES;
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



#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1){
        return 30.0f;
    }else return 0.01f;
}


- (CGFloat)tableView:(UITableView*)tableView
heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Customer Info" : @"Credit Card Details";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 8 : 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0 && row == 0) {
        CheckoutInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutInputCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"Name" placeholder:@"Required" protected:NO inputType:@"Text"];
        cell.inputTextField.tag = 0;
        nameTextField = cell.inputTextField;
        return cell;
        
    }
    else if (section == 0 && row == 1) {
        CheckoutInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutInputCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"Email" placeholder:@"Required" protected:NO inputType:@"Text"];
        emailTextField  = cell.inputTextField;
        cell.inputTextField.tag = 1;

        return cell;
    }
    
    
    else if (section == 0 && row == 2) {
        CheckoutInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutInputCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"Address line 1" placeholder:@"Required" protected:NO inputType:@"Text"];
        address1TextField  = cell.inputTextField;
        cell.inputTextField.tag = 2;
        
        return cell;
    }
    
    
    else if (section == 0 && row == 3) {
        CheckoutInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutInputCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"Address line 2" placeholder:@"Optional" protected:NO inputType:@"Text"];
        address2TextField  = cell.inputTextField;
        cell.inputTextField.tag = 3;
        
        return cell;
    }
    else if (section == 0 && row == 4) {
        CheckoutInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutInputCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"Country" placeholder:@"Required" protected:NO inputType:@"Text"];
        countryTextField  = cell.inputTextField;
        cell.inputTextField.tag = 4;
        
        return cell;
    }
    else if (section == 0 && row == 5) {
        CheckoutInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutInputCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"State" placeholder:@"Required" protected:NO inputType:@"Text"];
        stateTextField  = cell.inputTextField;
        cell.inputTextField.tag = 5;
        
        return cell;
    }
    else if (section == 0 && row == 6) {
        CheckoutInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutInputCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"City" placeholder:@"Required" protected:NO inputType:@"Text"];
        cityTextField  = cell.inputTextField;
        cell.inputTextField.tag = 6;
        
        return cell;
    }
    else if (section == 0 && row == 7) {
        CheckoutInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutInputCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"ZIP Code" placeholder:@"Required" protected:NO inputType:@"Text"];
        zipTextField  = cell.inputTextField;
        cell.inputTextField.tag = 7;
        
        return cell;
    }
    
    else if (section == 1 && row == 0) {
        CreditCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardInfoCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"Credit card number" placeholder:@"Required" protected:YES];
        cell.inputTextField.tag = 8;
        cardNumberTextField = cell.inputTextField;
        return cell;
    }
    else if (section == 1 && row == 1) {
        CreditCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardInfoCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"Expiration date" placeholder:@"Required" protected:NO];
        cell.inputTextField.allowsEditingTextAttributes = NO;
        cell.inputTextField.tag = 9;
        expirationDateTextField = cell.inputTextField;
        [self pickerView:self.expirationDatePicker didSelectRow:0 inComponent:0];
        return cell;
    }
    else if (section == 1 && row == 2) {
        CreditCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardInfoCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"CVC number" placeholder:@"Required" protected:NO];
        cell.inputTextField.tag = 10;
        cell.inputTextField.returnKeyType = UIReturnKeyDone;
        CVCNumberTextField = cell.inputTextField;
        return cell;
    }
    else if (section == 1 && row == 3) {
        CreditCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardInfoCell" forIndexPath:indexPath];
        [cell initializeCellWithname:@"Card type" placeholder:@"Required" protected:NO];
        cell.inputTextField.allowsEditingTextAttributes = NO;
        cell.inputTextField.tag = 11;
        cell.inputTextField.returnKeyType = UIReturnKeyDone;
        cardTypeTextField = cell.inputTextField;
        return cell;
    }

    else if (section == 1 && row == 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"creditCardsCell" forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}



#pragma mark - UIPicker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerFlag == 1) return 2;
    else if (pickerFlag == 2) return 1;
    else return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerFlag == 1){
        return (component == 0) ? 12 : 10;
    }
    else if (pickerFlag == 2){
        return cardArray.count;
    }
    return 0;
}

#pragma mark - UIPicker delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerFlag == 1){
        if (component == 0) {
            //Expiration month
            return monthArray[row];
        }
        else {
            //Expiration year
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy"];
            NSInteger currentYear = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
            return [NSString stringWithFormat:@"%li", currentYear + row];
        }
    }
    else if (pickerFlag == 2){
        return cardArray[row];
    }

    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerFlag == 1){
        if (component == 0) {
            selectedMonth = @(row + 1);
        }
        else {
            NSString *yearString = [self pickerView:self.expirationDatePicker titleForRow:row forComponent:1];
            selectedYear = @([yearString integerValue]);
        }
        
        
        if (!selectedMonth) {
            [self.expirationDatePicker selectRow:0 inComponent:0 animated:YES];
            selectedMonth = @(1); //Default to January if no selection
        }
        
        if (!selectedYear) {
            [self.expirationDatePicker selectRow:0 inComponent:1 animated:YES];
            NSString *yearString = [self pickerView:self.expirationDatePicker titleForRow:0 forComponent:1];
            selectedYear = @([yearString integerValue]); //Default to current year if no selection
        }
        expirationDateTextField.text = [NSString stringWithFormat:@"%@/%@", selectedMonth, selectedYear];
        expirationDateTextField.textColor = [UIColor blackColor];
    }
    else if (pickerFlag == 2){
        NSString *cardType = [cardArray objectAtIndex:row];
        cardTypeTextField.text = cardType;
        brand = [self getCardBrand:row];
    }

    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == expirationDateTextField){
        pickerFlag = 1;
        [self.expirationDatePicker reloadAllComponents];
        return NO;
    }
    else if (textField == cardTypeTextField){
        pickerFlag = 2;
        [self.expirationDatePicker reloadAllComponents];
        return NO;
    }
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 10) {
        [self.view endEditing:YES];
        return YES;
    }

    else if (textField.tag == 8) {
        [(UITextField*)[self.view viewWithTag:10] becomeFirstResponder];
        
    }
    else if (textField.tag == 7) {
        [(UITextField*)[self.view viewWithTag:8] becomeFirstResponder];
        
    }
    else if (textField.tag == 6) {
        [(UITextField*)[self.view viewWithTag:7] becomeFirstResponder];
        
    }
    else if (textField.tag == 5) {
        [(UITextField*)[self.view viewWithTag:6] becomeFirstResponder];
        
    }
    else if (textField.tag == 4) {
        [(UITextField*)[self.view viewWithTag:5] becomeFirstResponder];
        
    }
    else if (textField.tag == 3) {
        [(UITextField*)[self.view viewWithTag:4] becomeFirstResponder];
        
    }
    else if (textField.tag == 2) {
        [(UITextField*)[self.view viewWithTag:3] becomeFirstResponder];
        
    }
    else if (textField.tag == 1) {
        [(UITextField*)[self.view viewWithTag:2] becomeFirstResponder];
        
    }
    else if (textField.tag == 0) {
        [(UITextField*)[self.view viewWithTag:1] becomeFirstResponder];
        
    }
    return YES;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)setPurchaseInfoWithpackageType:(NSInteger)packageType_ cost:(float)cost_ stamps:(NSInteger)stamps_{
    packageType = packageType_;
    price = cost_;
    stamps = stamps_;
}

//cardArray = @[@"Visa", @"MasterCard", @"Amex", @"Diners Club", @"JCB", @"Discover"];
- (STPCardBrand)getCardBrand:(NSInteger)index{
    if (index == 0){
        return STPCardBrandVisa;
    }
    else if (index == 1){
        return STPCardBrandMasterCard;
    }
    else if (index == 2){
        return STPCardBrandAmex;
    }
    else if (index == 3){
        return STPCardBrandDinersClub;
    }
    else if (index == 4){
        return STPCardBrandJCB;
    }
    else if (index == 5){
        return STPCardBrandDiscover;
    }
    else return STPCardBrandUnknown;
}


@end
