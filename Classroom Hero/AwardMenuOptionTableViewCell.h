//
//  AwardMenuOptionTableViewCell.h
//  Classroom Hero
//
//  Created by Josh Nussbaum on 11/21/16.
//  Copyright © 2016 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AwardMenuOptionTableViewCell : UITableViewCell

- (void)initializeWithTitle:(NSString *)title;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;


@end
