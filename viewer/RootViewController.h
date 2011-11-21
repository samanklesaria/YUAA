//
//  RootViewController.h
//  ipad viewer
//
//  Created by Sam Anklesaria on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Grapher.h"
#import "StatTableDelegate.h"

@class DetailViewController;

@interface RootViewController : UITableViewController <ControllerShower> {
    StatTableDelegate *stDelegate;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
