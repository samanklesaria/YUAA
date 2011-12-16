//
//  BalloonMapDelegate.m
//  viewer
//
//  Created by Sam Anklesaria on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BalloonMapLogic.h"
#import "SharedData.h"
#include <math.h>

@implementation BalloonMapLogic


- (id)initWithMap: (MKMapView *)newmap
{
    self = [super init];
    if (self) {
        SharedData *s = [SharedData instance];
        s.map = [newmap retain];
        [s.map setDelegate: self];
        s.map.showsUserLocation = YES;
        
    }
    return self;
}

- (void) dealloc {
    [selectedPoint release];
    [currentPoint release];
    [locmanager release];
    [super dealloc];
}

- (void) mapView: (MKMapView *)map didUpdateUserLocation: (MKUserLocation *)userLocation {
    if (currentPoint)
        [self updateView: currentPoint.coordinate];
}


- (CLLocationCoordinate2D)midpointFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb {
    CLLocationCoordinate2D midpoint;
    midpoint.latitude = (loca.latitude + locb.latitude) / 2;
    midpoint.longitude = (loca.longitude + locb.longitude) / 2;
    return midpoint;
}

double myabs(double a) {
    return a >0 ? a : -a;
}

- (MKCoordinateSpan)distanceFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb {
    MKCoordinateSpan spanA;
    double f = myabs(loca.latitude - locb.latitude);
    double s = myabs(loca.longitude - locb.longitude);
    spanA.latitudeDelta = f;
    spanA.longitudeDelta = s;
    return spanA;
}

- (double)spanSize: (MKCoordinateSpan)rect {
    return rect.latitudeDelta * rect.longitudeDelta;
}

- (void)updateWithCurrentLocation:(CLLocationCoordinate2D)location {
    SharedData *s = [SharedData instance];
    DataPoint *p = [[DataPoint alloc] initWithCoordinate:location];
    DataPoint *oldPoint = currentPoint;
    currentPoint = p;    
    if (oldPoint != nil) {
        [s.map removeAnnotation:oldPoint];
        [s.map addAnnotation:oldPoint];
    }
    [s.map addAnnotation:p];
    [self updateView: location];
}

-(void) updateView: (CLLocationCoordinate2D)location  {
    SharedData *s = [SharedData instance];
    if ([s autoAdjust] == AUTO) {
        CLLocationCoordinate2D carloc = s.map.userLocation.location.coordinate;
        MKCoordinateSpan spanB;
        spanB.latitudeDelta=0.2;
        spanB.longitudeDelta=0.2;
        MKCoordinateRegion region;
        if (carloc.latitude && carloc.longitude) {
            CLLocationCoordinate2D center = [self midpointFrom:location to:carloc];
            MKCoordinateSpan spanA = [self distanceFrom: location to: carloc];
            region.span = ([self spanSize: spanB] > [self spanSize: spanA]) ? spanB : spanA;
            region.center=center;
        } else {
            region.center = location;
            region.span = spanB;
        }
        [s.map setRegion: [s.map regionThatFits: region] animated:TRUE];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(DataPoint *)annotation{
    SharedData *s = [SharedData instance];
    static NSString *defaultAnnotationID = @"datapoint";
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[s.map dequeueReusableAnnotationViewWithIdentifier:defaultAnnotationID];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultAnnotationID];
        annotationView.canShowCallout = YES;
        annotationView.calloutOffset = CGPointMake(-5, 5);
    } else {
        annotationView.annotation = annotation;
    }
    [annotationView setPinColor:annotation == currentPoint? MKPinAnnotationColorGreen:MKPinAnnotationColorRed];
    
    if (selectedPoint == annotation) {
        [annotationView setPinColor:MKPinAnnotationColorPurple];
    }
    
    return annotationView;
}

@end
