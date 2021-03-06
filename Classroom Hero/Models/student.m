//
//  student.m
//  Classroom Hero
//
//  Created by Josh on 10/6/14.
//  Copyright (c) 2014 Josh Nussbaum. All rights reserved.
//

#import "student.h"



@implementation student

@synthesize id;
@synthesize firstName;
@synthesize lastName;
@synthesize lvl;
@synthesize lvlupamount;
@synthesize points;
@synthesize checkedin;
@synthesize totalpoints;
@synthesize progress;
@synthesize hash;

#pragma mark - Constructors


- (id) init{
    self = [super init];
    if (self){
        self->id = 0;
        self->firstName = @"";
        self->lastName = @"";
        self->lvl = 0;
        self->lvlupamount = 3;
        self->points = 0;
        self->checkedin = NO;
    }
    return self;
}


-(id) initWithid:(NSInteger)id_ firstName:(NSString*)firstName_ lastName:(NSString*)lastName_ lvl:(NSInteger)lvl_ progress:(NSInteger)progress_ lvlupamount:(NSInteger)lvlupamount_ points:(NSInteger)points_  totalpoints:(NSInteger)totalpoints_ checkedin:(BOOL)checkedin_ hash:(NSString *)hash_{
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
        self->checkedin = checkedin_;
        self->hash = hash_;
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

- (void) setCheckedIn:(BOOL)checkedIn_{
    self->checkedin = checkedIn_;
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

- (BOOL)getCheckedIn{
    return self->checkedin;
}

- (NSString *)getHash{
    return self->hash;
}


#pragma mark - Update


- (void) addPoints:(NSInteger)pointsGained{
    self->points += pointsGained;
    self->totalpoints += pointsGained;
    self->progress += 1;
    
    if (self->progress >= self->lvlupamount)
    {
        [self levelUp];
    }
}


- (void) addOnlyPoints:(NSInteger)pointsGained{
    self->points += pointsGained;
}


- (void)updatePoints:(NSInteger)newPoints{
    self->points = newPoints;
}

- (void)updateCheckedIn:(BOOL)checkedIn_{
    self->checkedin = checkedIn_;
}


#pragma mark - Misc


- (void) levelUp{
    self->lvl += 1;
    self->progress = 0;
    self->lvlupamount += 3;
}


- (void) printStudent{
    NSString *checkedInString;
    if (self->checkedin){
        checkedInString = @"Checked in";
    } else checkedInString = @"Not checked in";
    
    NSLog(@"\n Student UID => %ld,\n Student First Name => %@,\n Student Last Name => %@,\n Student Points => %ld,\n Student Progress => %ld,\n Student Level => %ld,\n Student LevelUpAmount => %ld,\n Total Points => %ld,\n %@,\n Hash -> %@", (long)self->id, self->firstName, self->lastName, (long)self->points,  (long)self->progress, (long)self->lvl,  (long)self->lvlupamount, (long)self->totalpoints, checkedInString, self->hash);
}

-(NSString *)fullName{
    return [NSString stringWithFormat:@"%@ %@", self->firstName, self->lastName];
}


@end
