//
//  baseTextField.h
//  Classroom Hero
//
//  Created by Josh on 7/24/15.
//  Copyright (c) 2015 Josh Nussbaum. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol baseTextField <NSObject>

-(NSString *)validate;

@end


@interface baseTextField : UITextField

-(id)init;


@end