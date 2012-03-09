//
//  Orientation.m
//  viewer
//
//  Created by Sam Anklesaria on 11/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Orientation.h"

// We might want to kill this class, as it does nothing.

@implementation Orientation
@synthesize glView;

- (void)viewDidAppear:(BOOL)animated {
    glView.displaying = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    glView.displaying = NO;
}

- (void)viewDidUnload
{
    [self setGlView:nil];
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
    [glView release];
    [super dealloc];
}

@end