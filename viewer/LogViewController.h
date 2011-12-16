//
//  LogViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"

@interface LogViewController : UIViewController <UITableViewDataSource> {
    UITableView *logTable;
}
@property (nonatomic, retain) IBOutlet UITableView *logTable;
- (void)reloadLog;

@end
