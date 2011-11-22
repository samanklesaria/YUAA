//
//  PicViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 11/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PicViewController.h"
#import "SharedData.h"

@implementation PicViewController
@synthesize pageControl;
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    NSArray *images = [[SharedData instance] images];
    pageControl.numberOfPages = [images count];
    if ([images count] > 0) {
        image.image = [UIImage imageWithData: [images objectAtIndex: 1]];
        pageControl.currentPage = 0;
    }
}

//swiping?

- (void)viewDidUnload
{
    [self setPageControl:nil];
    [self setImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pageValueChanged:(id)sender {
    NSArray *images = [[SharedData instance] images];
    image.image = [UIImage imageWithData: [images objectAtIndex: pageControl.currentPage]];
}

- (void)dealloc {
    [pageControl release];
    [image release];
    [super dealloc];
}
@end
