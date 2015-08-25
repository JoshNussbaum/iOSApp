//
//  classjar.m
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh ;. All rights reserved.
//

#import "classjar.h"

@implementation classjar


#pragma mark - Constructors


- (id) init{
    self = [super init];
    if (self){
        self->id = 0;
        self->cid = 0;
        self->name = @"";
        self->progress = 0;
        self->total = 0;
    }
    return self;
}


- (id)init:(NSInteger)id_ :(NSInteger)cid_ :(NSString *)name_ :(NSInteger)progress_ :(NSInteger)total_{
    self = [super init];
    if (self){
        self->id = id_;
        self->cid = cid_;
        self->name = name_;
        self->progress = progress_;
        self->total = total_;
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


- (void) setProgress:(NSInteger)progress_{
    self->progress = progress_;
}


- (void) setTotal:(NSInteger)total_{
    self->total = total_;
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


- (NSInteger) getProgress{
    return self->progress;
}


- (NSInteger) getTotal{
    return self->total;
}



@end
