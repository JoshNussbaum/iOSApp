//
//  ClassTableViewCell.h
//  Classroom Hero
//
//  Created by Josh on 8/19/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "user.h"
#import "class.h"

@interface ClassTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfStudentsLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalPointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *classProgressLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UILabel *schoolName;
@property (strong, nonatomic) IBOutlet UILabel *gradeLabel;

- (void)initializeCellWithClass:(class*)class_ :(NSInteger)classCount :(NSString *)schoolName;

@end
