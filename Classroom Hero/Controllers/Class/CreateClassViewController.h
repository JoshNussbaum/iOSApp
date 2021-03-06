//
//  CreateClassViewController.h
//  Classroom Hero
//
//  Created by Josh on 8/22/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nameTextField.h"
#import "numberTextField.h"
#import "ConnectionHandler.h"

@interface CreateClassViewController : UIViewController <ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet nameTextField *classNameTextField;

@property (strong, nonatomic) IBOutlet numberTextField *classGradeTextField;

@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) IBOutlet UIButton *addClassButton;


- (IBAction)backgroundTap:(id)sender;

- (IBAction)addClassClicked:(id)sender;

- (IBAction)helpClicked:(id)sender;


@end
