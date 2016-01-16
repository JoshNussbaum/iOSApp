//
//  EditTeacherViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"
#import "nameTextField.h"
#import "passwordTextField.h"

@interface EditTeacherViewController : UIViewController <ConnectionHandlerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *editNameButton;
@property (strong, nonatomic) IBOutlet UIButton *editPasswordButton;
@property (strong, nonatomic) IBOutlet UIButton *resetPasswordButton;
@property (strong, nonatomic) IBOutlet nameTextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet nameTextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet passwordTextField *currentPasswordTextField;
@property (strong, nonatomic) IBOutlet passwordTextField *editPasswordTextField;
@property (strong, nonatomic) IBOutlet passwordTextField *confirmNewPasswordTextField;

- (IBAction)editNameClicked:(id)sender;
- (IBAction)editPasswordClicked:(id)sender;
- (IBAction)backClicked:(id)sender;
- (IBAction)resetPasswordClicked:(id)sender;

@end
