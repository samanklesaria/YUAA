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
#import "Grapher.h"
#import "SharedData.h"
#import "Parser.h"
#import <CFNetwork/CFSocketStream.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "Connector.h"

@interface FlightViewController : UIViewController <ConnectorDelegate> {
    MKMapView *map;
    UIBarButtonItem *tempButton;
    DataPoint *selectedPoint;
    DataPoint *currentPoint;
    UIBarButtonItem *altitudeBtn;
    NSString *ftInfo;
    NSString *bayInfo;
    CGRect previousRect;
    double lat;
    double lon;
    bool bay;
    Connector *connector;
}

- (IBAction)showAltTbl:(id)sender;
- (IBAction)showTempTbl:(id)sender;
- (IBAction)killBalloon:(id)sender;

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *bayButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *tempButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *altitudeBtn;

- (void)updateWithCurrentLocation:(CLLocationCoordinate2D)location;

@end
