//
//  classjar.h
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface classjar : NSObject
{
    NSInteger id;
    NSString *name;
    NSInteger cid;
    NSInteger progress;
    NSInteger total;
}

//Constructors

-(id) init;

-(id)initWithid:(NSInteger)id_ cid:(NSInteger)cid_ name:(NSString *)name_ progress:(NSInteger)progress_ total:(NSInteger)total_;

//Creation Functions

-(void) setId:(NSInteger)id_;

-(void) setCid:(NSInteger)cid_;

-(void) setName:(NSString *)name_;

-(void) setProgress:(NSInteger)progress_;

-(void) setTotal:(NSInteger)total_;

//Read Functions

-(NSInteger) getId;

-(NSInteger) getCid;

-(NSString *) getName;

-(NSInteger) getProgress;

-(NSInteger) getTotal;

//Update Functions

-(void) updateJar:(NSInteger)points;

-(void) printJar;

@end