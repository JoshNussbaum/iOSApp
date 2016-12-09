//
//  ClassJarViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//




// Set up jar Coins right below the jar, and
// and just do the negative multiply thing with it starting at
// 0 and just alter the height and have everything else adjust dyanmically
// with autolayout



#import "ClassJarViewController.h"
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "StudentsTableViewController.h"
#import <Google/Analytics.h>


@interface ClassJarViewController (){
    user *currentUser;
    classjar *currentClassJar;
    ConnectionHandler *webHandler;
    CGRect coinRect;
    CGRect corkRect;
    SystemSoundID award;
    SystemSoundID cork;
    SystemSoundID coinShake;
    SystemSoundID fail;
    SystemSoundID jarFull;
    
    MBProgressHUD *hud;
    NSString *newClassJarName;
    NSString *newClassJarTotal;
    NSInteger tmpProgress;

    double currentPoints;
    BOOL isStamping;
    BOOL coinsShowing;
    BOOL isJarFull;
    
    float jarImageX;
    float jarImageY;
    float jarImageWidth;
    
    CGFloat jarCoinsHeight;
    CGFloat jarCoinsX;
    CGFloat jarCoinsY;
    CGFloat jarCoinsWidth;
}

@property UIImageView *jarCoins;

@end


@implementation ClassJarViewController


- (void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Class Jar"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    coinsShowing = NO;
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    currentClassJar = [[DatabaseHandler getSharedInstance] getClassJar:[currentUser.currentClass getId]];
    [Utilities makeRoundedButton:self.addPointsButton :nil];
    
    if (!currentClassJar){
        self.classJarProgressLabel.hidden = YES;
        [self.addJarButton setTitle:@"Add" forState:UIControlStateNormal];
        self.stepper.hidden = YES;
        self.pointsLabel.hidden = YES;
    }
    else {
        self.classJarProgressLabel.hidden = NO;
        self.classJarProgressLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)[currentClassJar getProgress], (long)[currentClassJar getTotal]];
        [self.addJarButton setTitle:@"Edit" forState:UIControlStateNormal];
        self.stepper.hidden = NO;
        self.pointsLabel.hidden = NO;
    }
    [self displayClassJar];
    
    NSArray *menuButtons = @[self.homeButton, self.awardButton, self.jarButton, self.marketButton];
    for (UIButton *button in menuButtons){
        button.exclusiveTouch = YES;
    }
    
    award = [Utilities getAwardSound];
    cork = [Utilities getCorkSound];
    coinShake = [Utilities getCoinShakeSound];
    fail = [Utilities getFailSound];
    jarFull = [Utilities getAchievementSound];
    
    self.classJarName.layer.zPosition = -4;
    self.classJarProgressLabel.layer.zPosition = -4;
    self.backLidImage.layer.zPosition = -5;
    
    currentPoints = 1;
    isJarFull = NO;

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (self.view.frame.size.height == 1366) {
        NSArray *menuButtons = @[self.homeButton, self.jarButton, self.marketButton, self.awardButton];
        
        [Utilities setFontSizeWithbuttons:menuButtons font:@"GillSans-Bold" size:menuItemFontSize];
        
        self.backLidImage.frame = CGRectMake(225, 328, 598, 920.0);
        
        self.classJarName.frame = CGRectMake(21, 178, 982, 76);
        
        self.classJarProgressLabel.frame = CGRectMake(399, 265, 226, 54);
        
    }
}


