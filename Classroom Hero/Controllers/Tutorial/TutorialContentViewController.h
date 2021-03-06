//
//  TutorialContentViewController.h
//  Classroom Hero
//
//  Created by Josh on 7/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@protocol TutorialView <NSObject>

- (void)setTmpClass:(Class *)tmpClass;

@end

@interface TutorialContentViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate,  ConnectionHandlerDelegate>

@property NSMutableArray *schoolData;
@property NSMutableArray *classData;
@property NSUInteger pageIndex;
@property NSString *titleText;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField1;
@property (strong, nonatomic) IBOutlet UITextField *textField2;
@property (strong, nonatomic) IBOutlet UIPickerView *schoolPicker;
@property (strong, nonatomic) IBOutlet UIButton *button;

@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stampImage;	
@property (strong, nonatomic) IBOutlet UILabel *pickerLabel;

- (IBAction)infoButtonClicked:(id)sender;

- (IBAction)buttonClicked:(id)sender;

- (IBAction)backgroundTap:(id)sender;

- (void)setTmpClass:(class *)tmpClass_;

@end
