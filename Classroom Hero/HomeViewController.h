//
//  HomeViewController.h
//  Classroom Hero
//
//  Created by Josh Nussbaum on 1/30/17.
//  Copyright © 2017 Josh Nussbaum. All rights reserved.
//

#import "LGSideMenuController.h"
#import <UIKit/UIKit.h>
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "ConnectionHandler.h"
#import "YLProgressBar.h"


@interface HomeViewController : LGSideMenuController <ConnectionHandlerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *levelView;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *levelBar;
@property (strong, nonatomic) IBOutlet UILabel *levelUpLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sackImage;
@property (strong, nonatomic) IBOutlet UIImageView *stampImage;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryNameLabel;

@property (strong, nonatomic) IBOutlet UIImageView *aOne;
@property (strong, nonatomic) IBOutlet UIImageView *aTwo;
@property (strong, nonatomic) IBOutlet UIImageView *aThree;
@property (strong, nonatomic) IBOutlet UIImageView *bOne;
@property (strong, nonatomic) IBOutlet UIImageView *bTwo;
@property (strong, nonatomic) IBOutlet UIImageView *cOne;
@property (strong, nonatomic) IBOutlet UIImageView *coinImage;
@property (strong, nonatomic) IBOutlet UILabel *coinPointsLabel;
@property (strong, nonatomic) IBOutlet UIButton *chestButton;

@property (strong, nonatomic) IBOutlet UIButton *openStudentTableViewButton;
@property (strong, nonatomic) YLProgressBar *progressView;

@property (strong, nonatomic) IBOutlet UICollectionView *studentCollectionView;

@property (strong, nonatomic) IBOutlet UIView *categoryView;
@property (strong, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (strong, nonatomic) IBOutlet UILabel *categoryStudentsNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *categoryPointsTextField;
@property (strong, nonatomic) IBOutlet UITextField *commentsTextField;
@property (strong, nonatomic) IBOutlet UIButton *categoryBackButton;
@property (strong, nonatomic) IBOutlet UIButton *categoryAddButton;
@property (strong, nonatomic) IBOutlet UIButton *categoryEditCategoryButton;
@property (strong, nonatomic) IBOutlet UIButton *categoryGenerateChestButton;
@property (strong, nonatomic) IBOutlet UIButton *categoryAddPointsButton;


- (IBAction)categoryAddPointsClicked:(id)sender;
- (IBAction)categoryBackClicked:(id)sender;
- (IBAction)categoryAddCategoryClicked:(id)sender;
- (IBAction)categoryEditCategoryClicked:(id)sender;
- (IBAction)categoryGenerateChestClicked:(id)sender;

- (IBAction)chestClicked:(id)sender;

- (IBAction)backClicked:(id)sender;

- (IBAction)backgroundTap:(id)sender;

@end