- (void)viewDidAppear:(BOOL)animated{
    if (!coinsShowing){
        coinsShowing = YES;
        UIImage *image = [UIImage imageNamed:@"jar_progress_coins.png"];
        
        jarImageX = self.jarImage.frame.origin.x;
        jarImageY = self.jarImage.frame.origin.y;
        jarImageWidth = self.jarImage.frame.size.width;
        
        jarCoinsHeight = self.jarCoinsImage.frame.size.height - 10;
        jarCoinsWidth = self.jarCoinsImage.frame.size.width;
        
        
        jarCoinsX = self.jarCoinsImage.frame.origin.x;
        jarCoinsY = self.jarCoinsImage.frame.origin.y;
        jarCoinsY += (jarCoinsHeight + 2);
        
        self.jarCoins = [[UIImageView alloc] initWithImage:image];
        self.jarCoins.layer.zPosition = -1;
        self.jarCoins.frame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, 0);
        self.jarCoins.clipsToBounds = YES;
        if (self.view.frame.size.height == 1366) {
            self.jarCoins.contentMode = UIViewContentModeScaleToFill;
        }
        else {
            self.jarCoins.contentMode = UIViewContentModeTop;
        }

        [self.view addSubview:self.jarCoins];
        
        
        self.corkImage.hidden = YES;
        self.corkImage.layer.zPosition = -1;
        float prog = (float)[currentClassJar getProgress] / (float)[currentClassJar getTotal];
        
        CGFloat newProg;
        if ([currentClassJar getProgress] == 0){
            self.jarCoins.hidden = YES;
            newProg = 0;
        }
        else {
            newProg = prog * -(jarCoinsHeight);
            
        }
        CGRect finalFrame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, newProg);
        [UIView animateWithDuration:0.5 animations:^{
            self.jarCoins.frame = finalFrame;
            
        }];
    }
    self.awardButton.enabled = YES;
    self.awardIconButton.enabled = YES;
    self.homeButton.enabled = YES;
    self.homeIconButton.enabled = YES;
    self.marketButton.enabled = YES;
    self.marketIconButton.enabled = YES;
    
    coinRect = self.coinImage.frame;
    corkRect = self.corkImage.frame;
    
    CGRect rect = self.coinImage.frame;
}


- (IBAction)unwindToClassJar:(UIStoryboardSegue *)unwindSegue{
    
}


- (IBAction)valueChanged:(id)sender {
    
    if (!isStamping && currentClassJar) {
        self.pointsLabel.text = [NSString stringWithFormat:@"+ %.f",self.stepper.value];
        currentPoints = [(UIStepper*)sender value];
    }
}


- (IBAction)homeClicked:(id)sender {
    self.homeButton.enabled = NO;
    self.homeIconButton.enabled = NO;
    [self performSegueWithIdentifier:@"class_jar_to_home" sender:self];
}


- (IBAction)awardClicked:(id)sender {
    self.awardButton.enabled = NO;
    self.awardIconButton.enabled = NO;
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)marketClicked:(id)sender {
    self.marketButton.enabled = NO;
    self.marketIconButton.enabled = NO;
    [self performSegueWithIdentifier:@"class_jar_to_market" sender:nil];
}


- (IBAction)studentListClicked:(id)sender {
    UIStoryboard *storyboard = self.storyboard;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    StudentsTableViewController *stvc = [storyboard instantiateViewControllerWithIdentifier:@"StudentsTableViewController"];
    [self.navigationController pushViewController:stvc animated:NO];
}


- (IBAction)addJarClicked:(id)sender {
    if (!currentClassJar){
        [Utilities editAlertTextWithtitle:@"Add Class Jar" message:nil cancel:nil done:nil delete:NO textfields:@[@"Class jar name", @"Class jar total"] tag:1 view:self];
    }
    else {
        [Utilities editTextWithtitle:@"Edit Class Jar" message:nil cancel:@"Cancel" done:nil delete:NO textfields:@[[currentClassJar getName], [NSString stringWithFormat:@"%ld", (long)[currentClassJar getTotal]]] tag:2 view:self];
    }
}


- (IBAction)addPointsClicked:(id)sender{
    if (currentClassJar != nil){
        if (!isStamping){
            if (!isJarFull){
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[currentUser fullName]
                                                                      action:@"Add Points (Class Jar)"
                                                                       label:[currentClassJar getName]
                                                                       value:@1] build]];
                isStamping = YES;
                [webHandler addToClassJar:[currentClassJar getId] :currentPoints :[currentUser.currentClass getId]];
            }
        }
    }
    else {
        [Utilities alertStatusWithTitle:@"Add a class jar above" message:nil cancel:nil otherTitles:nil tag:0 view:self];
    }
}


