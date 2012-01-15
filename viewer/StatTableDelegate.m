//
//  StatTableDelegate.m
//  viewer
//
//  Created by Sam Anklesaria on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatTableDelegate.h"
#import "SharedData.h"

@implementation StatTableDelegate
@synthesize shower;

- (id)init
{
    self = [super init];
    if (self) {
        orientation = [[Orientation alloc] initWithNibName:@"Orientation" bundle:nil];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SharedData *a = [SharedData instance];
    return [[a statArray] count] + 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SharedData *a = [SharedData instance];
    NSString *str;
    UITableViewCellAccessoryType mytype = UITableViewCellAccessoryDisclosureIndicator;
    NSString *cellId;
    UITableViewCellStyle cellStyle;
    NSDate *updatedDate;
    UITableViewCellSelectionStyle mySelect = UITableViewCellSelectionStyleBlue;
    
    if (indexPath.row == 0) {
        str = @"Orientation";
        if (a.lastIMUTime) {
            cellId = @"SubCell";
            cellStyle = UITableViewCellStyleSubtitle;
            updatedDate = a.lastIMUTime;
        } else {
            cellId = @"Cell";
            cellStyle = UITableViewCellStyleDefault;
        }
    } else if (indexPath.row == 1) {
        str = [NSString stringWithFormat: @"Images (%d)", [a.picViewController imagesCount]];
        if ([a.picViewController imagesCount] == 0) {
            mytype = UITableViewCellAccessoryNone;
            mySelect = UITableViewCellSelectionStyleNone;
        }
        if (a.lastImageTime) {
            cellId = @"SubCell";
            cellStyle = UITableViewCellStyleSubtitle;
            updatedDate = a.lastImageTime;
        } else {
            cellId = @"Cell";
            cellStyle = UITableViewCellStyleDefault;
        }
    } else {
        NSString *tag = [a.statArray objectAtIndex:indexPath.row -2];
        StatPoint *stat = [a.balloonStats objectForKey: tag];
        if (stat.lastTime) {
            cellId = @"SubCell";
            cellStyle = UITableViewCellStyleSubtitle;
            updatedDate = stat.lastTime;
        } else {
            cellId = @"Cell";
            cellStyle = UITableViewCellStyleDefault;
        }
        NSNumber *n = [(NSDictionary *)[(NSArray *)[stat points] lastObject] objectForKey: @"y"];
        NSString *humanName = [a.plistData objectForKey: tag];
        NSString *realName = (humanName != NULL) ? humanName : tag;
        str = [NSString stringWithFormat: @"%@ (%@)", realName, n];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellId] autorelease];
    }
    cell.textLabel.text = str;
    cell.accessoryType = mytype;
    // cell.selectionStyle = mySelect;
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
    SharedData *a = [SharedData instance];
    if (indexPath.row == 0) {
        [shower showController: orientation withFrame:cell.frame view:cell.superview title: theText];
    } else {
        if (indexPath.row == 1) {
            if ([a.picViewController imagesCount] > 0)
                [shower showController: a.picViewController withFrame:cell.frame view:cell.superview title: theText];
        } else {
            SharedData *a = [SharedData instance];
            NSString *theText = [[cell textLabel] text];
            NSString *tag = [a.statArray objectAtIndex:indexPath.row -2];
            
            [shower showController: a.grapher withFrame:cell.frame view:cell.superview title: theText];
            StatPoint *tmp = [a.balloonStats objectForKey: tag];
            [a.grapher showDataSource: tmp named: theText];
        }
    }
    return nil;   
}

@end
