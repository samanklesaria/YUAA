//
//  StatView.h
//  viewer
//
//  Created by Sam Anklesaria on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControllerShower.h"
#import "FlightData.h"
#import "AbstractControllerShower.h"

@interface StatViewController : UIViewController <UITableViewDataSource, AbstractControllerShower> {
    IBOutlet UITableView *statList;
    IBOutlet UILabel *tagStatus;
    ControllerShower *controllerShower;
}

- (void) runReloadData;
- (void) renderAgain;

@property (retain) ControllerShower *controllerShower;

- (void) setGettingTags: (BOOL) b;

@end
