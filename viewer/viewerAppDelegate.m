//
//  viewerAppDelegate.m
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "viewerAppDelegate.h"

@implementation viewerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    prefs = [[Prefs alloc] init];
    prefsViewController.prefs = prefs;
    prefsViewController.delegate = self;
    FlightData *f = [FlightData instance];
    processor = [[Processor alloc] initWithPrefs: prefs];
    processor.delegate = self;
    
    statViewController = [[StatViewController alloc] initWithNibName:@"StatViewController" bundle:nil];
    statViewController.title = @"Stats";
    [statNav pushViewController:statViewController animated:YES];
    
    flightViewController = [[FlightViewController alloc] initWithNibName:@"FlightViewController" bundle:nil];
    flightViewController.title = @"Map";
    [flightNav pushViewController:flightViewController animated:YES];
    
    connector = [[Connector alloc] initWithProcessor: processor prefs: prefs];
    logViewController.logData = f.parseLogData;
    
    graphView = [[GraphViewController alloc] initWithNibName:@"GraphViewController" bundle:nil];
    
    orientation = [[Orientation alloc] initWithNibName:@"Orientation" bundle:nil];
    
    picView = [[PicViewController alloc] initWithNibName:@"PicViewController" bundle:nil];
    
    controllerShower = [[ControllerShower alloc] initWithConnector: connector shower:flightViewController graphView:graphView orientationView: orientation picView:picView];
    flightViewController.controllerShower = controllerShower;
    statViewController.controllerShower = controllerShower;
    
    [window makeKeyAndVisible];
    
    balloonMapLogic = [[BalloonMapLogic alloc] initWithPrefs:prefs map: flightViewController.map];
    [self mapTrackingChanged: prefs.autoAdjust];
    
    return YES;
}

- (void)mapChosen: (int)type {
    switch (type) {
        case 0: 
            [flightViewController.map setMapType: MKMapTypeStandard];
            break;
        case 1: 
            [flightViewController.map setMapType: MKMapTypeSatellite];
            break;
        case 2: 
            [flightViewController.map setMapType: MKMapTypeHybrid];
            break;
    }
}

- (void)mapTrackingChanged: (bool)type {
    if (type) {
       [flightViewController.map setUserTrackingMode: MKUserTrackingModeFollowWithHeading animated: YES]; 
    } else {
        [flightViewController.map setUserTrackingMode: MKUserTrackingModeNone];
        [balloonMapLogic updateView];
    }
}

-(void)receivedTag:(NSString *)theData withValue:(double)val {
    [flightViewController receivedTag: theData withValue: val]; 
}

-(void)receivedPicture {
    [picView addedImage];
}

-(void)receivedLocation {
    [balloonMapLogic updateLoc];
}

-(void)gettingTags: (bool)b {
    NSLog(@"Getting tags: %d", b);
    [statViewController view];
    [statViewController setGettingTags: b];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == flightNav) {
        [controllerShower setShower: flightViewController];
    } else if (viewController == statNav) {
        [controllerShower setShower: statViewController];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [prefsViewController release];
    [statNav release];
    [flightNav release];
    [window release];
    [connector release];
    [controllerShower release];
    [flightViewController release];
    [statViewController release];
    [balloonMapLogic release];
    [logViewController release];
    [prefs release];
    [processor release];
    [super dealloc];
}

@end
