//
//  MapViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlightViewController.h"
#import "LogViewController.h"
#import "PrefsViewController.h"
#import "SharedData.h"
#import "StatPoint.h"
#import <time.h>

#define BUFSIZE 800

@implementation FlightViewController
@synthesize altitudeBtn;
@synthesize map;
@synthesize bayButton;
@synthesize tempButton;

/*
- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Flight Map"];
    bayInfo = @"(Bay Open)";
    ftInfo = @"0 ft ";
    previousRect = [[self.tabBarController.view.subviews objectAtIndex:0] frame];
    [SharedData instance].connectorDelegate = self;
    balloonLogic = [[BalloonMapLogic alloc] initWithMap: map];
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
    [self setBayButton:nil];
    [[[SharedData instance] plistData] release];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [map release];
    [altitudeBtn release];
    [tempButton release];
    [ftInfo release];
    [bayInfo release];
    [super dealloc];
}

- (IBAction)showAltTbl:(id)sender {
    SharedData *mydata = [SharedData instance];
    StatPoint *alt = [mydata.balloonStats objectForKey: @"AL"];
    if (alt != NULL) {
        [[self navigationController] pushViewController:mydata.grapher animated:YES];
        [mydata.grapher showDataSource: alt named: @"Altitude"];
    } else {
        UIAlertView *err = [[UIAlertView alloc] initWithTitle: @"No Altitude Data" message: @"No altitude information has been received from the balloon." delegate: nil cancelButtonTitle: @"Okay" otherButtonTitles: nil];
        [err show];
    }
}

- (IBAction)showTempTbl:(id)sender {
    SharedData *mydata = [SharedData instance];
    StatPoint *alt = [mydata.balloonStats objectForKey: @"TI"];
    if (alt != NULL) {
        [[self navigationController] pushViewController:mydata.grapher animated:YES];
        [mydata.grapher showDataSource: alt named: @"Temperature"];
    } else {
        UIAlertView *err = [[UIAlertView alloc] initWithTitle: @"No Temperature Data" message: @"No temperature information has been received from the balloon." delegate: nil cancelButtonTitle: @"Okay" otherButtonTitles: nil];
        [err show];
    }
   
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
    } else if ([tag isEqualToString: @"TI"])
        [tempButton setTitle: [NSString stringWithFormat:@"%2fº", val]];
    else if ([tag isEqualToString: @"AL"]) {
        ftInfo = [NSString stringWithFormat: @"%.2f ft " , val];
        [altitudeBtn setTitle: [ftInfo stringByAppendingString: bayInfo]];
    } else if ([tag isEqualToString: @"BB"]) {
        if (bay == 1)
            bayInfo = @"(Bay Closed)";
        else
            bayInfo = @"(Bay Open)";
        [altitudeBtn setTitle: [ftInfo stringByAppendingString: bayInfo]];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated: YES];
}

- (IBAction)killBalloon:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        if (texter == nil) {
            texter = [[MFMessageComposeViewController alloc] init];
            [texter setMessageComposeDelegate: self];
        }
        NSString *pnum = [[SharedData instance] phoneNumber];
        if (pnum) {
            [texter setRecipients: [NSArray arrayWithObject: pnum]];
        }
        [self presentModalViewController: texter animated: YES];
    } else {
        UIAlertView *err = [[UIAlertView alloc] initWithTitle: @"Not Supported" message: @"Texting is not supported on this device. Your balloon is as good as lost." delegate: nil cancelButtonTitle: @"Fuck" otherButtonTitles: nil];
        [err show];
        
    }
}

@end
