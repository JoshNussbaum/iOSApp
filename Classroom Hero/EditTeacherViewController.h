//
//  EditTeacherViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTeacherViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *editNameButton;
@property (strong, nonatomic) IBOutlet UIButton *editPasswordButton;

- (IBAction)backClicked:(id)sender;

@end
