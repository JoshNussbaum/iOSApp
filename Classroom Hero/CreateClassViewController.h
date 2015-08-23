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

@interface CreateClassViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *schoolPicker;
- (IBAction)addClassClicked:(id)sender;
@property (strong, nonatomic) IBOutlet nameTextField *classNameTextField;
@property (strong, nonatomic) IBOutlet numberTextField *classGradeTextField;
- (IBAction)backgroundTap:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

@end
