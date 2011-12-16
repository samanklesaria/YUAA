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

@interface BalloonMapLogic : NSObject <MKMapViewDelegate> {
    DataPoint *selectedPoint;
    DataPoint *currentPoint;
    CLLocationManager *locmanager;
}

- (id) initWithMap: (MKMapView *)map;
- (void)updateWithCurrentLocation:(CLLocationCoordinate2D)location;
- (CLLocationCoordinate2D)midpointFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb;
- (MKCoordinateSpan)distanceFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb;
- (double)spanSize: (MKCoordinateSpan)rect;
- (void) updateView: (CLLocationCoordinate2D)location;

@end

double myabs(double a);