//
//  AboutViewController.m
//  Classroom Hero
//
//  Created by Josh on 8/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "AboutViewController.h"
#import "Utilities.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[Utilities CHBlueColor]];

    // Do any additional setup after loading the view.
    [Utilities makeRoundedButton:self.backButton :nil];
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

@end
