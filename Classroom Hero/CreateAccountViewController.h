//
//  CreateAccountViewController.h
//  Classroom Hero
//
//  Created by Josh on 7/25/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"
#import "DatabaseHandler.h"
#import "emailTextField.h"
#import "passwordTextField.h"
#import "nameTextField.h"
#import "user.h"

@interface CreateAccountViewController : UIViewController <ConnectionHandlerDelegate>
@property (strong, nonatomic) IBOutlet nameTextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet nameTextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet emailTextField *emailTextField;
@property (strong, nonatomic) IBOutlet passwordTextField *passwordTextField;
@property (strong, nonatomic) IBOutlet passwordTextField *confirmPasswordTextField;


- (IBAction)createAccountClicked:(id)sender;
- (IBAction)backClicked:(id)sender;

- (IBAction)backgroundTap:(id)sender;
@end
