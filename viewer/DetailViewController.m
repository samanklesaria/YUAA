//
//  DetailViewController.m
//  ipad viewer
//
//  Created by Sam Anklesaria on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

@synthesize controllerShower;
@synthesize map;
@synthesize prefs;
@synthesize log;

- (IBAction)sendMessage:(id)sender {
    [controllerShower sendMessage];
}

- (void)viewDidLoad
{
    CGSize mysize;
    mysize.width = 320; // 400
    mysize.height = 450; // 560
    pc = [[UIPopoverController alloc] initWithContentViewController:self];
    [pc setPopoverContentSize: mysize];
    [super viewDidLoad];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [map release];
    [prefs release];
    [pc release];
    self.controllerShower = nil;
    self.log = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (IBAction)showSettings:(id)sender {
    [pc dismissPopoverAnimated:YES];
    pc.contentViewController = prefs;
    [pc presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)showLog:(id)sender {
    [pc dismissPopoverAnimated:YES];
    pc.contentViewController = log;
    [pc presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
 
- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title {
    [pc dismissPopoverAnimated:YES];
    pc.contentViewController = controller;
    [pc presentPopoverFromRect: rect inView:view
                                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) hideController {
    [pc dismissPopoverAnimated:YES];
}

@end
