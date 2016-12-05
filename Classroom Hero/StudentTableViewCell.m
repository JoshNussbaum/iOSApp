//
//  StudentTableViewCell.m
//  Classroom Hero
//
//  Created by Josh on 9/23/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "StudentTableViewCell.h"
#import "Utilities.h"
#import "DatabaseHandler.h"
#import <Google/Analytics.h>


@interface StudentTableViewCell (){
    ConnectionHandler *webHandler;
    user *currentUser;
    BOOL connectionInProgress;

}
@end

@implementation StudentTableViewCell


- (void)initializeWithStudent:(student *)currentStudent_{
    connectionInProgress = NO;
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc] initWithDelegate:self];
    currentStudent = currentStudent_;
    [Utilities makeRoundedButton:self.plusOneButton :[UIColor blackColor]];
    [Utilities makeRoundedButton:self.minusOneButton :[UIColor blackColor]];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]];
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.contentView layoutSubviews];
    if (IS_IPAD_PRO) {
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.pointsLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.levelLabel.hidden = YES;
//        self.levelLabel.frame = CGRectMake(700, 8, 105, 33);
//        self.nameLabel.frame = CGRectMake(5, 8, 650, 33);

    }
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [super layoutSubviews];
    [self.contentView layoutSubviews]; if (IS_IPAD_PRO) {
        self.nameLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.pointsLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.levelLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
        self.levelLabel.hidden = YES;
//        self.levelLabel.frame = CGRectMake(700, 8, 105, 33);
//        self.nameLabel.frame = CGRectMake(5, 8, 650, 33);
    }
}

- (IBAction)minusOneClicked:(id)sender {
    if ([currentStudent getPoints] > 0 && !connectionInProgress){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                              action:@"Minus One Clicked"
                                                               label:[currentStudent fullName]
                                                               value:@1] build]];
        connectionInProgress = YES;
        [webHandler subtractPointsWithStudentId:[currentStudent getId] points:1];
    }
}

- (IBAction)plusOneClicked:(id)sender {
    if (!connectionInProgress){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                              action:@"Plus One Clicked"
                                                               label:[currentStudent fullName]
                                                               value:@1] build]];
        connectionInProgress = YES;
        [webHandler addPointsWithStudentId:[currentStudent getId] points:1];
    }
}

- (void)dataReady:(NSDictionary *)data :(NSInteger)type {
    if (data == nil){
        [Utilities alertStatusNoConnection];
        connectionInProgress = NO;
        return;
    }
    
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if([successNumber boolValue] == YES){

        if (type == ADD_POINTS || type == SUBTRACT_POINTS){
            UIColor *backgroundColor;
//            if (type == ADD_POINTS){
//                [Utilities CHGoldColor];
//                backgroundColor = [UIColor colorWithRed:124.0/255.0 green:166.0/255.0 blue:115/255.0 alpha:0.8];
//            }
//            else {
//                backgroundColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:0.8];
//            }
//            [UIView animateWithDuration:0.2
//                             animations:^{
//                                 self.backgroundColor = backgroundColor;
//;
//                             }
//                             completion:^(BOOL finished) {
//                                 double delayInSeconds = 0.2;
//                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                                     self.backgroundColor = [UIColor clearColor];
//
//                                 });
//                             }
//             ];
            
            
            NSDictionary *studentDictionary = [data objectForKey:@"student"];
            
            NSNumber * pointsNumber = (NSNumber *)[studentDictionary objectForKey: @"currentCoins"];
            NSNumber * idNumber = (NSNumber *)[studentDictionary objectForKey: @"id"];
            NSNumber * levelNumber = (NSNumber *)[studentDictionary objectForKey: @"lvl"];
            NSNumber * progressNumber = (NSNumber *)[studentDictionary objectForKey: @"progress"];
            NSNumber * totalPoints = (NSNumber *)[studentDictionary objectForKey: @"totalCoins"];
            NSInteger lvlUpAmount = 3 + (2*(levelNumber.integerValue - 1));
            
            [currentStudent setPoints:pointsNumber.integerValue];
            [currentStudent setLevel:levelNumber.integerValue];
            [currentStudent setProgress:progressNumber.integerValue];
            [currentStudent setLevelUpAmount:lvlUpAmount];
            [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
            self.pointsLabel.text = [NSString stringWithFormat:@"%ld points", (long)[currentStudent getPoints]];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@ %@", [currentStudent getFirstName], [currentStudent getLastName]],@"Student Name", [NSString stringWithFormat:@"%ld", (long)[currentStudent getId]], @"Student ID", [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            if (type == ADD_POINTS){
                // add points - student able view cell
            }
            else {
                // subtract points
            }
            connectionInProgress = NO;
            
        }
        else {
            [Utilities alertStatusNoConnection];
            connectionInProgress = NO;
        }
        
    }
}
@end
