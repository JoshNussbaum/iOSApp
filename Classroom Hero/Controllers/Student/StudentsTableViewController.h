//
//  StudentsTableViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/23/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@interface StudentsTableViewController : UITableViewController <ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;

- (IBAction)backClicked:(id)sender;

- (IBAction)addStudentClicked:(id)sender;

- (IBAction)editButtonClicked:(id)sender;

@end
