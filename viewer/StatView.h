//
//  StatView.h
//  viewer
//
//  Created by Sam Anklesaria on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"
#import "StatTableDelegate.h"

@interface StatView : UIViewController <ControllerShower, UITableViewDataSource> {
    UITableView *statList;
    StatTableDelegate *stDelegate;
}
@end
