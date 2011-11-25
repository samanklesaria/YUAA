//
//  RootViewController.m
//  ipad viewer
//
//  Created by Sam Anklesaria on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "DetailViewController.h"

@implementation RootViewController
		
@synthesize detailViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320, 450);
    stDelegate = [[StatTableDelegate alloc] init];
    stDelegate.shower = self;
    [[SharedData instance] setTable: [self tableView]];
}

		
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [detailViewController release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    return [stDelegate tableView: tableView numberOfRowsInSection: section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [stDelegate numberOfSectionsInTableView: tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [stDelegate tableView: tableView cellForRowAtIndexPath: indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return [stDelegate tableView: tableView willSelectRowAtIndexPath:indexPath];
}

- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title {
    [detailViewController showController: controller withFrame:rect view:view title: title];
}
@end
