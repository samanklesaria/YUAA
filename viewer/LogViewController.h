//
//  LogViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlightData.h"

@protocol LogChangeProtocol <NSObject>
- (void) newLogType: (int) type;
@end

@interface LogViewController : UIViewController <UITableViewDataSource> {
    UITableView *logTable;
    BOOL displayed;
    NSArray *logData;
    id delegate;
}
@property (nonatomic, retain) IBOutlet UITableView *logTable;
@property (retain) NSArray *logData;
@property (retain) id delegate;
@property (retain, nonatomic) IBOutlet UITextView *textView;

- (void)reloadLog;
- (void)timedReloader;
- (IBAction)logTypeChanged:(id)sender;

@end
