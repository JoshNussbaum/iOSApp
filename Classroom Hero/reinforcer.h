//
//  reinforcer.h
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface reinforcer : NSObject{
    NSInteger id;
    NSInteger cid;
    NSString *name;
    NSInteger value;
}

-(id) init;

-(id)init:(NSInteger)id_ :(NSInteger)cid_ :(NSString *)name_ :(NSInteger)value_;

-(void)setId:(NSInteger)id_;

-(void)setCid:(NSInteger)cid_;

-(void)setName:(NSString *)name_;

-(void)setValue:(NSInteger)value_;

-(NSInteger)getId;

-(NSInteger)getCid;

-(NSString *)getName;

-(NSInteger)getValue;

-(void)printReinforcer;


@end
