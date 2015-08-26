//
//  HomeViewController.m
//  Classroom Hero
//
//  Created by Josh on 8/22/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "HomeViewController.h"
#import "user.h"
#import "DatabaseHandler.h"


@interface HomeViewController (){
    user *currentUser;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    // Do any additional setup after loading the view.
}

@end
