//
//  StatView.m
//  viewer
//
//  Created by Sam Anklesaria on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatView.h"

@implementation StatView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Stats"];
        stDelegate = [[StatTableDelegate alloc] init];
        stDelegate.shower = self;
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
}

- (void)viewDidUnload
{

    [stDelegate release];
    stDelegate = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [stDelegate release];
    [super dealloc];
}

-(void) showController:(UIViewController *)controller withFrame:(CGRect)rect view:(UIView *)view title: (NSString *)title {
    [[self navigationController] pushViewController:controller animated:YES];
    [controller setTitle: title];
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

@end
