//
//  ClassJarViewController.m
//  Classroom Hero
//
//  Created by Josh on 9/2/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import "ClassJarViewController.h"
#import "DatabaseHandler.h"
#import "Utilities.h"
#import "MBProgressHUD.h"
#import "StudentsTableViewController.h"

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

    double currentPoints;
    bool isStamping;
}

@property UIImageView *jarCoins;

@end

@implementation ClassJarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [user getInstance];
    webHandler = [[ConnectionHandler alloc]initWithDelegate:self];
    currentClassJar = [[DatabaseHandler getSharedInstance] getClassJar:[currentUser.currentClass getId]];
    
    [currentClassJar printJar];
    if (!currentClassJar){
        self.addJarButton.hidden = NO;
        self.addJarButton.enabled = YES;
    }
    else {
        self.addJarButton.hidden = YES;
        self.addJarButton.enabled = NO;
    }
    [self displayClassJar];
    
    self.appKey = snowshoe_app_key ;
    self.appSecret = snowshoe_app_secret;
    
    if (!currentClassJar){
        
        self.stepper.enabled = NO;
        self.classJarName.text = @"Add  a  jar  above";
    }
    else {
        self.stepper.enabled = YES;
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

-(void)viewWillAppear:(BOOL)animated{
    currentUser = [user getInstance];
    
    UIImage *image = [UIImage imageNamed:@"jar_progress_coins.png"];
    
    self.jarCoins = [[UIImageView alloc] initWithImage:image];
    self.jarCoins.layer.zPosition = -1;
    self.jarCoins.frame = CGRectMake(194, 840, 381, 0);
    self.jarCoins.contentMode = UIViewContentModeTop;
    self.jarCoins.clipsToBounds = YES;
    [self.view addSubview:self.jarCoins];
    
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
    CGRect finalFrame = CGRectMake(194, 840, 381, newProg);
    [UIView animateWithDuration:0.0 animations:^{
        self.jarCoins.frame = finalFrame;
        
    }];
    
}

- (void) activityStart :(NSString *)message {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    [hud show:YES];
    
}
- (IBAction)editJarClicked:(id)sender {
    if (currentClassJar){
        [Utilities editAlertTextWithtitle:@"Edit Class Jar" message:nil cancel:nil done:nil delete:NO textfields:@[[currentClassJar getName], [NSString stringWithFormat:@"%ld", (long)[currentClassJar getTotal]]] tag:2 view:self];
    }
}

- (IBAction)addJarClicked:(id)sender {
    [Utilities editAlertTextWithtitle:@"Add Class Jar" message:nil cancel:nil done:nil delete:NO textfields:@[@"Class jar name", @"Class jar total"] tag:1 view:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    newClassJarName = [alertView textFieldAtIndex:0].text;
    newClassJarTotal = [alertView textFieldAtIndex:1].text;
    
    
    NSString *errorMessage = [Utilities isInputValid:newClassJarName :@"Class jar Name"];
    
    if (!errorMessage){
        errorMessage = [Utilities isNumeric:newClassJarTotal];
        if (!errorMessage){
            if (alertView.tag == 1){
                [self activityStart:@"Adding class jar..."];
                [webHandler addJar:[currentUser.currentClass getId] :newClassJarName :newClassJarTotal.integerValue];

            }
            else if (alertView.tag == 2){
                [self activityStart:@"Editing class jar..."];
                [webHandler editJar:[currentUser.currentClass getId] :newClassJarName :newClassJarTotal.integerValue];
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
    if (data == nil){
        [hud hide:YES];
        [Utilities alertStatusNoConnection];
        return;
    }
    if (type == ADD_JAR){
        NSInteger jarId = [[data objectForKey:@"id"] integerValue];
        currentClassJar = [[classjar alloc] initWithid:jarId cid:[currentUser.currentClass getId] name:newClassJarName progress:0 total:newClassJarTotal.integerValue];
        [[DatabaseHandler getSharedInstance] addClassJar:(currentClassJar)];
        [self displayClassJar];	
        self.addJarButton.enabled = NO;
        self.addJarButton.hidden = YES;
        [hud hide:YES];
        self.stepper.enabled = YES;

    }
    else if (type == EDIT_JAR){
        [currentClassJar setName:newClassJarName];
        [currentClassJar setTotal:newClassJarTotal.integerValue];
        [[DatabaseHandler getSharedInstance] updateClassJar:currentClassJar];
        [self displayClassJar];
        [hud hide:YES];
    }
    else if (type == ADD_TO_JAR){
        [currentClassJar updateJar:currentPoints];
        [[DatabaseHandler getSharedInstance]updateClassJar:currentClassJar];
        [self addCoins];
    }
}


-(void)stampResultDidChange:(NSString *)stampResult{
    currentUser = [user getInstance];
    if (!isStamping && currentClassJar){
        NSData *jsonData = [stampResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (resultObject != NULL) {
            if ([resultObject objectForKey:@"stamp"] != nil){
                NSString *stampSerial = [[resultObject objectForKey:@"stamp"] objectForKey:@"serial"];
                NSLog(@"We stamped with -> %@", stampSerial);

                if (self.corkImage.hidden == YES){
                    self.stepper.enabled = NO;
                    isStamping = YES;

                    if ([stampSerial isEqualToString:currentUser.serial] && ([currentClassJar getTotal] != 0))
                    {
                        [webHandler addToClassJar:[currentClassJar getId] :currentPoints];

                        /*
                        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys: currentUser.jarName, @"added", nil];
                        
                        [[Countly sharedInstance] recordEvent:@"addToJar" segmentation:dict count:1 sum:currentPoints];
                        */
                        
                    }
                    else {
                        self.stepper.enabled = YES;
                        isStamping = NO;
                    }
                }
                else{
                    AudioServicesPlaySystemSound(jarFull);
                    self.corkImage.hidden = YES;
                    self.corkImage.frame = corkRect;
                    
                    CGRect finalFrame = self.jarCoins.frame;
                    finalFrame.size.height = 0;
                    
                    [UIView animateWithDuration:0 animations:^{
                        self.jarCoins.frame = finalFrame;
                    }];
                    isStamping = NO;
                }
            }
        }
    }
}


-(void)addCoins{
    AudioServicesPlaySystemSound(award);
    self.jarCoins.hidden = NO;
    NSMutableArray *scores = [NSMutableArray array];
    NSInteger newTotal = [currentClassJar getProgress] +currentPoints;
    NSInteger points = [currentClassJar getProgress];
    
    [scores addObject:[NSNumber numberWithInteger:points]];
    [scores addObject:[NSNumber numberWithInteger:newTotal]];
    

    if (newTotal >= [currentClassJar getTotal]) {
        [currentClassJar setProgress:[currentClassJar getTotal]];
    }
    [self coinsFall:scores];
}


-(void)coinsFall:(NSMutableArray*)scores{
    NSInteger score = [[scores objectAtIndex:0]integerValue];
    NSInteger newScore = [[scores objectAtIndex:1]integerValue];
    NSInteger points;
    if (newScore >= [currentClassJar getTotal]) {
        points = [currentClassJar getTotal] - score;
    }
    else {
        points = newScore - score;
    }
    float time = points *.25;
    if (score != newScore)
    {
        score++;
        UIImageView *coin = [[UIImageView alloc] initWithFrame:coinRect];
        coin.image = [UIImage imageNamed:@"teachers_coin.png"];
        coin.alpha=1.0;
        coin.layer.zPosition = -50;
        [self.view addSubview:coin];
        
        [scores replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:score]];
        
        [UIView animateWithDuration:.60
                         animations:^{
                             [coin setFrame:CGRectMake(self.jarImage.frame.origin.x + self.jarImage.frame.size.width/2 - 85, self.jarImage.frame.origin.y+(self.jarImage.frame.size.height-230), self.coinImage.frame.size.width, self.coinImage.frame.size.height)];
                             
                         }
                         completion:^(BOOL finished) {
                             AudioServicesPlaySystemSound(coinShake);
                             
                             coin.alpha=0;
                             coin.frame = coinRect;
                             float prog = (float)score / (float)[currentClassJar getTotal];
                             
                             CGRect finalFrame = self.jarCoins.frame;
                             float newProg;
                             if (prog >= 1.0) {
                                 newProg = -420;
                             }
                             else {
                                 newProg = prog * -420;
                                 
                             }
                             finalFrame.size.height = newProg;
                             
                             [UIView animateWithDuration:time animations:^{
                                 self.jarCoins.frame = CGRectMake(194, 840, 381, newProg);
                             }];
                             
                         }
         ];
        [self performSelector:@selector(coinsFall:) withObject:scores afterDelay:0.2 ];
    }
    
    else if ([currentClassJar getProgress] >= [currentClassJar getTotal]){
        [self jarFull];
    }
    else {
        self.stepper.enabled = YES;
        isStamping = NO;
    }
}

-(void)jarFull{
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [currentClassJar setProgress:0];
        self.stepper.enabled = YES;
        isStamping = NO;
        
        self.corkImage.hidden = NO;
        
        [UIView animateWithDuration:1.2
                         animations:^{
                             [self.corkImage setFrame:CGRectMake(self.corkImage.frame.origin.x, self.corkImage.frame.origin.y+140, self.corkImage.frame.size.width, self.corkImage.frame.size.height)];
                             
                         }
                         completion:^(BOOL finished) {
                             AudioServicesPlaySystemSound(cork);
                             isStamping = NO;
                         }
         ];
    });
    
}


- (void)displayClassJar{
    self.classJarName.text = [currentClassJar getName];
}



- (IBAction)homeClicked:(id)sender {
    [self performSegueWithIdentifier:@"class_jar_to_home" sender:self];
}


- (IBAction)awardClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)marketClicked:(id)sender {
    [self performSegueWithIdentifier:@"class_jar_to_market" sender:nil];
}


- (IBAction)unwindToClassJar:(UIStoryboardSegue *)unwindSegue
{
    
}


- (IBAction)valueChanged:(id)sender {
    if (!isStamping && currentClassJar) {
        self.pointsLabel.text = [NSString stringWithFormat:@"+ %.f",self.stepper.value];
        currentPoints = [(UIStepper*)sender value];
    }
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
@end
