//
//  student.h
//  Classroom Hero
//
//  Created by Josh on 7/31/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface student : NSObject{
    NSInteger id;
    NSString *firstName;
    NSString *lastName;
    NSString *serial;
    NSInteger lvl;
    NSInteger progress;
    NSInteger lvlupamount;
    NSInteger points;
    NSInteger totalpoints;
    BOOL checkedin;
}

-(id) init;

-(id) initWithid:(NSInteger)id_ firstName:(NSString*)firstName_ lastName:(NSString*)lastName_ serial:(NSString*)serial_ lvl:(NSInteger)lvl_ progress:(NSInteger)progress_ lvlupamount:(NSInteger)lvlupamount_ points:(NSInteger)points_  totalpoints:(NSInteger)totalpoints_ checkedin:(BOOL)checkedin_;

// Creation Functions

-(void) setId:(NSInteger)id_;

-(void) setFirstName:(NSString *)firstName_;

-(void) setLastName:(NSString *)lastName_;

-(void) setSerial:(NSString *)serial_;

-(void) setPoints:(NSInteger)points_;

- (void) setLevel:(NSInteger)level_;

- (void) setLevelUpAmount:(NSInteger)levelUpAmount_;

- (void) setProgress:(NSInteger)progress_;

- (void) setCheckedIn:(BOOL)checkedIn_;

// Read Functions
-(NSInteger )getId;

-(NSString *)getFirstName;

-(NSString *)getLastName;

-(NSInteger)getLvl;

-(NSInteger)getLvlUpAmount;

-(NSInteger)getPoints;

-(NSInteger)getTotalPoints;

-(NSInteger)getProgress;

-(NSString*)getSerial;

-(BOOL)getCheckedIn;


// Update Functions
-(void)addPoints:(NSInteger)pointsGained;

-(void)addOnlyPoints:(NSInteger)pointsGained;

-(void)updatePoints:(NSInteger)newPoints;

-(void)updateCheckedIn:(BOOL)checkedIn;

// Misc Functions
-(void) printStudent;

@end
