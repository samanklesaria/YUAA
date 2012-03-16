//
//  viewerAppDelegate.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatViewController.h"
#import "FlightViewController.h"
#import "PrefsViewController.h"
#import "LogViewController.h"
#import "Connector.h"
#import "Processor.h"
#import "BalloonMapLogic.h"
#import "ControllerShower.h"
#import "GraphViewController.h"
#import "PicViewController.h"
#import "Orientation.h"
#import "EAGLView.h"
#import "BalloonRenderer.h"

@interface viewerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, ProcessorDelegate, PrefsResponder, LogChangeProtocol> {
    IBOutlet PrefsViewController *prefsViewController;
    
    IBOutlet UINavigationController *statNav;
    IBOutlet UINavigationController *flightNav;
    IBOutlet LogViewController *logViewController;
    IBOutlet UIWindow *window;
    
    Prefs *prefs;
    Processor *processor;
    
    GraphViewController *graphView;
    Orientation *orientation;
    PicViewController *picView;
    
    Connector *connector;
    ControllerShower *controllerShower;
    FlightViewController *flightViewController;
    StatViewController *statViewController;
    BalloonMapLogic *balloonMapLogic;
}

@end