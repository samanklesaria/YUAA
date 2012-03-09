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

@interface BalloonMapLogic : NSObject <MKMapViewDelegate> {
    Prefs *prefs;
    DataPoint *currentPoint;
    MKMapView *map;
}

- (id) initWithPrefs: (Prefs *)p map: (MKMapView *) m;
- (void)updateWithCurrentLocation:(CLLocationCoordinate2D)location;
- (CLLocationCoordinate2D)midpointFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb;
- (MKCoordinateSpan)distanceFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb;
- (double)spanSize: (MKCoordinateSpan)rect;
- (void) updateView;
- (void)updateLoc;
- (void)postUserLocation;

@end

double myabs(double a);
