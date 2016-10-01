//
//  StudentAwardTableViewCell.h
//  
//
//  Created by Josh Nussbaum on 9/30/16.
//
//

#import <UIKit/UIKit.h>
#import "student.h"

@interface StudentAwardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *studentNameLabel;

- (void)initializeWithStudent:(student *)student selected:(BOOL)selected;


@end
