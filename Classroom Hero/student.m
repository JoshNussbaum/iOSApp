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
        self->lvlupamount = 0;
        self->lvlsgained = 0;
        self->points = 0;
        self->pointsspent = 0;
        self->pointsspent = 0;
        self->timestamp = nil;
    }
    return self;
}


- (id) init:(NSInteger)id_ :(NSString*)firstName_ :(NSString*)lastName_ :(NSString*)serial_ :(NSInteger)lvl_ :(NSInteger)lvlupamount_ :(NSInteger)lvlsgained_ :(NSInteger)points_  :(NSInteger)pointsgained_  :(NSInteger)pointsspent_ :(NSInteger)totalpoints_ :(NSInteger)progress_ :(NSInteger)progressgained_  :(NSString*)timestamp_{

    self = [super init];
    if (self) {
        self->id = id_;
        self->firstName = firstName_;
        self->lastName = lastName_;
        self->lvl = lvl_;
        self->lvlupamount = lvlupamount_;
        self->lvlsgained = lvlsgained_;
        self->points = points_;
        self->pointsgained = pointsgained_;
        self->pointsspent = pointsspent_;
        self->totalpoints = totalpoints_;
        self->progress = progress_;
        self->progressgained = progressgained_;
        self->serial = serial_;
        self->timestamp = timestamp_;
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


- (void) setPointsspent:(NSInteger)pointsspent_{
    self->pointsspent = pointsspent_;
}


- (void) setTimestamp:(NSString *)timestamp_{
    self->timestamp = timestamp_;
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


- (NSInteger)getLvlsGained{
    return self->lvlsgained;
}


- (NSInteger)getPoints{
    return self->points;
}


- (NSInteger)getPointsGained{
    return self->pointsgained;
}


- (NSInteger)getPointsSpent{
    return self->pointsspent;
}


- (NSInteger)getTotalPoints{
    return self->totalpoints;
}


- (NSInteger)getProgress{
    return self->progress;
}


- (NSInteger)getProgressGained{
    return self->pointsgained;
}


- (NSString *)getSerial{
    return self->serial;
}


- (NSString *)getTimestamp{
    return self->timestamp;
}


#pragma mark - Update


- (void) addPoints:(NSInteger)pointsGained{
    self->points += pointsGained;
    self->pointsgained += pointsGained;
    self->progress += pointsGained;
    self->progressgained += pointsGained;
    
    while (self->progress >= self->lvlupamount)
    {
        [self levelUp:self->progress :self->lvlupamount];
    }
}


- (void) addOnlyPoints:(NSInteger)pointsGained{
    self->points += pointsGained;
    self->pointsgained += pointsGained;
}


#pragma mark - Misc


- (void) levelUp:(NSInteger)progress :(NSInteger)lvlupamount{
    self->lvl += 1;
    self->lvlsgained +=1;
    self->progress = self->progress - self->lvlupamount;
    self->lvlupamount += 2;
}


- (void) printStudent{
    NSLog(@"\n Student UID => %ld,\n Student First Name => %@,\n, Student Last Name => %@,\n Student Serial => %@\n, Student Points => %ld,\n Student PointsGained => %ld,\n Student Progress => %ld,\n Student Level => %ld, \n Student LevelsGained => %ld, \nStudent LevelUpAmount => %ld,\n", (long)self->id, self->firstName, self->lastName, self->serial, (long)self->points, (long)self->pointsgained, (long)self->progress, (long)self->lvl, (long)self->lvlsgained, (long)self->lvlupamount);
}


@end
