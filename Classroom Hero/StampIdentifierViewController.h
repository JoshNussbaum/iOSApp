//
//  StampIdentifierViewController.h
//  Classroom Hero
//
//  Created by Josh on 10/19/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnowShoeViewController.h"
#import "ConnectionHandler.h"

@interface StampIdentifierViewController : SnowShoeViewController <ConnectionHandlerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *stampImage;
@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *stampSerialLabel;
@property (strong, nonatomic) IBOutlet UIButton *unregisterStampButton;

- (IBAction)unregisterStampClicked:(id)sender;
- (IBAction)backClicked:(id)sender;

@end
