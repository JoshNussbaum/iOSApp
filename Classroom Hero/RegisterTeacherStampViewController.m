//
//  RegisterTeacherStampViewController.m
//  Classroom Hero
//
//  Created by Josh on 10/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "RegisterTeacherStampViewController.h"
#import "Utilities.h"
#import "MBProgressHUD.h"


@interface RegisterTeacherStampViewController (){
    user *currentUser;
    MBProgressHUD *hud;
}

@end

@implementation RegisterTeacherStampViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    
    self.appKey = snowshoe_app_key;
    self.appSecret = snowshoe_app_secret;
    
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

- (IBAction)unreigsterClicked:(id)sender {
}
@end
