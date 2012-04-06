//
//  StatView.m
//  viewer
//
//  Created by Sam Anklesaria on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatViewController.h"
#import "PicViewController.h"

@implementation StatViewController
@synthesize controllerShower;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger myint = [[[FlightData instance] nameArray] count] + 2;
    return myint;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NSThread detachNewThreadSelector: @selector(renderAgain) toTarget:self withObject:nil];
}

-(void) runReloadData {
    if ([[self navigationController] topViewController] == self) {
        [statList performSelectorOnMainThread: @selector(reloadData) withObject:statList waitUntilDone:NO];
    }
}

-(void) renderAgain {
    [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector:@selector(runReloadData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str;
    UITableViewCellAccessoryType mytype = UITableViewCellAccessoryDisclosureIndicator;
    NSString *cellId;
    UITableViewCellStyle cellStyle;
    NSDate *updatedDate;
    
    FlightData *flightData = [FlightData instance];
    if (indexPath.row == 0) {
        str = @"Orientation";
        if (flightData.lastIMUTime) {
            cellId = @"SubCell";
            cellStyle = UITableViewCellStyleSubtitle;
            updatedDate = flightData.lastIMUTime;
        } else {
            cellId = @"Cell";
            cellStyle = UITableViewCellStyleDefault;
        }
    } else if (indexPath.row == 1) {
        str = [NSString stringWithFormat: @"Images (%d)", [flightData.pictures count]];
        if ([flightData.pictures count] == 0) {
            mytype = UITableViewCellAccessoryNone;
        }
        if (flightData.lastImageTime) {
            cellId = @"SubCell";
            cellStyle = UITableViewCellStyleSubtitle;
            updatedDate = flightData.lastImageTime;
        } else {
            cellId = @"Cell";
            cellStyle = UITableViewCellStyleDefault;
        }
    } else {
        NSString *tag = [flightData.nameArray objectAtIndex:indexPath.row -2];
        StatPoint *stat = [flightData.balloonStats objectForKey: tag];
        if (stat.lastTime) {
            cellId = @"SubCell";
            cellStyle = UITableViewCellStyleSubtitle;
            updatedDate = stat.lastTime;
        } else {
            cellId = @"Cell";
            cellStyle = UITableViewCellStyleDefault;
        }
        NSNumber *n = [(NSDictionary *)[(NSArray *)[stat points] lastObject] objectForKey: @"y"];
        NSString *humanName = [flightData.plistData objectForKey: tag];
        NSString *realName = (humanName != NULL) ? humanName : tag;
        str = [NSString stringWithFormat: @"%@ (%@)", realName, n];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellId] autorelease];
    }
    cell.textLabel.text = str;
    cell.accessoryType = mytype;
    if (cellStyle == UITableViewCellStyleSubtitle) {
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat: @"HH:mm:ss"];
        cell.detailTextLabel.text = [@"Upated " stringByAppendingString: [df stringFromDate: updatedDate]];
        [df release];
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *theText = [[cell textLabel] text];
    FlightData *flightData = [FlightData instance];
    if (indexPath.row == 0) {
        [controllerShower showOrientationWithFrame: cell.frame view:cell.superview];
    } else {
        if (indexPath.row == 1) {
            if ([flightData.pictures count] > 0)
                [controllerShower showPicturesWithFrame:cell.frame view:cell.superview];
        } else {
            NSString *tag = [flightData.nameArray objectAtIndex:indexPath.row -2];
            
            [controllerShower showGraphWithTag: tag frame:cell.frame view:cell.superview title: theText];
        }
    }
    return nil;   
}

- (void) setGettingTags: (BOOL) b {
    tagStatus.text = b ? @"Using LAN" : @"Using remote server";
}

- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title {
    [[self navigationController] pushViewController:controller animated:YES];
    [controller setTitle: title];
}

- (void) hideController {
    [[self navigationController] popViewControllerAnimated: YES];
}

- (void)dealloc {
    [tagStatus release];
    [super dealloc];
}
- (void)viewDidUnload {
    [tagStatus release];
    tagStatus = nil;
    [super viewDidUnload];
}
@end
