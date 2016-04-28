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
#import "Flurry.h"


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
    
    float jarImageX;
    float jarImageY;
    float jarImageWidth;
    float jarImageHeight;
    float jarCoinsX;
    float jarCoinsY;
    float jarCoinsWidth;
}

@property UIImageView *jarCoins;

@end


@implementation ClassJarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    coinsShowing = NO;
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    currentClassJar = [[DatabaseHandler getSharedInstance] getClassJar:[currentUser.currentClass getId]];
    
    if (!currentClassJar){
        self.addJarButton.hidden = NO;
        self.addJarButton.enabled = YES;
        self.editJarButton.hidden = YES;
        self.stepper.hidden = YES;
        self.pointsLabel.hidden = YES;
    }
    else {
        self.addJarButton.hidden = YES;
        self.addJarButton.enabled = NO;
        self.editJarButton.hidden = NO;
        self.stepper.hidden = NO;
        self.pointsLabel.hidden = NO;
    }
    [self displayClassJar];
    self.appKey = snowshoe_app_key ;
    self.appSecret = snowshoe_app_secret;
    
    
    NSArray *menuButtons = @[self.homeButton, self.awardButton, self.jarButton, self.marketButton];
    for (UIButton *button in menuButtons){
        button.exclusiveTouch = YES;
    }
    
    award = [Utilities getAwardSound];
    cork = [Utilities getCorkSound];
    coinShake = [Utilities getCoinShakeSound];
    fail = [Utilities getFailSound];
    jarFull = [Utilities getAchievementSound];
    
    coinRect = self.coinImage.frame;
    corkRect = self.corkImage.frame;
    
    currentPoints = 1;

}


- (void)viewDidAppear:(BOOL)animated{
    if (!coinsShowing){
        coinsShowing = YES;
        UIImage *image = [UIImage imageNamed:@"jar_progress_coins.png"];
        
        jarImageX = self.jarImage.frame.origin.x;
        jarImageY = self.jarImage.frame.origin.y;
        jarImageWidth = self.jarImage.frame.size.width;
        jarImageHeight = self.jarImage.frame.size.height;
        
        jarCoinsWidth = jarImageX + jarImageWidth/2;
        
        
        jarCoinsX = (jarImageX + jarImageWidth/2) - jarCoinsWidth/2;
        jarCoinsY = jarImageHeight + jarImageY - 50;
        
        self.jarCoins = [[UIImageView alloc] initWithImage:image];
        self.jarCoins.layer.zPosition = -1;
        self.jarCoins.frame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, 0);
        self.jarCoins.contentMode = UIViewContentModeTop;
        self.jarCoins.clipsToBounds = YES;
        [self.view addSubview:self.jarCoins];
        
        self.jarCoins.frame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, 0);
        
        self.corkImage.hidden = YES;
        float prog = (float)[currentClassJar getProgress] / (float)[currentClassJar getTotal];
        
        float newProg;
        if ([currentClassJar getProgress] == 0){
            self.jarCoins.hidden = YES;
            newProg = 0;
        }
        else {
            newProg = prog * (-420);
            
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


- (IBAction)editJarClicked:(id)sender {
    if (currentClassJar){
        [Utilities editTextWithtitle:@"Edit Class Jar" message:nil cancel:@"Cancel" done:nil delete:NO textfields:@[[currentClassJar getName], [NSString stringWithFormat:@"%ld", (long)[currentClassJar getTotal]]] tag:2 view:self];
    }
}


- (IBAction)addJarClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Add Class Jar" message:nil cancel:nil done:nil delete:NO textfields:@[@"Class jar name", @"Class jar total"] tag:1 view:self];
}


