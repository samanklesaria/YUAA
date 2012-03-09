//
//  MapViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DataPoint.h"
#import "Parser.h"
#import "Connector.h"
#import "AbstractControllerShower.h"
#import "ControllerShower.h"

@interface FlightViewController : UIViewController <ConnectorDelegate, AbstractControllerShower> {
    MKMapView *map;
    UIBarButtonItem *tempButton;
    UIBarButtonItem *altitudeBtn;
    NSString *ftInfo;
    NSString *bayInfo;
    CGRect previousRect;
    bool bay;
    ControllerShower *controllerShower;
}

- (IBAction)showAltTbl:(id)sender;
- (IBAction)showTempTbl:(id)sender;

- (IBAction)sendMessage:(id)sender;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *tempButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *altitudeBtn;
@property (retain) ControllerShower *controllerShower;

@end
