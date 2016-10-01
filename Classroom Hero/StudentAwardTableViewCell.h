//
//  StudentAwardTableViewCell.h
//  Classroom Hero
//
//  Created by Josh Nussbaum on 9/30/16.
//  Copyright © 2016 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "student.h"

@interface StudentAwardTableViewCell : NSObject

- (void)initializeWithStudent:(student *)student selected:(BOOL)selected_;

@end
