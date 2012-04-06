//
//  MapViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlightViewController.h"
#import "StatPoint.h"
#import <time.h>

#define BUFSIZE 800

@implementation FlightViewController
@synthesize altitudeBtn;
@synthesize map;
@synthesize tempButton;
@synthesize controllerShower;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Flight Map"];
    bayInfo = @"(Bay Open)";
    ftInfo = @"0 ft ";
    previousRect = [[self.tabBarController.view.subviews objectAtIndex:0] frame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [self setMap:nil];
    [self setAltitudeBtn:nil];
    [self setTempButton:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [map release];
    [altitudeBtn release];
    [tempButton release];
    [ftInfo release];
    [bayInfo release];
    self.controllerShower = nil;
    [super dealloc];
}

- (IBAction)showAltTbl:(id)sender {
    [controllerShower showGraphWithTag: @"AL" frame: CGRectZero view: nil title: @"Altitude"];
}

- (IBAction)showTempTbl:(id)sender {
    [controllerShower showGraphWithTag: @"TI" frame: CGRectZero view: nil title: @"Temperature"];   
}

- (IBAction)sendMessage:(id)sender {
    [controllerShower sendMessage];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {               
        [self.navigationController setNavigationBarHidden:TRUE animated:FALSE]; 
        [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:FALSE animated:FALSE];
        [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation { 
    UIInterfaceOrientation toOrientation = self.interfaceOrientation;
    if ( self.tabBarController.view.subviews.count >= 2 )
    {
        UIView *transView = [self.tabBarController.view.subviews objectAtIndex:0];
        UIView *tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
        
        if(toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight) {                                     
            tabBar.hidden = TRUE;
            transView.frame = CGRectMake(0, 0, 480, 320 );
            [map setRegion: [map convertRect: map.frame toRegionFromView: map] animated: NO];
        }
        else
        {                     
            transView.frame = previousRect;
            tabBar.hidden = FALSE;
        }
    }
}

- (void)receivedTag:(NSString *)tag withValue:(double)val {
    if ([tag isEqualToString: @"TI"])
        [tempButton setTitle: [NSString stringWithFormat:@"%2fº", val]];
    else if ([tag isEqualToString: @"AL"]) {
        ftInfo = [NSString stringWithFormat: @"%.2f ft " , val];
        [altitudeBtn setTitle: [ftInfo stringByAppendingString: bayInfo]];
    } else if ([tag isEqualToString: @"BB"]) {
        if (bay == 1) {
            bayInfo = @"(Bay Closed)";
            bay = 0;
        } else {
            bayInfo = @"(Bay Open)";
            bay = 1;
        }
        [altitudeBtn setTitle: [ftInfo stringByAppendingString: bayInfo]];
    }
}

- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title {
    [[self navigationController] pushViewController:controller animated:YES];
    [controller setTitle: title];
}

- (void) hideController {
    [self dismissModalViewControllerAnimated: YES];
}

@end
