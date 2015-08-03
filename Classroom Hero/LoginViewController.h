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

- (IBAction)backgroundTap:(id)sender;

- (IBAction)loginClicked:(id)sender;

- (IBAction)createAccountClicked:(id)sender;

@end
