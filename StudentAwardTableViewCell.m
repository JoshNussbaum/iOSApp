//
//  StudentAwardTableViewCell.m
//  
//
//  Created by Josh Nussbaum on 9/30/16.
//
//

#import "StudentAwardTableViewCell.h"
#import "Utilities.h"

@implementation StudentAwardTableViewCell

- (void)initializeWithStudent:(student *)student selected:(BOOL)selected{
    self.studentNameLabel.text = [NSString stringWithFormat:@"%@ %@", [student getFirstName], [student getLastName]];
    if (selected){
        self.backgroundColor = [Utilities CHBlueColor];
    }else self.backgroundColor = [UIColor clearColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
