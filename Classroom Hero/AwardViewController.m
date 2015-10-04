//
//  AwardViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "AwardViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ClassJarViewController.h"
#import "MarketViewController.h"
#import "MBProgressHUD.h"
#import "StudentsTableViewController.h"

@interface AwardViewController (){
    NSMutableArray *reinforcerData;
    
    reinforcer *currentReinforcer;
    NSString *tmpName;
    
    user *currentUser;
    ConnectionHandler *webHandler;
    MBProgressHUD *hud;

    NSInteger index;
    
    // 3 Coins Rects
    CGRect aOneRect;
    CGRect aTwoRect;
    CGRect aThreeRect;
    
    // 2 Coins Rects
    CGRect bOneRect;
    CGRect bTwoRect;
    
    // 1 Coin Rect
    CGRect cOneRect;
    
    CGRect coinRect;
    CGRect levelRect;
    CGRect awardRect;

    SystemSoundID failSound;
    SystemSoundID award;
    SystemSoundID coins;
    SystemSoundID levelUp;
    SystemSoundID awardAllStamp;
    SystemSoundID teacherStamp;
    
    bool isStamping;
    
    student *currentStudent;
    NSInteger pointsAwarded;
    NSInteger tmpPoints;
}

@end


@implementation AwardViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    
    reinforcerData = [[DatabaseHandler getSharedInstance]getReinforcers:[currentUser.currentClass getId]];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];

    self.categoryPicker.delegate = self;
    self.categoryPicker.dataSource = self;
    
    self.nameLabel.text=@"";
    
    failSound = [Utilities getFailSound];
    award = [Utilities getAwardSound];
    coins = [Utilities getCoinShakeSound];
    levelUp = [Utilities getLevelUpSound];
    awardAllStamp = [Utilities getAwardAllSound];
    teacherStamp = [Utilities getTeacherStampSound];
    
    self.appKey = snowshoe_app_key ;
    self.appSecret = snowshoe_app_secret;
    
    
    // 3 Coins Rects
    aOneRect = self.aOne.frame;
    aTwoRect = self.aTwo.frame;
    aThreeRect = self.aThree.frame;
    
    // 2 Coins Rects
    bOneRect = self.bOne.frame;
    bTwoRect = self.bTwo.frame;
    
    // 1 Coin Rect
    cOneRect = self.cOne.frame;
    
    coinRect = self.aTwo.frame;
    if (reinforcerData.count > 0){
        NSLog(@"In here bro");
        [self.categoryPicker selectRow:index inComponent:0 animated:YES];
        self.categoryPicker.hidden = NO;
        currentReinforcer = [reinforcerData objectAtIndex:0];
        [currentReinforcer printReinforcer];
        self.reinforcerLabel.text= [NSString stringWithFormat:@"%@", [currentReinforcer getName]];
        [self.categoryPicker reloadAllComponents];

    }
    
    if (!reinforcerData || [reinforcerData count] == 0) {
        self.categoryPicker.hidden = YES;
        self.reinforcerLabel.text=@"Add  reinforcers  above";
        self.editReinforcerButton.hidden = YES;

    }
    else {
        self.editReinforcerButton.hidden = NO;
    }

}


- (void)viewWillAppear:(BOOL)animated{
    self.nameLabel.hidden = YES;
}


- (void)setReinforcerName{
    index = [self.categoryPicker selectedRowInComponent:0];
    currentReinforcer = [reinforcerData objectAtIndex:index];
    NSLog(@"At row -> %ld we have \n ", (long)index);
    [currentReinforcer printReinforcer];
    self.reinforcerLabel.text= [NSString stringWithFormat:@"%@", [currentReinforcer getName]];
}


- (void)viewDidAppear:(BOOL)animated{
    isStamping = NO;
}


- (IBAction)addReinforcerClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Add Reinforcer" message:nil cancel:nil  done:nil delete:NO input:@"Reinforcer name" tag:2 view:self];
}


