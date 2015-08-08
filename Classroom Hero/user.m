//
//  user.m
//  Classroom Hero
//
//  Created by Josh on 7/25/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "user.h"

@implementation user

@synthesize id;
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize password;
@synthesize serial;
@synthesize classIds;
@synthesize currentClassId;
@synthesize currentClassName;

static user *instance = nil;

+(user *)getInstance{
    @synchronized(self){
        if(instance==nil){
            instance = [user new];
            instance->id = 0;
            instance->firstName=@"";
            instance->lastName=@"";
            instance->email=@"";
            instance->password=@"";
            instance->serial=@"";
            instance->classIds = [NSMutableArray array];
            instance->currentClassId = 0;
            instance->currentClassName=@"";
        }
    }
    return instance;
}

-(void)reset{
    self->firstName = @"";
    self->lastName = @"";
    self->email = @"";
    self->password = @"";
    self->serial = @"";
    self->currentClassId = 0;
    self->currentClassName = @"";
}



@end
