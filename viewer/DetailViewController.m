//
//  DetailViewController.m
//  ipad viewer
//
//  Created by Sam Anklesaria on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

#import "RootViewController.h"
#import "PrefsViewController.h"
#import "LogViewController.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation DetailViewController

@synthesize popoverController = _myPopoverController;

#pragma mark - Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */

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

#pragma mark - Split view support

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    self.popoverController = pc;
    CGSize mysize;
    mysize.width = 320; // 400
    mysize.height = 450; // 560
    [pc setPopoverContentSize: mysize];
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{

}


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [SharedData instance].connectorDelegate = self;
    balloonLogic = [[BalloonMapLogic alloc] initWithMap: map];
}


- (void)viewDidUnload
{
    [map release];
    map = nil;
	[super viewDidUnload];
    [prefs release];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
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
    [_myPopoverController release];
    [map release];
    [balloonLogic release];
    [super dealloc];
}

- (IBAction)showSettings:(id)sender {
    if (prefs == nil) {
        prefs = [[[PrefsViewController alloc] initWithNibName:@"PrefsViewController" bundle:nil] retain];
    }
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController.contentViewController = prefs;
    [self.popoverController presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)showLog:(id)sender {
    if ([[SharedData instance] logViewController] == nil) {
        [[LogViewController alloc] initWithNibName:@"LogView" bundle:nil];
    }
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController.contentViewController = [[SharedData instance] logViewController];
    [self.popoverController presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self.popoverController dismissPopoverAnimated:YES];
}

        
- (IBAction)sendMessage:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        if (texter == nil) {
            texter = [[MFMessageComposeViewController alloc]init];
        }
        NSString *pnum = [[SharedData instance] phoneNumber];
        if (pnum) {
            [texter setRecipients: [NSArray arrayWithObject: pnum]];
            [texter setMessageComposeDelegate: self];
        }
        self.popoverController.contentViewController = texter;
        [self.popoverController presentPopoverFromBarButtonItem:sender
                                       permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        UIAlertView *err = [[UIAlertView alloc] initWithTitle: @"Not Supported" message: @"Texting is not supported on this device. Your balloon is as good as lost." delegate: nil cancelButtonTitle: @"Fuck" otherButtonTitles: nil];
        [err show];
        
    }
}

- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title {
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController.contentViewController = controller;
    [self.popoverController presentPopoverFromRect: rect inView:view
                                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) updateLoc {
    if (lat && lon) {
        CLLocationCoordinate2D loc = {lat, lon};
        [balloonLogic updateWithCurrentLocation: loc];
    }
}

- (void)receivedTag:(NSString *)tag withValue:(double)val {
    if ([tag isEqualToString: @"LA"]) {
        lat = val;
        [self updateLoc];
    } else if ([tag isEqualToString: @"LN"]) {
        lon = val;
        [self updateLoc];
    }
}

@end