- (IBAction)editReinforcerClicked:(id)sender {
    if (reinforcerData.count > 0){
        index = [self.categoryPicker selectedRowInComponent:0];
        currentReinforcer = [reinforcerData objectAtIndex:index];
        [Utilities editAlertTextWithtitle:@"Edit Reinforcer" message:nil cancel:nil done:nil delete:YES input:[currentReinforcer getName] tag:1 view:self];
    }
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UITextPosition *beginning = [textField beginningOfDocument];
    [textField setSelectedTextRange:[textField textRangeFromPosition:beginning
                                                          toPosition:beginning]];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    if (alertView.tag == 1){
        NSLog(@"BUTTON INDEX -> %ld", (long)buttonIndex );
        if (buttonIndex == 1){
            NSString *newReinforcerName = [alertView textFieldAtIndex:0].text;
            
            NSString *errorMessage = [Utilities isInputValid:newReinforcerName :@"Reinforcer Name"];
            
            if ([errorMessage isEqualToString:@""]){
                [self activityStart:@"Editing Reinforcer..."];
                [currentReinforcer setName:newReinforcerName];
                [webHandler editCategory:[currentReinforcer getId] :newReinforcerName];
            }
            else {
                [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
            }
            
        }
        else if (buttonIndex == 2){
            NSString *deleteMessage = [NSString stringWithFormat:@"Really delete %@?", [currentReinforcer getName]];
            NSLog(@"Here is the delete message -> %@", deleteMessage);
            [Utilities alertStatusWithTitle:@"Confirm delete" message:deleteMessage cancel:@"Cancel" otherTitles:@[@"Delete"] tag:3 view:self];
        }

    }
    else if (alertView.tag == 2){
        tmpName = [alertView textFieldAtIndex:0].text;
        
        NSString *errorMessage = [Utilities isInputValid:tmpName :@"Reinforcer Name"];
        
        if ([errorMessage isEqualToString:@""]){
            [self activityStart:@"Adding Reinforcer..."];
            [webHandler addReinforcer:[currentUser.currentClass getId] :tmpName];
            
        }
        else {
            [Utilities alertStatusWithTitle:@"Error adding reinforcer" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
    }
    else if (alertView.tag == 3){
        [webHandler deleteCategory:[currentReinforcer getId]];
    }
    
}


- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    NSLog(@"In award data ready -> %@", data);
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        isStamping = NO;
        self.nameLabel.hidden=YES;
        self.pointsLabel.hidden=YES;
        self.levelLabel.hidden=YES;
        self.sackImage.hidden=YES;
        self.levelBar.hidden=YES;
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];
    if (type == EDIT_REINFORCER){
        
        if([successNumber boolValue] == YES)
        {
            [[DatabaseHandler getSharedInstance] editReinforcer:currentReinforcer];
            [reinforcerData replaceObjectAtIndex:index withObject:currentReinforcer];
            [self.categoryPicker reloadAllComponents];
            [self setReinforcerName];
            [hud hide:YES];

        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            
            [hud hide:YES];
            return;
        }
    }
    else if (type == ADD_REINFORCER){
        if([successNumber boolValue] == YES)
        {
            NSInteger reinforcerId = [[data objectForKey:@"id"] integerValue];
            reinforcer *rr = [[reinforcer alloc] init:reinforcerId :[currentUser.currentClass getId] :tmpName];
            
            [[DatabaseHandler getSharedInstance] addReinforcer:rr];
            [reinforcerData insertObject:rr atIndex:0];
            [self.categoryPicker reloadAllComponents];
            
            [self.categoryPicker selectRow:0 inComponent:0 animated:NO];

            [self setReinforcerName];

            [hud hide:YES];
            self.editReinforcerButton.hidden = NO;
            self.categoryPicker.hidden = NO;
            


        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error editing reinforcer" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            
            [hud hide:YES];
            return;
        }
    }
    else if (type == DELETE_REINFORCER){
        if([successNumber boolValue] == YES){
            [[DatabaseHandler getSharedInstance]deleteReinforcer:[currentReinforcer getId]];
            [reinforcerData removeObjectAtIndex:index];
            [self.categoryPicker reloadAllComponents];
            
            if (!reinforcerData || [reinforcerData count] == 0) {
                self.categoryPicker.hidden = YES;
                self.reinforcerLabel.text=@"Add  reinforcers  above";
                self.editReinforcerButton.hidden = YES;
            }
            else {
                [self setReinforcerName];
            }
        }

    }
    else if (type == REWARD_STUDENT){
        if([successNumber boolValue] == YES)
        {
            NSInteger startLevel = [currentStudent getLvl];
            tmpPoints = [currentStudent getPoints];
            [currentStudent addPoints:pointsAwarded];
            NSInteger newLevel = [currentStudent getLvl];
            
            [self addPoints:pointsAwarded levelup:(newLevel > startLevel) ? YES : NO];

            [[DatabaseHandler getSharedInstance]updateStudent:currentStudent];
            
            
            
            //TODO- Flurry
            
            
        }
        else {
            NSString *message = [data objectForKey:@"message"];
            [Utilities alertStatusWithTitle:@"Error rewarding student" message:message cancel:nil otherTitles:nil tag:0 view:nil];
            return;
        }
    }
    else if (type == REWARD_ALL_STUDENTS){
        if ([successNumber boolValue] == YES){
            AudioServicesPlaySystemSound(teacherStamp);
            [[DatabaseHandler getSharedInstance] rewardAllStudentsInClassWithid:[currentUser.currentClass getId]];
            [self awardAllStudents];
        }
    }
}


- (void)awardAllStudents{
    awardRect = CGRectMake(self.stampImage.frame.origin.x, self.stampImage.frame.origin.y, self.stampImage.frame.size.width, self.stampImage .frame.size.height);
    self.nameLabel.text = @"+1 All Students";
    self.nameLabel.hidden = NO;
    double delayInSeconds = .6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.6
                         animations:^{
                             [Utilities wiggleImage:self.stampImage sound:NO];
                         }
                         completion:^(BOOL finished) {
                             double delayInSeconds = .5;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 
                                 AudioServicesPlaySystemSound([Utilities getAwardAllSound]);
                                 double delayInSeconds = 1.0;
                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                     
                                     [UIView animateWithDuration:.3
                                                      animations:^{
                                                          [self.stampImage setFrame:awardRect];
                                                      }
                                      ];
                                     
                                     self.nameLabel.text = @"";
                                     isStamping = NO;
                                     
                                 });
                             });
                         }
         ];
    });
}


