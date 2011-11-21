//
//  StatTableDelegate.h
//  viewer
//
//  Created by Sam Anklesaria on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Orientation.h"

@protocol ControllerShower <NSObject>
- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title;
@end


@interface StatTableDelegate : NSObject  <UITableViewDataSource, UITableViewDelegate> {
    id <ControllerShower> shower;
    Orientation *orientation;
}

@property (retain) id  <ControllerShower> shower;
@end
