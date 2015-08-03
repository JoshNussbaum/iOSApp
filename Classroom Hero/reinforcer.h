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
    
}

-(id) init;

-(id) init:(NSInteger)id_ :(NSInteger)cid_ :(NSString *)name_;

-(void)setId:(NSInteger)id_;

-(void)setCid:(NSInteger)cid_;

-(void)setName:(NSString *)name_;

-(NSInteger)getId;

-(NSInteger)getCid;

-(NSString *)getName;


@end
