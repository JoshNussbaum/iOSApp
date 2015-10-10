//
//  student.m
//  Classroom Hero
//
//  Created by Josh on 10/6/14.
//  Copyright (c) 2014 Josh Nussbaum. All rights reserved.
//

#import "student.h"

@implementation student


#pragma mark - Constructors


- (id) init{
    self = [super init];
    if (self){
        self->id = 0;
        self->firstName = @"";
        self->lastName = @"";
        self->lvl = 0;
        self->lvlupamount = 5;
        self->points = 0;
    }
    return self;
}


-(id) initWithid:(NSInteger)id_ firstName:(NSString*)firstName_ lastName:(NSString*)lastName_ serial:(NSString*)serial_ lvl:(NSInteger)lvl_ progress:(NSInteger)progress_ lvlupamount:(NSInteger)lvlupamount_ points:(NSInteger)points_  totalpoints:(NSInteger)totalpoints_{
    self = [super init];
    if (self) {
        self->id = id_;
        self->firstName = firstName_;
        self->lastName = lastName_;
        self->lvl = lvl_;
        self->lvlupamount = lvlupamount_;
        self->points = points_;
        self->totalpoints = totalpoints_;
        self->progress = progress_;
        self->serial = serial_;
    }
    return self;
}


#pragma mark - Create


-(void) setId:(NSInteger)id_{
    self->id = id_;
}


- (void) setFirstName:(NSString *)firstName_{
    self->firstName = firstName_;
}


- (void) setLastName:(NSString *)lastName_{
    self->lastName = lastName_;
}


- (void)setSerial:(NSString *)serial_{
    self->serial = serial_;
}


- (void) setPoints:(NSInteger)points_{
    self->points = points_;
}


- (void) setLevel:(NSInteger)level_{
    self->lvl = level_;
}


- (void) setLevelUpAmount:(NSInteger)levelUpAmount_{
    self->lvlupamount = levelUpAmount_;
}


- (void) setProgress:(NSInteger)progress_{
    self->progress = progress_;
}


#pragma mark - Read


- (NSInteger)getId{
    return self->id;
}


- (NSString *)getFirstName{
    return self->firstName;
}


- (NSString *)getLastName{
    return self->lastName;
}


- (NSInteger)getLvl{
    return self->lvl;
}


- (NSInteger)getLvlUpAmount{
    return self->lvlupamount;
}


- (NSInteger)getPoints{
    return self->points;
}



- (NSInteger)getTotalPoints{
    return self->totalpoints;
}


- (NSInteger)getProgress{
    return self->progress;
}

- (NSString *)getSerial{
    return self->serial;
}



#pragma mark - Update


- (void) addPoints:(NSInteger)pointsGained{
    self->points += pointsGained;
    self->progress += 1;
    
    while (self->progress >= self->lvlupamount)
    {
        [self levelUp:self->progress :self->lvlupamount];
    }
}


- (void) addOnlyPoints:(NSInteger)pointsGained{
    self->points += pointsGained;
}


- (void)updatePoints:(NSInteger)newPoints{
    self->points = newPoints;
}


#pragma mark - Misc


- (void) levelUp:(NSInteger)progress :(NSInteger)lvlupamount{
    self->lvl += 1;
    self->progress = self->progress - self->lvlupamount;
    self->lvlupamount += 2;
}


- (void) printStudent{
    NSLog(@"\n Student UID => %ld,\n Student First Name => %@,\n Student Last Name => %@,\n Student Serial => %@\n Student Points => %ld,\n Student Progress => %ld,\n Student Level => %ld,\n Student LevelUpAmount => %ld,\n Total Points => %ld,\n", (long)self->id, self->firstName, self->lastName, self->serial, (long)self->points,  (long)self->progress, (long)self->lvl,  (long)self->lvlupamount, (long)self->totalpoints);
}


@end
