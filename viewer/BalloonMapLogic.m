//
//  BalloonMapDelegate.m
//  viewer
//
//  Created by Sam Anklesaria on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BalloonMapLogic.h"
#import "SharedData.h"

@implementation BalloonMapLogic


- (id)initWithMap: (MKMapView *)newmap
{
    self = [super init];
    if (self) {
        map = [newmap retain];
        [map setDelegate: self];
    }
    return self;
}

- (void) dealloc {
    [map release];
    [selectedPoint release];
    [currentPoint release];
    [super dealloc];
}


- (void)updateWithCurrentLocation:(CLLocationCoordinate2D)location {
    DataPoint *p = [[DataPoint alloc] initWithCoordinate:location];
    DataPoint *oldPoint = currentPoint;
    currentPoint = p;    
    if (oldPoint != nil) {
        [map removeAnnotation:oldPoint];
        [map addAnnotation:oldPoint];
    }
    [map addAnnotation:p];
    if ([[SharedData instance] autoAdjust]) {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta=0.6;
        span.longitudeDelta=0.6;
        region.span=span;
        region.center=location;
        [map setRegion:region animated:TRUE];
        [map regionThatFits:region];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(DataPoint *)annotation{
    static NSString *defaultAnnotationID = @"datapoint";
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:defaultAnnotationID];
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