- (void)rewardStudent{
    
}


- (void)displayStudent{
    self.categoryPicker.hidden = YES;
    NSString *studentName = [[currentStudent getFirstName] stringByAppendingString:[NSString stringWithFormat:@" %@",[currentStudent getLastName]]];
    self.nameLabel.text = studentName;
    self.nameLabel.hidden = NO;
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld", (long)[currentStudent getPoints]];
    self.pointsLabel.hidden = NO;
    
    self.levelBar.progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
    self.levelBar.hidden = NO;
    NSString *levelDisplay = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
    self.levelLabel.text=levelDisplay;
    self.levelLabel.hidden = NO;
    
    
    self.sackImage.hidden = NO;
}


- (void)stampResultDidChange:(NSString *)stampResult{
    if (!isStamping && (reinforcerData.count > 0)){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                isStamping = YES;
                [Utilities wiggleImage:self.stampImage sound:NO];
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                if (![currentUser.serial isEqualToString:@""]){
                    if ([Utilities isValidClassroomHeroStamp:stampSerial]){
                        if ([stampSerial isEqualToString:currentUser.serial]){
                            [webHandler rewardAllStudentsWithcid:[currentUser.currentClass getId]];
                        }
                        else if ([[DatabaseHandler getSharedInstance] isValidStamp:stampSerial :[currentUser.currentClass getSchoolId]]){
                            currentStudent = [[DatabaseHandler getSharedInstance]getStudentWithSerial:stampSerial];
                            [self displayStudent];
                            pointsAwarded = [Utilities getRewardNumber];
                            NSLog(@"Points awarded -> %ld", (long)pointsAwarded);
                            [webHandler rewardStudentWithid:[currentStudent getId] pointsEarned:pointsAwarded categoryId:[currentReinforcer getId]];
                        }
                        else {
                            [Utilities failAnimation:self.stampImage];
                            isStamping = NO;
                        }
                    }
                    else {
                        [Utilities alertStatusWithTitle:@"Invalid Stamp" message:@"You must use a Classroom Hero stamp" cancel:nil otherTitles:nil tag:0 view:nil];
                        isStamping = NO;
                    }
                }
                else {
                    [Utilities alertStatusWithTitle:@"Error awarding points" message:@"You must register your teacher stamp first" cancel:nil otherTitles:nil tag:0 view:nil];
                }
       
            }
            else {
                AudioServicesPlaySystemSound(failSound);
                self.nameLabel.text=@"Try  Stamping  Again";
                self.nameLabel.hidden = NO;
                isStamping = NO;
            }
        }
        else {
            isStamping  =  NO;
        }
    }

}



