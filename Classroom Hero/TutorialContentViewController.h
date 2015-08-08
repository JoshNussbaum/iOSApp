//
//  TutorialContentViewController.h
//  Classroom Hero
//
//  Created by Josh on 7/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SnowShoeViewController.h"
#import "ConnectionHandler.h"

@interface TutorialContentViewController : SnowShoeViewController <UIPickerViewDataSource, UIPickerViewDelegate,  ConnectionHandlerDelegate>{
    
    SystemSoundID success;

}

@property NSMutableArray *schoolData;
@property NSUInteger pageIndex;
@property NSString *titleText;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField1;
@property (strong, nonatomic) IBOutlet UITextField *textField2;
@property (strong, nonatomic) IBOutlet UIPickerView *schoolPicker;
@property (strong, nonatomic) IBOutlet UIButton *button;

- (IBAction)buttonClicked:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *chestImage;

@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;

-(void)setSchools;

@end