- (void)hideJar{
    AudioServicesPlaySystemSound(jarFull);
    self.corkImage.hidden = YES;
    self.corkImage.frame = corkRect;
    
    CGRect finalFrame = self.jarCoins.frame;
    finalFrame.size.height = 0;
    
    [UIView animateWithDuration:0 animations:^{
        self.jarCoins.frame = finalFrame;
    }];
    
    isStamping = NO;
    isJarFull = NO;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    if (alertView.tag !=3 ){
        newClassJarName = [alertView textFieldAtIndex:0].text;
        newClassJarTotal = [alertView textFieldAtIndex:1].text;
    }
   
    NSString *errorMessage = [Utilities isInputValid:newClassJarName :@"Class jar name"];
    
    if (alertView.tag == 1){
        if (!errorMessage){
            errorMessage = [Utilities isNumeric:newClassJarTotal];
            if (!errorMessage){
                
                [self activityStart:@"Adding class jar..."];
                [webHandler addJar:[currentUser.currentClass getId] :newClassJarName :newClassJarTotal.integerValue];
                
            }
            else {
                [Utilities editAlertTextWithtitle:@"Error adding class jar" message:errorMessage cancel:nil done:nil delete:NO textfields:@[@"Class jar name", @"Class jar total"] tag:1 view:self];
                
            }
            
        }
        else {
            [Utilities editAlertTextWithtitle:@"Error adding class jar" message:errorMessage cancel:nil done:nil delete:NO textfields:@[@"Class jar name", @"Class jar total"] tag:1 view:self];
        }

        
    }
    else if (alertView.tag == 2){
        if (!errorMessage){
            errorMessage = [Utilities isNumeric:newClassJarTotal];
            if (!errorMessage){
                [self activityStart:@"Editing class jar..."];
                if (newClassJarTotal.integerValue <= [currentClassJar getProgress]){
                    [Utilities alertStatusWithTitle:@"Warning" message:@"Your new total is less than your current progress. Proceeding will reset your progress to 0" cancel:@"Cancel" otherTitles:@[@"Proceed"] tag:3 view:self];
                }
                else{
                    [webHandler editJar:[currentClassJar getId] :newClassJarName :newClassJarTotal.integerValue :[currentClassJar getProgress]];
                }
            }
            
            else {
                [Utilities editTextWithtitle:@"Edit Class Jar" message:errorMessage cancel:@"Cancel" done:nil delete:NO textfields:@[[currentClassJar getName], [NSString stringWithFormat:@"%ld", (long)[currentClassJar getTotal]]] tag:2 view:self];
                
            }
        }
        else {
            [Utilities editTextWithtitle:@"Edit Class Jar" message:errorMessage cancel:@"Cancel" done:nil delete:NO textfields:@[[currentClassJar getName], [NSString stringWithFormat:@"%ld", (long)[currentClassJar getTotal]]] tag:2 view:self];

        }
    }
    
    else if (alertView.tag == 3){
        [webHandler editJar:[currentClassJar getId] :newClassJarName :newClassJarTotal.integerValue :0];
    }
    
}
	

