//
//  CreditCardTableViewCell.h
//  Classroom Hero
//
//  Created by Josh Nussbaum on 12/12/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stripe.h"

@interface CreditCardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

- (void)initializeCellWithname:(NSString*)name placeholder:(NSString *)placeHolder protected:(BOOL)protected;

@end
