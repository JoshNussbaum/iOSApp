//
//  class.m
//  Classroom Hero
//
//  Created by Josh on 7/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "class.h"

@implementation class

- (id) init{
    self = [super init];
    if (self)
    {
        self->id = 0;
        self->name = @"";
        self->nextLevel = 10;
    }
    return self;
}

- (id) init:(NSInteger)id_ :(NSString *)name_ :(NSInteger)gradeNumber_ :(NSInteger)schoolId_ :(NSInteger)level_ :(NSInteger)progress_ :(NSInteger)nextLevel_ :(NSInteger)hasStamps_{
    self = [super init];
    if (self)
    {
        self->id = id_;
        self->name = name_;
        self->gradeNumber = gradeNumber_;
        self->schoolId = schoolId_;
        self->level = level_;
        self->progress = progress_;
        self->nextLevel = nextLevel_;
        self->hasStamps = 0;
    }
    return self;
}


#pragma mark - Create


- (void) setId:(NSInteger)id_{
    self->id = id_;
}


- (void) setName:(NSString *)name_{
    self->name = name_;
}


- (void) setGradeNumber:(NSInteger)gradeNumber_{
    self->gradeNumber = gradeNumber_;
}


- (void) setSchoolId:(NSInteger)schoolId_{
    self->schoolId = schoolId_;
}



#pragma mark - Read


- (NSInteger) getId{
    return self->id;
}


- (NSString *) getName{
    return self->name;
}


- (NSInteger) getGradeNumber{
    return self->gradeNumber;
}


- (NSInteger)getSchoolId{
    return self->schoolId;
}


- (NSInteger)getLevel{
    return self->level;
}


- (NSInteger)getProgress{
    return self->progress;
}


- (NSInteger)getNextLevel{
    return self->nextLevel;
}


- (NSInteger)getHasStamps{
    return self->hasStamps;
}



#pragma mark - Update
-(void) addPoints:(NSInteger)points{
    self->progress += 1;
    
    if (self->progress >= self->nextLevel)
    {
        [self levelUp];
    }
}

-(void) levelUp{
    self->level++;
    self->progress = 0;
    self->nextLevel+= 5;
}


#pragma mark - Misc


- (void)printClass{
    NSLog(@"\nClass ID=>%li,\n Name=>%@,\n Grade=>%ld,\n School Id=>%ld,\n Level=>%ld,\n Progress=>%ld,\n Next Level=>%ld,\n Has Stamps=>%ld\n", (long)self->id, self->name, (long)self->gradeNumber, (long)self->schoolId, (long)self->level, (long)self->progress, (long)self->nextLevel, (long)self->hasStamps);
    
}

@end