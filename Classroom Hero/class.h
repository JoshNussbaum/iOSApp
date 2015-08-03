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
    NSInteger gradeNumber;
    NSInteger schoolId;
    NSInteger level;
    NSInteger progress;
    NSInteger nextLevel;
    NSInteger hasStamps;
}

-(id) init;

-(id) init:(NSInteger)id_ :(NSString *)name_ :(NSInteger)gradeNumber_ :(NSInteger)schoolId;

// Creation Functions

-(void) setId:(NSInteger)id_;

-(void) setName:(NSString *)name_;

-(void) setGradeNumber:(NSInteger)gradeNumber_;

-(void) setSchoolId:(NSInteger)schoolId_;




// Read Functions

-(NSInteger) getId;

-(NSString *) getName;

-(NSInteger) getGradeNumber;

-(NSInteger) getSchoolId;

-(NSInteger) getLevel;

-(NSInteger) getProgress;

-(NSInteger) getNextLevel;

-(NSInteger) getHasStamps;



// Update Functions


// Misc Functions
-(void)printClass;

@end