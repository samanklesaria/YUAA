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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [SharedData instance].logViewController = self;
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setLogTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    SharedData *a = [SharedData instance];
    return [[a logData] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SharedData *a = [SharedData instance];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell.textLabel setFont: [UIFont fontWithName: @"Arial" size:14]];
        [cell.textLabel setTextColor: [UIColor greenColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [a.logData objectAtIndex:indexPath.row];
    return cell;
}

-(void)reloadLog {
    [logTable reloadData];
}

@end
