//
//  LogViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LogViewController.h"

@implementation LogViewController
@synthesize logTable;
@synthesize logData;
@synthesize delegate;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadLog];
    [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector:@selector(reloadLog) userInfo:nil repeats:YES];
    // [NSThread detachNewThreadSelector:@selector(timedReloader) toTarget:self withObject:nil];
}

- (void)timedReloader {
    [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector:@selector(reloadLog) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (IBAction)logTypeChanged:(id)sender {
    logData = NULL;
    NSInteger ind = ((UISegmentedControl *)sender).selectedSegmentIndex;
    if (ind == 2) {
        [logTable setHidden: YES];
        [textView setHidden: NO];
    } else {
        FlightData *f = [FlightData instance];
        logData = (ind == 0) ? f.parseLogData : f.netLogData;
        [logTable setHidden: NO];
        [textView setHidden: YES];
    }
    [self scroller];
}

- (void) scroller {
    if (!logData) {
        NSRange range;
        range = NSMakeRange ([[textView text] length], 0);
        [textView scrollRangeToVisible: range];
    } else {
        if ([logDataCopy count]) {
        // [logTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [logTable scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [logDataCopy count] - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
        }
    }
}

- (void)viewDidUnload
{
    [self setLogTable:nil];
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    displayed = YES;
    [self reloadLog];
}

- (void)viewDidDisappear:(BOOL)animated {
    displayed = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    // Return YES for supported orientations
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [logTable release];
    [delegate release];
    [textView release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (logData) {
        logDataCopy = logData;
        return [logDataCopy count];
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell.textLabel setFont: [UIFont fontWithName: @"Arial" size:14]];
        [cell.textLabel setTextColor: [UIColor greenColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [logDataCopy objectAtIndex:indexPath.row];
    return cell;
}

-(void)reloadLog {
    if (displayed && self.textView.hidden) {
        [logTable reloadData];
    }
}

@end
