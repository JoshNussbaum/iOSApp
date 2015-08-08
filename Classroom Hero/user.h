//
//  user.h
//  Classroom Hero
//
//  Created by Josh on 7/25/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const snowshoe_app_key = @"d12276c2fac976865fdc";
static NSString * const snowshoe_app_secret = @"bf700a42149799b02641b2c2d93dbd3c4f995db8";

@interface user : NSObject{
    NSInteger id;
    NSString *firstName;
    NSString *lastName;
    NSString *email;
    NSString *password;
    NSString *serial;
    NSMutableArray *classIds;
    NSInteger currentClassId;
    NSString *currentClassName;
}

@property(nonatomic)NSInteger id;
@property(nonatomic)NSString *firstName;
@property(nonatomic)NSString *lastName;
@property(nonatomic)NSString *email;
@property(nonatomic)NSString *password;
@property(nonatomic)NSString *serial;
@property(nonatomic)NSMutableArray *classIds;
@property(nonatomic)NSInteger currentClassId;
@property(nonatomic)NSString *currentClassName;


+(user *)getInstance;

-(void)reset;


@end
