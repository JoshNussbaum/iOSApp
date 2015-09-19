//
//  reinforcer.m
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "reinforcer.h"

@implementation reinforcer


#pragma mark - Constructors


- (id) init{
    self = [super init];
    if (self){
        self->id = 0;
        self->name = @"";
    }
    return self;
}


- (id) init:(NSInteger)id_ :(NSInteger)cid_ :(NSString *)name_{
    self = [super init];
    if (self){
        self->id = id_;
        self->cid = cid_;
        self->name = name_;
    }
    return self;
}


#pragma mark - Create


- (void)setId:(NSInteger)id_{
    self->id = id_;
}


- (void)setCid:(NSInteger)cid_{
    self->cid = cid_;
}


- (void)setName:(NSString *)name_{
    self->name = name_;
}


#pragma mark - Read



- (NSInteger)getId{
    return self->id;
}


- (NSInteger)getCid{
    return self->cid;
}


- (NSString *)getName{
    return self->name;
}

- (void)printReinforcer{
    NSLog(@"Reinforcer name -> %@,\n Reinforcer Id -> %ld,\n Reinforecer CID -> %ld\n", self->name, (long)self->id , (long)self->cid);
}


@end
