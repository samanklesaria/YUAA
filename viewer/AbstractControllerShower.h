//
//  ControllerShower.h
//  viewer
//
//  Created by Sam Anklesaria on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol AbstractControllerShower <NSObject>
- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title;
- (void)hideController;
@end