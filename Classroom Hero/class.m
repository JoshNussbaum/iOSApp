//
//  class.m
//  Classroom Hero
//
//  Created by Josh on 7/29/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "class.h"

@implementation class

-(id) init{
    self = [super init];
    if (self)
    {
        self->id = 0;
        self->name = @"";
    }
    return self;
}

-(id) init:(NSInteger)id_ :(NSString *)name_ :(NSInteger)gradeNumber_ :(NSInteger)schoolId_{
    self = [super init];
    if (self)
    {
        self->id = id_;
        self->name = name_;
        self->gradeNumber = gradeNumber_;
        self->schoolId = schoolId_;
        self->level = 1;
        self->nextLevel = 10;
        self->progress = 0;
        self->hasStamps = 0;
    }
    return self;
}

// Creation Functions

-(void) setId:(NSInteger)id_{
    self->id = id_;
}


-(void) setName:(NSString *)name_{
    self->name = name_;
}


-(void) setGradeNumber:(NSInteger)gradeNumber_{
    self->gradeNumber = gradeNumber_;
}


-(void) setSchoolId:(NSInteger)schoolId_{
    self->schoolId = schoolId_;
}



// Read Functions

-(NSInteger) getId{
    return self->id;
}

-(NSString *) getName{
    return self->name;
}

-(NSInteger) getGradeNumber{
    return self->gradeNumber;
}

-(NSInteger)getSchoolId{
    return self->schoolId;
}

-(NSInteger)getLevel{
    return self->level;
}

-(NSInteger)getProgress{
    return self->progress;
}

-(NSInteger)getNextLevel{
    return self->nextLevel;
}

-(NSInteger)getHasStamps{
    return self->hasStamps;
}




// Update Functions


// Misc Functions
-(void)printClass{
    NSLog(@"Class ID=>%li\n, Name=>%@\n, Grade=>%d\n", (long)self->id, self->name, self->gradeNumber);
    
}

@end