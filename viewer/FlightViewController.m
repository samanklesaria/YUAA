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
    [[self navigationController] pushViewController:mydata.grapher animated:YES];
    StatPoint *alt = [mydata.balloonStats objectForKey: @"AL"];
    [mydata.grapher showDataSource: alt named: @"Altitude"];
}

- (IBAction)showTempTbl:(id)sender {
    SharedData *mydata = [SharedData instance];
    [[self navigationController] pushViewController:mydata.grapher animated:YES];
    StatPoint *tmp = [mydata.balloonStats objectForKey: @"TI"];
    [mydata.grapher showDataSource: tmp named: @"Temperature Inside"];
   
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
    if ([tag isEqualToString: @"LA"]) {
        lat = val;
        return;
    }
    if ([tag isEqualToString: @"LN"]) {
        lon = val;
        return;
    }
    if ([tag isEqualToString: @"TI"])
        [altitudeBtn setTitle: [NSString stringWithFormat:@"%2fº", val]];
    if ([tag isEqualToString: @"AL"])
        ftInfo = [NSString stringWithFormat: @"%f ft" , val];
    if ([tag isEqualToString: @"BB"]) {
        if (bay == 1)
            bayInfo = @"(Bay Closed)";
        else
            bayInfo = @"(Bay Open)";
    }    
}

- (void)endOfTags {
    if (lat && lon) {
        CLLocationCoordinate2D loc = {lat, lon};
        [balloonLogic updateWithCurrentLocation: loc];
    }
    [altitudeBtn setTitle: [ftInfo stringByAppendingString: bayInfo]];
    lat = 0; lon = 0;
}

- (IBAction)killBalloon:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *texter = [[MFMessageComposeViewController alloc]init];
        [texter setRecipients: [NSArray arrayWithObject:[[SharedData instance] phoneNumber]]];
        [self presentModalViewController: texter animated: YES];
    } else {
        UIAlertView *err = [[UIAlertView alloc] initWithTitle: @"Not Supported" message: @"Texting is not supported on this device. Your balloon is as good as lost." delegate: nil cancelButtonTitle: @"Fuck" otherButtonTitles: nil];
        [err show];
        
    }
}

@end
