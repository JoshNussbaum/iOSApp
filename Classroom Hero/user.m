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
@synthesize accountStatus;
@synthesize serial;
@synthesize currentClass;
@synthesize studentIds;
@synthesize students;
@synthesize token;

static user *instance = nil;

+ (user *)getInstance{
    @synchronized(self){
        if(instance==nil){
            instance = [user new];
            instance->id = 0;
            instance->firstName=@"";
            instance->lastName=@"";
            instance->email=@"";
            instance->password=@"";
            instance->accountStatus = 0;
            instance->serial=nil;
            instance->studentIds=nil;
            instance->students=nil;
            instance->token=nil;
        }
    }
    return instance;
}

- (void)reset{
    self->firstName = @"";
    self->lastName = @"";
    self->email = @"";
    self->password = @"";
    self->accountStatus = 0;
    self->serial = nil;
    self->currentClass = nil;
    self->studentIds = nil;
    self->students = nil;
    self->token = nil;
}


-(void)printUser{
    NSLog(@"\nUser name -> %@, %@,\nUser email -> %@,\nUser account status -> %ld,\nUser serial -> %@,\nUser current class -> %@,\n Student IDs -> %@", self->firstName, self->lastName, self->email, (long)self->accountStatus, self->serial, [self->currentClass getName], self->studentIds);
}

-(NSString *)fullName{
    return [NSString stringWithFormat:@"%@ %@", self->firstName, self->lastName];
}


@end
