//
//  ClassTableViewController.h
//  Classroom Hero
//
//  Created by Josh on 8/19/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"



@interface ClassTableViewController : UITableViewController <ConnectionHandlerDelegate>

- (IBAction)editClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
- (IBAction)addClassClicked:(id)sender;

@end
