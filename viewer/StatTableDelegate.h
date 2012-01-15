//
//  StatTableDelegate.h
//  viewer
//
//  Created by Sam Anklesaria on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Orientation.h"
#import "PicViewController.h"
#import "ControllerShower.h"


@interface StatTableDelegate : NSObject  <UITableViewDataSource, UITableViewDelegate> {
    id <ControllerShower> shower;
    Orientation *orientation;
}

@property (retain) id  <ControllerShower> shower;

@end