/* Animations for Awarding Points */




- (void)addPoints:(NSInteger)points levelup:(bool)levelup{
    AudioServicesPlaySystemSound(award);
    
    if (levelup){
        levelRect = CGRectMake(self.levelView.frame.origin.x, self.levelView.frame.origin.y, self.levelView.frame.size.width, self.levelView.frame.size.height);
    }
    if (points == 3){
        [self threeCoinsAnimationWithlevelup:levelup];
    }
    else if (points == 2){
        [self twoCoinsAnimationWithlevelup:levelup];
    }
    else if (points == 1){
        [self oneCoinAnimationWithlevelup:levelup];
    }

}


- (void)incrementPoints{
    while (pointsAwarded > 0)
    {
        NSString *scoreDisplay = [NSString stringWithFormat:@"%ld", (long)++tmpPoints];
        [self.pointsLabel setText:scoreDisplay];
        [self performSelector:@selector(incrementPoints) withObject:nil afterDelay:0.15 ];
        pointsAwarded -- ;
    }
}


- (void)animateCoinToSack:(UIImageView *)coin{
    [coin setFrame:CGRectMake(self.sackImage.frame.origin.x + self.sackImage.frame.size.width/2 - 30, self.sackImage.frame.origin.y+50, self.sackImage.frame.size.width-75, self.sackImage.frame.size.height-75)];
    coin.alpha = 0;
}


- (void)showLevelView{
    self.levelUpLabel.text = [NSString stringWithFormat:@"Level :%li", (long)[currentStudent getLvl]];
    self.levelView.alpha = 1.0;
    AudioServicesPlaySystemSound(levelUp);
    [UIView animateWithDuration:.6
                     animations:^{
                         self.levelView.hidden = NO;
                         
                         [self.levelView setFrame:CGRectMake(40,475, 689, 88)];
                         
                     }completion:^(BOOL finished) {
                         
                         double delayInSeconds = 1.25;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.5
                                              animations:^{
                                                  [self.levelView setFrame:CGRectMake(40,1200, 689, 88)];
                                                  self.levelView.alpha = 0;
                                              }
                                              completion:^(BOOL finished) {
                                                  self.levelView.hidden = YES;
                                                  [self.levelView setFrame:levelRect];
                                              }
                              ];
                         });
                     }
     ];
    
}


