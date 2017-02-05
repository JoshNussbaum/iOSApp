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

- (IBAction)profileClicked:(id)sender;
- (IBAction)classListClicked:(id)sender;

@end
