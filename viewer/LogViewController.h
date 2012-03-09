//
//  LogViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogViewController : UIViewController <UITableViewDataSource> {
    UITableView *logTable;
    BOOL displayed;
    NSArray *logData;
}
@property (nonatomic, retain) IBOutlet UITableView *logTable;
@property (retain) NSArray *logData;

- (void)reloadLog;
- (void)timedReloader;

@end