- (void)stampResultDidChange:(NSString *)stampResult{
    if (!isStamping && currentClassJar){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            isStamping = YES;
            if ([resultObject objectForKey:@"stamp"] != nil){
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                self.stepper.enabled = NO;
                
                if ([stampSerial isEqualToString:currentUser.serial] && ([currentClassJar getTotal] != 0))
                {
                    [webHandler addToClassJar:[currentClassJar getId] :currentPoints :[currentUser.currentClass getId]];
                }
                else {
                    AudioServicesPlaySystemSound(fail);
                    self.stepper.enabled = YES;
                    isStamping = NO;
                }
              
            }
            else {
                isStamping = NO;
            }
        }
    }
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
    
    if (!errorMessage){
        errorMessage = [Utilities isNumeric:newClassJarTotal];
        if (!errorMessage){
            if (alertView.tag == 1){
                [self activityStart:@"Adding class jar..."];
                [webHandler addJar:[currentUser.currentClass getId] :newClassJarName :newClassJarTotal.integerValue];

            }
            else if (alertView.tag == 2){
                [self activityStart:@"Editing class jar..."];
                if (newClassJarTotal.integerValue <= [currentClassJar getProgress]){
                    [Utilities alertStatusWithTitle:@"Warning" message:@"Your new total is less than your current progress. Proceeding will reset your progress to 0" cancel:@"Cancel" otherTitles:@[@"Proceed"] tag:3 view:self];

                }
                else{
                    [webHandler editJar:[currentClassJar getId] :newClassJarName :newClassJarTotal.integerValue :[currentClassJar getProgress]];
                }
            }
            else if (alertView.tag == 3){
                [webHandler editJar:[currentClassJar getId] :newClassJarName :newClassJarTotal.integerValue :0];
            }
            
        }
        else {
            [Utilities alertStatusWithTitle:@"Error adding class jar" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
        }
        
    }
    else {
        [Utilities alertStatusWithTitle:@"Error adding class jar" message:errorMessage cancel:nil otherTitles:nil tag:0 view:nil];
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
            self.addJarButton.enabled = NO;
            self.addJarButton.hidden = YES;
            self.stepper.enabled = YES;
            self.editJarButton.hidden = NO;
            self.stepper.hidden = NO;
            self.pointsLabel.hidden = NO;
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add Jar - Jar View" withParameters:params];
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
                float newProg;
                newProg = prog * -420;
                
                finalFrame.size.height = newProg;
                
                [UIView animateWithDuration:0 animations:^{
                    self.jarCoins.frame = CGRectMake(jarCoinsX, jarCoinsY, jarCoinsWidth, newProg);
                }];
            }


        
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Edit Jar" withParameters:params];

        }
        else if (type == ADD_TO_JAR){
            tmpProgress = [currentClassJar getProgress];
            [currentClassJar updateJar:currentPoints];
            [[DatabaseHandler getSharedInstance]updateClassJar:currentClassJar];
            [self addCoins];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: [currentClassJar getName], @"Jar Name", [NSString stringWithFormat:@"%ld", (long)[currentClassJar getId]], @"Jar ID", [NSString stringWithFormat:@"%ld", (long)currentPoints], @"Points", [NSString stringWithFormat:@"%ld", (long)currentUser.id], @"Teacher ID", [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName], @"Teacher Name", [NSString stringWithFormat:@"%ld", (long)[currentUser.currentClass getId]], @"Class ID", nil];
            
            [Flurry logEvent:@"Add To Jar" withParameters:params];
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
        coin.layer.zPosition = -50;
        [self.view addSubview:coin];
        
        [scores replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:pointsEarned]];
        
        [UIView animateWithDuration:.60
                         animations:^{
                             [coin setFrame:CGRectMake(self.jarImage.frame.origin.x + self.jarImage.frame.size.width/2 - 85, self.jarImage.frame.origin.y+(self.jarImage.frame.size.height-230), self.coinImage.frame.size.width, self.coinImage.frame.size.height)];
                             
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
                             float newProg;
                             if (prog >= 1.0 || prog == 0) {
                                 newProg = -420;
                             }
                             else {
                                 newProg = prog * -420;
                                 
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
            [self jarFull];
        }
        self.stepper.enabled = YES;
        isStamping = NO;
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
    
    CGRect finalFrame = self.jarCoins.frame;
    float newProg;
    newProg = prog * -420;

    finalFrame.size.height = newProg;
    
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
                             [self.corkImage setFrame:CGRectMake(self.corkImage.frame.origin.x, self.corkImage.frame.origin.y+140, self.corkImage.frame.size.width, self.corkImage.frame.size.height)];
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
