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

//- (void)layoutSubviews{
//    [super layoutSubviews];
//    [self.contentView layoutSubviews];
//
//}
//
//- (void)didMoveToSuperview{
//    [super didMoveToSuperview];
//    [super layoutSubviews];
//    [self.contentView layoutSubviews];
//
//}

- (void)initializeWithStudent:(student *)student selected:(BOOL)selected{
    self.studentNameLabel.text = [NSString stringWithFormat:@"%@ %@", [student getFirstName], [student getLastName]];
    if (selected){
        self.backgroundColor = [Utilities CHGreenColor];
    }else self.backgroundColor = [UIColor whiteColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
