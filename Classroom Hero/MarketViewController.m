//
//  MarketViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/3/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "MarketViewController.h"

@interface MarketViewController ()

@end

@implementation MarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)homeClicked:(id)sender {
    [self performSegueWithIdentifier:@"market_to_home" sender:nil];
}

- (IBAction)awardClicked:(id)sender {
    [self performSegueWithIdentifier:@"market_to_award" sender:nil];
}

- (IBAction)classJarClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
