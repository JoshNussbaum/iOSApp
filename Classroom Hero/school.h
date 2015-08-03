//
//  school.h
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface school : NSObject{
    NSInteger id;
    NSString *name;
}

-(id) init;

-(id) init:(NSInteger)id_ :(NSString *)name_;

-(void)setId:(NSInteger)id_;

-(void)setName:(NSString *)name_;

-(NSInteger)getId;

-(NSString *)getName;


@end
