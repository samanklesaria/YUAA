//
//  ipad_viewerAppDelegate.h
//  ipad viewer
//
//  Created by Sam Anklesaria on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefsViewController.h"
#import "Connector.h"
#import "ControllerShower.h"
#import "StatViewController.h"
#import "BalloonMapLogic.h"
#import "LogViewController.h"
#import "DetailViewController.h"
#import "BalloonRenderer.h"

@class StatViewController;

@class DetailViewController;

@interface ipad_viewerAppDelegate : NSObject <UIApplicationDelegate, PrefsResponder, ProcessorDelegate, LogChangeProtocol> {
    IBOutlet DetailViewController *mapViewController;
    IBOutlet StatViewController *statViewController;
    IBOutlet PrefsViewController *prefsViewController;
    IBOutlet UIWindow *window;
    IBOutlet UISplitViewController *splitViewController;
    LogViewController *logViewController;
    
    Prefs *prefs;
    Processor *processor;
    
    GraphViewController *graphView;
    Orientation *orientation;
    PicViewController *picView;
    
    Connector *connector;
    ControllerShower *controllerShower;
    BalloonMapLogic *balloonMapLogic;
}

@end
