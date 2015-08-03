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
    NSInteger lvlupamount;
    NSInteger lvlsgained;
    NSInteger points;
    NSInteger pointsgained;
    NSInteger pointsspent;
    NSInteger progress;
    NSInteger progressgained;
    NSString *timestamp;
}

-(id) init;

-(id) init:(NSInteger)id_ :(NSString*)firstName_ :(NSString*)lastName_ :(NSString*)serial_ :(NSInteger)lvl_ :(NSInteger)lvlupamount_ :(NSInteger)lvlsgained_ :(NSInteger)points_  :(NSInteger)pointsgained_  :(NSInteger)pointsspent_ :(NSInteger)progress_ :(NSInteger)progressgained_  :(NSString*)timestamp_;

// Creation Functions
-(void) setFirstName:(NSString *)firstName_;

-(void) setLastName:(NSString *)lastName_;

-(void) setSerial:(NSString *)serial_;

-(void) setTimestamp:(NSString *)timestamp_;

-(void) setPoints:(NSInteger)points_;

-(void) setPointsspent:(NSInteger)pointsspent_;

// Read Functions
-(NSInteger )getId;

-(NSString *)getFirstName;

-(NSString *)getLastName;

-(NSInteger)getLvl;

-(NSInteger)getLvlsGained;

-(NSInteger)getLvlUpAmount;

-(NSInteger)getPoints;

-(NSInteger)getPointsGained;

-(NSInteger)getPointsSpent;

-(NSInteger)getProgress;

-(NSInteger)getProgressGained;

-(NSString*)getSerial;

-(NSString*)getTimestamp;


// Update Functions
-(void)addPoints:(NSInteger)pointsGained;

-(void)addOnlyPoints:(NSInteger)pointsGained;

// Misc Functions
-(void) printStudent;

@end
