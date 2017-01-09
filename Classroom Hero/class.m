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
        self->progress = 0;
        self->level = 1;
        self->nextLevel = 10;
    }
    return self;
}

- (id) init:(NSInteger)id_ :(NSString *)name_ :(NSString *)gradeNumber_ :(NSInteger)level_ :(NSInteger)progress_ :(NSInteger)nextLevel_ :(NSString *)currentDay_{
    self = [super init];
    if (self)
    {
        self->id = id_;
        self->name = name_;
        self->gradeNumber = gradeNumber_;
        self->level = level_;
        self->progress = progress_;
        self->nextLevel = nextLevel_;
        self->currentDay = currentDay_;
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


- (void) setGradeNumber:(NSString *)gradeNumber_{
    self->gradeNumber = gradeNumber_;
}


- (void) setCurrentDay:(NSString *)date{
    self->currentDay = date;
}



#pragma mark - Read


- (NSInteger) getId{
    return self->id;
}


- (NSString *) getName{
    return self->name;
}


- (NSString *) getGradeNumber{
    return self->gradeNumber;
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

- (NSString *)getCurrentDate{
    return self->currentDay;
}




#pragma mark - Update
-(void) addPoints:(NSInteger)points{
    self->progress += points;
    
    if (self->progress >= self->nextLevel)
    {
        [self levelUp];
    }
}

-(void) levelUp{
    self->level++;
    self->progress = 0;
    self->nextLevel = self->level * 6;
}


#pragma mark - Misc


- (void)printClass{
    NSLog(@"\nClass ID=>%li,\n Name=>%@,\n Grade=>%@,\n Level=>%ld,\n Progress=>%ld,\n Next Level=>%ld,\n", (long)self->id, self->name, self->gradeNumber, (long)self->level, (long)self->progress, (long)self->nextLevel);
    
}

@end
