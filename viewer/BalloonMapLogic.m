//
//  BalloonMapDelegate.m
//  viewer
//
//  Created by Sam Anklesaria on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BalloonMapLogic.h"
#include <math.h>
#import "Parser.h"
#import "ASIFormDataRequest.h"

@implementation BalloonMapLogic

- (id) initWithPrefs: (Prefs *)p map: (MKMapView *) m {
    self = [self init];
    if (self) {
        prefs = p;
        map = m;
        [map setDelegate: self];
        map.showsUserLocation = YES;
        [self updateView];
        [NSThread detachNewThreadSelector:@selector(poster) toTarget:self withObject:nil];
    }
    return self;
}

- (void) poster {
    [NSTimer scheduledTimerWithTimeInterval: 2 target: self selector:@selector(postUserLocation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void) dealloc {
    [selectedPoint release];
    [currentPoint release];
    [locmanager release];
    [super dealloc];
}

- (void) mapView: (MKMapView *)map didUpdateUserLocation: (MKUserLocation *)userLocation {
    [self updateView];
}

- (void) postUserLocation {
    char latstr[20];
    char lonstr[20];
    CLLocationCoordinate2D coord = map.userLocation.location.coordinate;
    if (coord.latitude && coord.longitude) {
        sprintf(latstr,"%+.5f",coord.latitude);
        sprintf(lonstr,"%+.5f",coord.longitude);
        int latlen = strlen(latstr);
        int lonlen = strlen(lonstr);
        char *lats = malloc(sizeof(char) * (latlen + 6));
        char *lons = malloc(sizeof(char) * (lonlen + 6));
        createProtocolMessage(lats,"LA", latstr, latlen);
        createProtocolMessage(lons,"LO", lonstr, lonlen);
        NSURL *myLocUrl = [NSURL URLWithString: [NSString stringWithFormat: @"http://yuaa.tc.yale.edu/scripts/store.php"]];
        ASIFormDataRequest *locReq = [ASIFormDataRequest requestWithURL:myLocUrl];
        [locReq setPostValue: prefs.uuid forKey:@"uid"];
        [locReq setPostValue: @"berkeley" forKey: @"password"];
        [locReq setPostValue: [prefs deviceName] forKey:@"devname"];
        [locReq setPostValue: [NSString stringWithFormat: @"%s%s", lats, lons] forKey: @"data"];
        [locReq setDelegate:self];
        [locReq startAsynchronous];
    }
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
    
    NSLog(@"GPS is %f, %f", location.latitude, location.longitude);
    DataPoint *p = [[DataPoint alloc] initWithCoordinate:location];
    DataPoint *oldPoint = currentPoint;
    currentPoint = p;    
    if (oldPoint != nil) {
        [map removeAnnotation:oldPoint];
        [map addAnnotation:oldPoint];
    }
    [map addAnnotation:p];
    [self updateView];
}

-(void) updateView {
    if ([prefs autoAdjust] == 0) {
        CLLocationCoordinate2D carloc = map.userLocation.location.coordinate;
        MKCoordinateSpan spanB;
        spanB.latitudeDelta=0.02;
        spanB.longitudeDelta=0.02;
        MKCoordinateRegion region;
        if (carloc.latitude && carloc.longitude) {
            if (currentPoint != nil) {
                CLLocationCoordinate2D center = [self midpointFrom:currentPoint.coordinate to:carloc];
                MKCoordinateSpan spanA = [self distanceFrom: currentPoint.coordinate to: carloc];
                region.span = ([self spanSize: spanB] > [self spanSize: spanA]) ? spanB : spanA;
                region.center=center;
            } else {
                region.center = carloc;
                region.span = spanB;
            }
        } else if (currentPoint != nil) {
            region.center = currentPoint.coordinate;
            region.span = spanB;
        } else {
            return;
        }
        [map setRegion: [map regionThatFits: region] animated:TRUE];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(DataPoint *)annotation{
    static NSString *defaultAnnotationID = @"datapoint";
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:defaultAnnotationID];
    if (annotationView == nil) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultAnnotationID] autorelease];
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

- (void) updateLoc {
    FlightData *f = [FlightData instance];
    if (f.lat && f.lon) {
        CLLocationCoordinate2D loc = {f.lat, f.lon};
        [self updateWithCurrentLocation: loc];
    }
}


@end
