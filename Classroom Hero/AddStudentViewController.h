//
//  AddStudentViewController.h
//  Classroom Hero
//
//  Created by Josh Nussbaum on 2/7/17.
//  Copyright © 2017 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nameTextField.h"
#import "ConnectionHandler.h"

@interface AddStudentViewController : UIViewController <ConnectionHandlerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) IBOutlet UITableView *studentsTableView;

@property (strong, nonatomic) IBOutlet nameTextField *studentNameTextField;

@property (strong, nonatomic) IBOutlet UIButton *continueButton;


- (IBAction)backgroundTap:(id)sender;

- (IBAction)backClicked:(id)sender;

- (IBAction)continueClicked:(id)sender;

- (IBAction)addStudentClicked:(id)sender;


- (void)setFlag:(NSInteger)flag_;

@end
