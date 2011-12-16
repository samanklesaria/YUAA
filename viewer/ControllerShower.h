//
//  ControllerShower.h
//  viewer
//
//  Created by Sam Anklesaria on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol ControllerShower <NSObject>
- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title;
@end