//
//  HeaderCollectionViewCell.h
//  Classroom Hero
//
//  Created by Josh Nussbaum on 1/29/17.
//  Copyright © 2017 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIButton *attendanceButton;
@property (strong, nonatomic) IBOutlet UIButton *marketButton;
@property (strong, nonatomic) IBOutlet UIButton *jarButton;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIButton *subtractButton;

@end
