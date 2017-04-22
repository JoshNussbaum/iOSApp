//
//  StudentTableViewCell.h
//  Classroom Hero
//
//  Created by Josh on 9/23/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "student.h"
#import "ConnectionHandler.h"

@interface StudentTableViewCell : UITableViewCell <ConnectionHandlerDelegate>{
    student *currentStudent;
}

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *levelLabel;

@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

@property (strong, nonatomic) IBOutlet UIButton *minusOneButton;

@property (strong, nonatomic) IBOutlet UIButton *plusOneButton;


- (void)initializeWithStudent:(student *)currentStudent_;


- (IBAction)plusOneClicked:(id)sender;

- (IBAction)minusOneClicked:(id)sender;

@end