- (void)dataReady:(NSDictionary *)data :(NSInteger)type{
    [hud hide:YES];
    
    if (data == nil){
        [Utilities alertStatusNoConnection];
        isStamping = NO;
        return;
    }
    NSNumber * successNumber = (NSNumber *)[data objectForKey: @"success"];

    if([successNumber boolValue] == YES)
    {
        if (type == ADD_JAR){
            NSInteger jarId = [[data objectForKey:@"id"] integerValue];
            currentClassJar = [[classjar alloc] initWithid:jarId cid:[currentUser.currentClass getId] name:newClassJarName progress:0 total:newClassJarTotal.integerValue];
            [[DatabaseHandler getSharedInstance] addClassJar:(currentClassJar)];
            [self displayClassJar];
            [self.addJarButton setTitle:@"Edit" forState:UIControlStateNormal];
            self.stepper.enabled = YES;
            self.stepper.hidden = NO;
            self.pointsLabel.hidden = NO;
            self.classJarProgressLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)[currentClassJar getProgress], (long)[currentClassJar getTotal]];
            self.classJarProgressLabel.hidden = NO;
            
        }
        else if (type == EDIT_JAR){
            self.classJarName.text = newClassJarName;
            
            [currentClassJar setName:newClassJarName];
            [currentClassJar setTotal:newClassJarTotal.integerValue];
            [[DatabaseHandler getSharedInstance] updateClassJar:currentClassJar];
            if (newClassJarTotal.integerValue <= [currentClassJar getProgress]){
                [currentClassJar setProgress:0];
                CGRect finalFrame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, 0);
                [UIView animateWithDuration:0.5 animations:^{
                    self.jarCoins.frame = finalFrame;
                    
                }];
            }
            else {
                float prog = (float)([currentClassJar getProgress]) / (float)[currentClassJar getTotal];
                
                
                CGRect finalFrame = self.jarCoins.frame;
                CGFloat newProg;
                newProg = prog * -(jarCoinsHeight );
                
                finalFrame.size.height = newProg;
                
                [UIView animateWithDuration:0 animations:^{
                    self.jarCoins.frame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, newProg);
                }];
            }
            self.classJarProgressLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)[currentClassJar getProgress], (long)[currentClassJar getTotal]];

        }
        else if (type == ADD_TO_JAR){
            tmpProgress = [currentClassJar getProgress];
            [currentClassJar updateJar:currentPoints];
            [[DatabaseHandler getSharedInstance]updateClassJar:currentClassJar];
            [self addCoins];
            [currentUser.currentClass addPoints:1];
            [[DatabaseHandler getSharedInstance]editClass:currentUser.currentClass];
        }
    }
    else {
        NSString *errorMessage;
        NSString *message = [data objectForKey:@"message"];
        if (type == ADD_JAR) {
            errorMessage = @"Error adding jar";
        }
        else if (type == EDIT_JAR){
            errorMessage = @"Error editing jar";
        }
        else if (type == ADD_TO_JAR){
            errorMessage = @"Error adding to jar";
        }
        [Utilities alertStatusWithTitle:errorMessage message:message cancel:nil otherTitles:nil tag:0 view:self];
        isStamping = NO;
    }

}


- (void)addCoins{
    AudioServicesPlaySystemSound(award);
    self.jarCoins.hidden = NO;
    NSInteger newTotal = [currentClassJar getProgress];
    NSMutableArray *scores = [NSMutableArray array];
    NSInteger points = currentPoints;
    
    if ([currentClassJar getProgress] == 0){
        if ([currentClassJar getTotal] == tmpProgress){
            points = tmpProgress;
        }
        else{
            points = [currentClassJar getTotal] - tmpProgress;
        }
    }
    [scores addObject:[NSNumber numberWithInteger:points]];
    [scores addObject:[NSNumber numberWithInteger:newTotal]];
    self.addPointsButton.enabled = NO;
    [self coinsFall:scores];
}


