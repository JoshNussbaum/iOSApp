//
//  AppDelegate.h
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ConnectionHandlerDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

