//
//  OrderStampsViewController.h
//  Classroom Hero
//
//  Created by Josh on 9/27/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@interface OrderStampsViewController : UIViewController <ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *recruitButton;
@property (strong, nonatomic) IBOutlet UIButton *heroicButton;
@property (strong, nonatomic) IBOutlet UIButton *legendaryButton;

- (IBAction)recruitClicked:(id)sender;
- (IBAction)heroicClicked:(id)sender;
- (IBAction)legendaryClicked:(id)sender;
- (IBAction)orderClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *placeOrderButton;
@property (strong, nonatomic) IBOutlet UITextField *stampsTextfield;
@property (strong, nonatomic) IBOutlet UILabel *costLabel;

- (IBAction)backClicked:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