- (void)coinsFall:(NSMutableArray*)scores{
    NSInteger pointsEarned = [[scores objectAtIndex:0]integerValue];
    NSInteger newScore = [[scores objectAtIndex:1]integerValue];

    float time = pointsEarned * .25;
    if (pointsEarned != 0)
    {
        pointsEarned--;
        UIImageView *coin = [[UIImageView alloc] initWithFrame:coinRect];
        coin.image = [UIImage imageNamed:@"coin.png"];
        coin.alpha=1.0;
        coin.layer.zPosition = -3;
        [self.view addSubview:coin];
        
        [scores replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:pointsEarned]];
        
        [UIView animateWithDuration:.60
                         animations:^{
                             if (IS_IPAD_PRO){
                                 [coin setFrame:CGRectMake(self.jarImage.frame.origin.x + self.jarImage.frame.size.width/2 - 110, self.jarImage.frame.origin.y+(self.jarImage.frame.size.height-270), self.coinImage.frame.size.width, self.coinImage.frame.size.height)];
                             }
                             else {
                                 [coin setFrame:CGRectMake(self.jarImage.frame.origin.x + self.jarImage.frame.size.width/2 - 90, self.jarImage.frame.origin.y+(self.jarImage.frame.size.height-230), self.coinImage.frame.size.width, self.coinImage.frame.size.height)];

                             }
                         }
                         completion:^(BOOL finished) {
                             AudioServicesPlaySystemSound(coinShake);
                             
                             coin.alpha=0;
                             coin.frame = coinRect;
                             float prog;
                             if ([currentClassJar getProgress] == 0){
                                 prog = (float)([currentClassJar getTotal] - pointsEarned);
                             }
                             else{
                                 prog = (float)([currentClassJar getProgress]-pointsEarned) / (float)[currentClassJar getTotal];
                             }
                             
                             CGRect finalFrame = self.jarCoins.frame;
                             CGFloat newProg;
                             if (prog >= 1.0 || prog == 0) {
                                 newProg = -(jarCoinsHeight );
                             }
                             else {
                                 newProg = prog * -(jarCoinsHeight);
                                 
                             }
                             finalFrame.size.height = newProg;
                             
                             [UIView animateWithDuration:time animations:^{
                                 self.jarCoins.frame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, newProg);
                             }];

                         }
         ];
        [self performSelector:@selector(coinsFall:) withObject:scores afterDelay:0.2];
        return;
    }
    else {
        if ([currentClassJar getProgress] == 0){
            isJarFull = YES;
            self.addPointsButton.enabled = NO;
            [self jarFull];
        }
        self.stepper.enabled = YES;
        isStamping = NO;
        self.addPointsButton.enabled = YES;
        self.classJarProgressLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)[currentClassJar getProgress], (long)[currentClassJar getTotal]];

    }
}


- (void)displayJarCoins:(NSInteger)pointsEarned :(NSInteger)newScore{
    float time = pointsEarned *.25;
    float prog;
    if ([currentClassJar getProgress] == 0){
        prog = (float)([currentClassJar getTotal] - pointsEarned);
    }
    else{
        prog = (float)([currentClassJar getProgress]-pointsEarned) / (float)[currentClassJar getTotal];
    }
    
    //CGRect finalFrame = self.jarCoins.frame;
    CGFloat newProg;
    newProg = prog * -(jarCoinsHeight);

    //finalFrame.size.height = newProg;
    
    [UIView animateWithDuration:time animations:^{
        self.jarCoins.frame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, newProg);
    }];
}


- (void)jarFull{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.stepper.enabled = YES;
        
        self.corkImage.hidden = NO;
        
        [UIView animateWithDuration:1.2
                         animations:^{
                             [self.corkImage setFrame:CGRectMake(self.corkImage.frame.origin.x-10, jarImageY-80, self.corkImage.frame.size.width, self.corkImage.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             AudioServicesPlaySystemSound(cork);
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 AudioServicesPlaySystemSound(jarFull);
                                 self.corkImage.hidden = YES;
                                 self.corkImage.frame = corkRect;
                                 
                                 CGRect finalFrame = self.jarCoins.frame;
                                 finalFrame.size.height = 0;
                                 
                                 [UIView animateWithDuration:0 animations:^{
                                     self.jarCoins.frame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, 0);
                                 }];
                                 isStamping = NO;
                                 isJarFull = NO;
                                 self.addPointsButton.enabled = YES;
                                 self.classJarProgressLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)[currentClassJar getProgress], (long)[currentClassJar getTotal]];
                             });
                         }
         ];
    });
}


- (void)displayClassJar{

    self.classJarName.text = [currentClassJar getName];
    if (currentClassJar == nil){
        self.stepper.enabled = NO;
        self.classJarName.text = @"Add a jar above";
    }
    else {
        self.stepper.enabled = YES;
        if ([currentClassJar getProgress] > [currentClassJar getTotal]){
            [currentClassJar setProgress:0];
        }
    }

}


- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
}


@end
