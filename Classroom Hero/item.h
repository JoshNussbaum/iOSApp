//
//  item.h
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface item : NSObject
{
    NSInteger id;
    NSInteger cid;
    NSString *name;
    NSInteger cost;
}

//Constructors

-(id) init;

-(id)init:(NSInteger)id_ :(NSInteger)cid_  :(NSString *)name_ :(NSInteger)cost_;

//Creation Functions

-(void) setId:(NSInteger)id_;

-(void) setCid:(NSInteger)cid_;

-(void) setName:(NSString *)name_;

-(void) setCost:(NSInteger)cost_;

//Read Functions

-(NSInteger) getId;

-(NSInteger) getCid;

-(NSString *) getName;

-(NSInteger) getCost;


-(void) printItem;

@end