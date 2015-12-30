//
//  AuthorizePaymentViewController.h
//  Classroom Hero
//
//  Created by Josh Nussbaum on 12/11/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthorizePaymentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *paymentTableView;

@property (weak, nonatomic) IBOutlet UILabel *packageTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *completeButton;

@property (weak, nonatomic) IBOutlet UIPickerView *expirationDatePicker;

- (IBAction)completeClicked:(id)sender;

- (IBAction)backClicked:(id)sender;

- (IBAction)backgroundTap:(id)sender;

- (void)setPurchaseInfoWithpackageType:(NSInteger)packageType_ cost:(float)cost_ stamps:(NSInteger)stamps_;


@end
