//
//  ipad_viewerAppDelegate.m
//  ipad viewer
//
//  Created by Sam Anklesaria on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ipad_viewerAppDelegate.h"

@implementation ipad_viewerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    oldString = [[NSMutableString alloc] initWithCapacity: 1024];
    prefs = [[Prefs alloc] init];
    prefsViewController.prefs = prefs;
    mapViewController.prefs  = prefsViewController;
    prefsViewController.delegate = self;
    FlightData *f = [FlightData instance];
    processor = [[Processor alloc] initWithPrefs: prefs];
    processor.delegate = self;
    
    statViewController.title = @"Stats";
    
    logViewController = [[LogViewController alloc] initWithNibName:@"LogViewController" bundle:nil];
    logViewController.logData = f.parseLogData;
    logViewController.delegate = self;
    [logViewController view];
    mapViewController.log = logViewController;
    
    connector = [[Connector alloc] initWithProcessor: processor prefs: prefs];
    connector.delegate = self;
    
    graphView = [[GraphViewController alloc] initWithNibName:@"GraphViewController" bundle:nil];
    
    orientation = [[Orientation alloc] initWithNibName:@"Orientation" bundle:nil];
    
    picView = [[PicViewController alloc] initWithNibName:@"PicViewController" bundle:nil];
    
    controllerShower = [[ControllerShower alloc] initWithConnector: connector shower:mapViewController graphView:graphView orientationView: orientation picView:picView];
    mapViewController.controllerShower = controllerShower;
    statViewController.controllerShower = controllerShower;
    
    
    window.rootViewController = splitViewController;
    [window makeKeyAndVisible];
    
    balloonMapLogic = [[BalloonMapLogic alloc] initWithPrefs:prefs map: mapViewController.map];
    [self mapTrackingChanged: prefs.autoAdjust];
    
    return YES;
}

- (void)gotAkpString:(NSString *)akp {
    [oldString appendString: akp];
    int len = [oldString length] - 1024;
    if (len > 0) {
        NSRange rng;
        rng.location = 0;
        rng.length = len;
        [oldString deleteCharactersInRange: rng];
    }
    [logViewController.textView performSelectorOnMainThread:@selector(setText:) withObject: oldString waitUntilDone:NO];
    [logViewController scroller];
}

-(void)gettingTags: (bool)b {
    [statViewController view];
    [statViewController setGettingTags: b];
}

- (void)mapChosen: (int)type {
    switch (type) {
        case 0: 
            [mapViewController.map setMapType: MKMapTypeStandard];
            break;
        case 1: 
            [mapViewController.map setMapType: MKMapTypeSatellite];
            break;
        case 2: 
            [mapViewController.map setMapType: MKMapTypeHybrid];
            break;
    }
}

- (void)mapTrackingChanged: (bool)type {
    if (type) {
        [mapViewController.map setUserTrackingMode: MKUserTrackingModeFollowWithHeading animated: YES]; 
    } else {
        [mapViewController.map setUserTrackingMode: MKUserTrackingModeNone];
        [balloonMapLogic updateView];
    }
}

-(void)receivedPicture {
    [picView addedImage];
}

-(void)receivedLocation {
    [balloonMapLogic updateLoc];
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
    [window release];
    [statViewController release];
    [mapViewController release];
    [prefsViewController release];
    [splitViewController release];
    [controllerShower release];
    [graphView release];
    [orientation release];
    [connector release];
    [balloonMapLogic release];
    [prefs release];
    [logViewController release];
    [super dealloc];
}

@end
