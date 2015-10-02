//
//  EditTeacherViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/28/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "EditTeacherViewController.h"
#import "Utilities.h"

@interface EditTeacherViewController ()

@end

@implementation EditTeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utilities makeRoundedButton:self.editNameButton :[UIColor whiteColor]];
    [Utilities makeRoundedButton:self.editPasswordButton :[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backgroundTap:(id)sender {
}
@end