- (void)oneCoinAnimationWithlevelup:(bool)levelup{
    [UIView animateWithDuration:.4
                     animations:^{
                         self.cOne.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         double delayInSeconds = .5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.5
                                              animations:^{
                                                  
                                                  [self animateCoinToSack:self.cOne];
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  [Utilities sackWiggle:self.sackImage];
                                                  AudioServicesPlaySystemSound(coins);
                                                  float t = pointsAwarded * .15;
                                                  if (levelup) t = .6;
                                                  [UIView animateWithDuration:t
                                                                   animations:^{
                                                                       [self.cOne setFrame:cOneRect];
                                                                       float progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
                                                                       [self.levelBar setProgress:progress animated:YES];
                                                                       [self incrementPoints];
                                                                       if (levelup){
                                                                           self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
                                                                           [UIView animateWithDuration:.6 animations:^{
                                                                               [self showLevelView];
                                                                            }];
                                                                       }
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       double delayInSeconds = 1.0;
                                                                       if (levelup) delayInSeconds = 2.6;
                                                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                           [UIView animateWithDuration:.5
                                                                                            animations:^{
                                                                                                self.nameLabel.hidden=YES;
                                                                                                self.pointsLabel.hidden=YES;
                                                                                                self.levelLabel.hidden=YES;
                                                                                                self.sackImage.hidden=YES;
                                                                                                self.levelBar.hidden=YES;
                                                                                            }
                                                                                            completion:^(BOOL finished) {
                                                                                                self.categoryPicker.hidden = NO;
                                                                                                isStamping = NO;
                                                                                            }
                                                                            ];
                                                                       });
                                                                   }
                                                   ];
                                              }
                              ];
                         });
                         
                     }
     ];

}


- (void)twoCoinsAnimationWithlevelup:(bool)levelup{
    [UIView animateWithDuration:.5
                     animations:^{
                         self.bOne.alpha = 1.0;
                         self.bTwo.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         double delayInSeconds = .5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.2
                                              animations:^{
                                                  
                                                  [self animateCoinToSack:self.bOne];
                                              }
                                              completion:^(BOOL finished) {
                                                  [Utilities sackWiggle:self.sackImage];
                                                  [UIView animateWithDuration:.2
                                                                   animations:^{
                                                                       [self animateCoinToSack:self.bTwo];
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       [Utilities sackWiggle:self.sackImage];
                                                                       AudioServicesPlaySystemSound(coins);
                                                                       float t = pointsAwarded * .15;
                                                                       if (levelup) t = .6;
                                                                       [UIView animateWithDuration:t
                                                                                        animations:^{
                                                                                            [self.bOne setFrame:bOneRect];
                                                                                            [self.bTwo setFrame:bTwoRect];
                                                                                            float progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
                                                                                            [self.levelBar setProgress:progress animated:YES];
                                                                                            [self incrementPoints];
                                                                                            if (levelup){
                                                                                                self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
                                                                                                [UIView animateWithDuration:.6 animations:^{
                                                                                                    [self showLevelView];
                                                                                                }];
                                                                                            }
                                                                                        }
                                                                                        completion:^(BOOL finished) {
                                                                                            double delayInSeconds = 1.0;
                                                                                            if (levelup) delayInSeconds = 2.6;
                                                                                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                                                [UIView animateWithDuration:.5
                                                                                                                 animations:^{
                                                                                                                     self.nameLabel.hidden=YES;
                                                                                                                     self.pointsLabel.hidden=YES;
                                                                                                                     self.levelLabel.hidden=YES;
                                                                                                                     self.sackImage.hidden=YES;
                                                                                                                     self.levelBar.hidden=YES;
                                                                                                                 }
                                                                                                                 completion:^(BOOL finished) {
                                                                                                                     self.categoryPicker.hidden = NO;
                                                                                                                     isStamping = NO;
                                                                                                                 }
                                                                                                 ];
                                                                                            });
                                                                                        }
                                                                        ];
                                                                       
                                                                   }
                                                   ];
                                              }
                              ];
                             
                         });
                     }
     ];
}


