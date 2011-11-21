//
//  viewerAppDelegate.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"
#import "StatView.h"
#import "FlightViewController.h"

@interface viewerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UINavigationController *_navController;
    UINavigationController *_mapNavController;
}
@property (nonatomic, retain) IBOutlet UINavigationController *mapNavController;

@property (nonatomic, retain) IBOutlet UINavigationController *statusNavController;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
