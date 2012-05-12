//
//  LogViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlightData.h"

@interface LogViewController : UIViewController <UITableViewDataSource> {
    UITableView *logTable;
    UITextView *textView;
    BOOL displayed;
    NSArray *logData;
    NSArray *logDataCopy;
    id delegate;
}
@property (nonatomic, retain) IBOutlet UITableView *logTable;
@property (retain) NSArray *logData;
@property (retain) id delegate;
@property (retain, nonatomic) IBOutlet UITextView *textView;

- (void)reloadLog;
- (void)scroller;
- (IBAction)logTypeChanged:(id)sender;

@end
