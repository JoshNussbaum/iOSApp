//
//  RegisterTeacherStampViewController.h
//  Classroom Hero
//
//  Created by Josh on 10/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"
#import "SnowShoeViewController.h"

@interface RegisterTeacherStampViewController : SnowShoeViewController <ConnectionHandlerDelegate>



@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stampAgainLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stampImage;
@property (strong, nonatomic) IBOutlet UIButton *unregisterStampButton;
- (IBAction)unreigsterClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
@end
