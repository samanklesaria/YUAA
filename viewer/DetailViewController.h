//
//  DetailViewController.h
//  ipad viewer
//
//  Created by Sam Anklesaria on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connector.h"
#import "PrefsViewController.h"
#import "AbstractControllerShower.h"
#import "LogViewController.h"
#import "ControllerShower.h"
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    IBOutlet MKMapView *map;
    PrefsViewController *prefs;
    LogViewController *logViewController;
    ControllerShower *controllerShower;
    UIPopoverController *pc;
}

- (IBAction)showSettings:(id)sender;
- (IBAction)showLog:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title;

@property (retain) ControllerShower *controllerShower;
@property (retain) MKMapView *map;
@property (retain) PrefsViewController *prefs;
@property (retain) LogViewController *log;
@end