- (void)threeCoinsAnimationWithlevelup:(bool)levelup{
    [UIView animateWithDuration:.4
                     animations:^{
                         self.aOne.alpha = 1.0;
                         self.aTwo.alpha = 1.0;
                         self.aThree.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         double delayInSeconds = .5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             [UIView animateWithDuration:.2
                                              animations:^{
                                                  [self animateCoinToSack:self.aOne];
                                              }
                                              completion:^(BOOL finished) {
                                                  [Utilities sackWiggle:self.sackImage];
                                                  [UIView animateWithDuration:.2
                                                                   animations:^{
                                                                       [self animateCoinToSack:self.aTwo];
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       [UIView animateWithDuration:.2
                                                                                        animations:^{
                                                                                            [self animateCoinToSack:self.aThree];
                                                                                        }
                                                                                        completion:^(BOOL finished) {
                                                                                            [Utilities sackWiggle:self.sackImage];
                                                                                            AudioServicesPlaySystemSound(coins);
                                                                                            float t = pointsAwarded * .15;
                                                                                            if (levelup) t = .6;
                                                                                            [UIView animateWithDuration:t
                                                                                                             animations:^{
                                                                                                                 [self.aOne setFrame:aOneRect];
                                                                                                                 [self.aTwo setFrame:aTwoRect];
                                                                                                                 [self.aThree setFrame:aThreeRect];
                                                                                                                 float progress = (float)[currentStudent getProgress] / (float)[currentStudent getLvlUpAmount];
                                                                                                                 [self.levelBar setProgress:progress animated:YES];
                                                                                                                 [self incrementPoints];
                                                                                                                 if (levelup){
                                                                                                                     self.levelLabel.text = [NSString stringWithFormat:@"Level %ld", (long)[currentStudent getLvl]];
                                                                                                                     [UIView animateWithDuration:.6 animations:^{
                                                                                                                         [self showLevelView];
                                                                                                                     }];                                                                                                                 }
                                                                                                             }
                                                                                                             completion:^(BOOL finished) {
                                                                                                                 double delayInSeconds = 1.0;
                                                                                                                 if (levelup) delayInSeconds = 2.6;
                                                                                                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                                                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                                                                     [UIView animateWithDuration:.5
                                                                                                                                      animations:^{
                                                                                                                                          self.nameLabel.hidden=YES;
                                                                                                                                          self.pointsLabel.hidden=YES;
                                                                                                                                          self.levelLabel.hidden=YES;
                                                                                                                                          self.sackImage.hidden=YES;
                                                                                                                                          self.levelBar.hidden=YES;
                                                                                                                                      }
                                                                                                                                      completion:^(BOOL finished) {
                                                                                                                                          self.categoryPicker.hidden = NO;
                                                                                                                                          isStamping = NO;
                                                                                                                                      }
                                                                                                                      ];
                                                                                                                 });
                                                                                                             }
                                                                                             ];
                                                                                        }
                                                                        ];
                                                                   }
                                                   ];
                                              }
                              ];
                         });
                     }
     ];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return reinforcerData.count;
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    reinforcer *tmpReinforcer = [reinforcerData objectAtIndex:row];
    return [tmpReinforcer getName];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    [self setReinforcerName];
}


- (IBAction)homeClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)classJarClicked:(id)sender {
    [self performSegueWithIdentifier:@"award_to_class_jar" sender:nil];
}


- (IBAction)marketClicked:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    
    ClassJarViewController *cjvc = [storyboard instantiateViewControllerWithIdentifier:@"ClassJarViewController"];
    MarketViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"MarketViewController"];
    [self.navigationController pushViewController:cjvc animated:NO];
    [self.navigationController pushViewController:mvc animated:NO];
}


- (IBAction)swipeDown:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    StudentsTableViewController *stvc = [storyboard instantiateViewControllerWithIdentifier:@"StudentsTableViewController"];
    [self.navigationController pushViewController:stvc animated:NO];
}


- (IBAction)unwindToAward:(UIStoryboardSegue *)unwindSegue {
    
}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}

@end
