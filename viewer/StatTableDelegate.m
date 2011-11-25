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
        pictures = [[PicViewController alloc] initWithNibName:@"PicViewController" bundle:nil];
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
    if (indexPath.row == 0)
        str = @"Orientation";
    else {
        if (indexPath.row == 1)
             str = @"Pictures";
        else {
            NSLog(@"Looking for label %@", [a.statArray objectAtIndex:indexPath.row -2]);
            str = [a.plistData objectForKey: [a.statArray objectAtIndex:indexPath.row -2]];
        }
    }
    NSString *cellid = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellid] autorelease];
    }
    cell.textLabel.text = str;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *theText = [[cell textLabel] text];
    if (indexPath.row == 0) {
        [shower showController: orientation withFrame:cell.frame view:cell.superview title: theText];
    } else {
        if (indexPath.row == 1) {
            [shower showController: pictures withFrame:cell.frame view:cell.superview title: theText];
        } else {
            SharedData *a = [SharedData instance];
            NSString *theText = [[cell textLabel] text];
            NSString *tag = [a.statArray objectAtIndex:indexPath.row -2];
            
            SharedData *mydata = [SharedData instance];
            [shower showController: mydata.grapher withFrame:cell.frame view:cell.superview title: theText];
            StatPoint *tmp = [mydata.balloonStats objectForKey: tag];
            [mydata.grapher showDataSource: tmp named: theText];
        }
    }
    return nil;   
}

@end
