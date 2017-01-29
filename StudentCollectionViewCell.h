//
//  StudentCollectionViewCell.h
//  
//
//  Created by Josh Nussbaum on 1/27/17.
//
//

#import <UIKit/UIKit.h>
#import "student.h"

@interface StudentCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@end


