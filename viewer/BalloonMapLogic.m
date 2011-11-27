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
        map = [newmap retain];
        map.showsUserLocation = YES;
        [map setDelegate: self];
        
        locmanager = [[CLLocationManager alloc] init];
        [locmanager setDelegate:self];
        [locmanager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locmanager startUpdatingLocation];
    }
    return self;
}

- (void) dealloc {
    [map release];
    [selectedPoint release];
    [currentPoint release];
    [locmanager release];
    [super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *err = [[UIAlertView alloc] initWithTitle: @"Tracking Failed" message: @"That invisibility cloak you're wearing really isn't helping." delegate: nil cancelButtonTitle: @"Silly Me." otherButtonTitles: nil];
    [err show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    carloc = newLocation.coordinate;
    [self updateView: currentPoint.coordinate];
}


- (CLLocationCoordinate2D)midpointFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb {
    CLLocationCoordinate2D midpoint;
    midpoint.latitude = (loca.latitude + locb.latitude) / 2;
    midpoint.longitude = (loca.longitude + locb.longitude) / 2;
    return midpoint;
}

- (MKCoordinateSpan)distanceFrom:(CLLocationCoordinate2D)loca to: (CLLocationCoordinate2D)locb {
    CLLocationDegrees a = abs(loca.latitude - locb.latitude);
    CLLocationDegrees b = abs(loca.longitude - locb.longitude);
    return MKCoordinateSpanMake(a,b);
}

- (double)spanSize: (MKCoordinateSpan)rect {
    return rect.latitudeDelta * rect.longitudeDelta;
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
    [self updateView: location];
}

-(void) updateView: (CLLocationCoordinate2D)location  {
    if ([[SharedData instance] autoAdjust]) {
        CLLocationCoordinate2D center = [self midpointFrom: carloc to: location];
        MKCoordinateSpan spanA = [self distanceFrom: center to: location];
        MKCoordinateSpan spanB;
        spanB.latitudeDelta=0.6;
        spanB.longitudeDelta=0.6;
        MKCoordinateRegion region;
        region.span = ([self spanSize: spanB] > [self spanSize: spanA]) ? spanB : spanA;
        region.center=center;
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
