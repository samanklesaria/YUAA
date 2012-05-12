//
//  BalloonMapDelegate.h
//  viewer
//
//  Created by Sam Anklesaria on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DataPoint.h"
#import "Prefs.h"
#import "FlightData.h"
#import "ASIHTTPRequest.h"

@interface BalloonMapLogic : NSObject <MKMapViewDelegate> {
    Prefs *prefs;
    DataPoint *currentPoint;
    NSMutableArray *oldPoints;
    NSMutableArray *transitionPoints;
    MKMapView *map;
    MKCoordinateRegion currentRegion;
    BOOL okToUpdate;
}

- (id) initWithPrefs: (Prefs *)p map: (MKMapView *) m;
- (void)updateWithCurrentLocation:(CLLocationCoordinate2D)location;
- (CLLocationCoordinate2D)midpointFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb;
- (MKCoordinateSpan)distanceFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb;
- (double)spanSize: (MKCoordinateSpan)rect;
- (void) updateView;
- (void)updateLoc;
- (void) doUpdate;
- (void)postUserLocation;
@property BOOL okToUpdate;

@end

double myabs(double a);
