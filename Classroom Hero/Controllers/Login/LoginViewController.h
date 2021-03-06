//
//  LoginViewController.h
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"
#import "DatabaseHandler.h"
#import "emailTextField.h"
#import "passwordTextField.h"
#import "user.h"

@interface LoginViewController : UIViewController <ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *stampImage;

@property (strong, nonatomic) IBOutlet emailTextField *emailTextField;

@property (strong, nonatomic) IBOutlet passwordTextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@property (strong, nonatomic) IBOutlet UIButton *aboutButton;

@property (strong, nonatomic) IBOutlet UIButton *pricingButton;

@property (weak, nonatomic) IBOutlet UIButton *logInButton;

@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *headerLabel;

- (IBAction)backgroundTap:(id)sender;

- (IBAction)loginClicked:(id)sender;

- (IBAction)createAccountClicked:(id)sender;

- (IBAction)aboutClicked:(id)sender;

- (IBAction)pricingClicked:(id)sender;

- (IBAction)forgotPasswordClicked:(id)sender;

@end
