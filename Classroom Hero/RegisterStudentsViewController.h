//
//  RegisterStudentsViewController.h
//  Classroom Hero
//
//  Created by Josh on 8/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnowShoeViewController.h"

@interface RegisterStudentsViewController : SnowShoeViewController

@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *stampToRegisterLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stampImage;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)skipButtonClicked:(id)sender;

- (void)setFlag:(NSInteger)flag_;

@end
