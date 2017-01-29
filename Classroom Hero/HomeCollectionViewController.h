//
//  HomeCollectionViewController.h
//  Classroom Hero
//
//  Created by Josh Nussbaum on 1/28/17.
//  Copyright © 2017 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@interface HomeCollectionViewController : UICollectionViewController <ConnectionHandlerDelegate>




- (IBAction)selectClicked:(id)sender;

- (IBAction)attendanceClicked:(id)sender;
- (IBAction)marketClicked:(id)sender;
- (IBAction)jarClicked:(id)sender;
- (IBAction)addPointsClicked:(id)sender;
- (IBAction)subtractPointsClicked:(id)sender;

@end
