//
//  user.h
//  Classroom Hero
//
//  Created by Josh on 7/25/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "class.h"

@interface user : NSObject

@property(nonatomic)NSInteger id;
@property(nonatomic)NSString *firstName;
@property(nonatomic)NSString *lastName;
@property(nonatomic)NSString *email;
@property(nonatomic)NSString *password;
@property(nonatomic)NSInteger accountStatus;
@property(nonatomic)NSString *serial;
@property(nonatomic)class *currentClass;


+(user *)getInstance;

-(void)reset;

-(void)printUser;


@end
