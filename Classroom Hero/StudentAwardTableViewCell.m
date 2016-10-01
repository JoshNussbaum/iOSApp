//
//  StudentAwardTableViewCell.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 9/30/16.
//  Copyright © 2016 Josh Nussbaum. All rights reserved.
//

#import "StudentAwardTableViewCell.h"

@implementation StudentAwardTableViewCell

- (void)initializeWithStudent:(student *)student selected:(bool)selected{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [student getFirstName], [student getLastName]];
    if (selected){
        self.backgroundColor = [Utilities CHBlueColor];
    }else self.backgroundColor = [UIColor clearColor];
}

@end
