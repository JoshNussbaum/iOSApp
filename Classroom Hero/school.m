//
//  school.m
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "school.h"

@implementation school

-(id) init{
    self = [super init];
    if (self){
        self->id = 0;
        self->name = @"";
    }
    return self;
}

-(id) init:(NSInteger)id_ :(NSString *)name_{
    self = [super init];
    if (self){
        self->id = id_;
        self->name = name_;		
    }
    return self;
}

-(void)setId:(NSInteger)id_{
    self->id = id_;
}

-(void)setName:(NSString *)name_{
    self->name = name_;
}

-(NSInteger)getId{
    return self->id;
}

-(NSString *)getName{
    return self->name;
}

@end
