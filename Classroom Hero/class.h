//
//  class.h
//  Classroom Hero
//
//  Created by Josh on 7/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface class : NSObject {
    NSInteger id;
    NSString *name;
    NSString *gradeNumber;
    NSInteger level;
    NSInteger progress;
    NSInteger nextLevel;
    NSString *currentDay;
    NSString *hash;
}

-(id) init;

-(id) init:(NSInteger)id_ :(NSString *)name_ :(NSString *)gradeNumber_ :(NSInteger)level_ :(NSInteger)progress_ :(NSInteger)nextLevel_ :(NSString *)currentDay_ :(NSString *)hash_;

// Creation Functions

-(void) setId:(NSInteger)id_;

-(void) setName:(NSString *)name_;

-(void) setGradeNumber:(NSString *)gradeNumber_;

-(void) setCurrentDay:(NSString *)date;

-(void) setHash:(NSString *)hash_;


// Read Functions

-(NSInteger) getId;

-(NSString *) getName;

-(NSString *) getGradeNumber;

-(NSInteger) getLevel;

-(NSInteger) getProgress;

-(NSInteger) getNextLevel;

-(NSString *)getCurrentDate;

-(NSString *)getHash;



// Update Functions

-(void) addPoints:(NSInteger)points;


// Misc Functions
-(void)printClass;

@end
