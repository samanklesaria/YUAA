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
    [NSThread detachNewThreadSelector:@selector(timedReloader) toTarget:self withObject:nil];
}

- (void)timedReloader {
    [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector:@selector(reloadLog) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void)viewDidUnload
{
    [self setLogTable:nil];
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
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [logData count];
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
    
    cell.textLabel.text = [logData objectAtIndex:indexPath.row];
    return cell;
}

-(void)reloadLog {
    if (displayed && [logData count]) {
        [logTable reloadData];
        [logTable scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [logData count] - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: NO];
    }
}

@end
