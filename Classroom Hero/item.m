//
//  item.m
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "item.h"

@implementation item


#pragma mark - Constructors

- (id) init{
    self = [super init];
    if (self){
        self->id = 0;
        self->cid = 0;
        self->name = @"";
        self->cost = 0;
    }
    return self;
}


- (id)init:(NSInteger)id_ :(NSInteger)cid_ :(NSString *)name_ :(NSInteger)cost_{
    self = [super init];
    if (self){
        self->id = id_;
        self->cid = cid_;
        self->name = name_;
        self->cost = cost_;
    }
    return self;
}


#pragma mark - Create


- (void) setId:(NSInteger)id_{
    self->id = id_;
}


- (void) setCid:(NSInteger)cid_{
    self->cid = cid_;
}


- (void) setName:(NSString *)name_{
    self->name = name_;
}


- (void) setCost:(NSInteger)cost_{
    self->cost = cost_;
}


#pragma mark - Read

- (NSInteger) getId{
    return self->id;
}


- (NSInteger) getCid{
    return self->cid;
}


- (NSString *) getName{
    return self->name;
}


- (NSInteger) getCost{
    return self->cost;
}


- (void) printItem{
    NSLog(@"\n Item id -> %ld,\n Item cid -> %ld,\n Item name -> %@,\n Item cost -> %ld", (long)self->id, (long)self->cid, self->name, (long)self->cost);
}

#pragma mark - Update



@end
