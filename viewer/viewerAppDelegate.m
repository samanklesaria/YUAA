//
//  viewerAppDelegate.m
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "viewerAppDelegate.h"
#import "Parser.h"

@implementation viewerAppDelegate

@synthesize mapNavController = _mapNavController;
@synthesize statusNavController = _navController;
@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    initCrc8();
    initContentBuf();
    self.window.rootViewController = self.tabBarController;
    SharedData *s = [SharedData instance];
    s.lshift = 0.0f;
    s.ushift = -0.1f;
    s.vshift = -2.0f;
    
    // INTERACTIVE SHIFTING IS the only way to get the right parameters
    
    StatView *statController = [[StatView alloc] initWithNibName:@"StatView" bundle:nil];
    [[self statusNavController] pushViewController:statController animated:NO];
    FlightViewController *mapController = [[FlightViewController alloc] initWithNibName:@"FlightViewController" bundle:nil];
    [[self mapNavController] pushViewController:mapController animated:NO];
    [self.window makeKeyAndVisible];
    return YES;
    
    // use detachNewThreadSelector:toTarget:withObject:
    // to start fetching from the server
    // make sure to stop the connection when deallocating
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
    [_window release];
    [_tabBarController release];
    [_navController release];
    [_mapNavController release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
