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
#import "IPAddress.h"
#import "Parser.h"

#define TIMEOUT 20

@implementation BalloonMapLogic


- (id)initWithMap: (MKMapView *)newmap
{
    self = [super init];
    if (self) {
        SharedData *s = [SharedData instance];
        s.map = [newmap retain];
        [s.map setDelegate: self];
        s.map.showsUserLocation = YES;
        [NSThread detachNewThreadSelector: @selector(postLocation) toTarget:self withObject:nil];
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
    [self updateView];
}

- (void)postLocation {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    SharedData *s = [SharedData instance];
    while (1) {
        CLLocationCoordinate2D coord = s.map.userLocation.location.coordinate;
        char *latstr = malloc(sizeof(char) * 10);
        char *lonstr = malloc(sizeof(char) * 10);
        sprintf(latstr,"%+.5f",coord.latitude);
        sprintf(lonstr,"%+.5f",coord.longitude);
        char *lats = createProtocolMessage("LA", latstr, strlen(latstr));
        char *lons = createProtocolMessage("LO", lonstr, strlen(lonstr));
        NSURLRequest *r = [NSURLRequest requestWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://yuaa.kolmas.cz/store.php?uid=%s&devname=%@&data=%s%s", hw_addrs[0], s.deviceName, lats, lons]]];
        if ([NSURLConnection canHandleRequest: r])
            [NSURLConnection connectionWithRequest: r delegate: nil];
        [NSThread sleepForTimeInterval: 30];   
    }
    [pool release];
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
    [self updateView];
}

-(void) updateView {
    SharedData *s = [SharedData instance];
    if ([s autoAdjust] == AUTO) {
        CLLocationCoordinate2D carloc = s.map.userLocation.location.coordinate;
        MKCoordinateSpan spanB;
        spanB.latitudeDelta=0.2;
        spanB.longitudeDelta=0.2;
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

- (void) updateLoc {
    if (lat && lon) {
        CLLocationCoordinate2D loc = {lat, lon};
        [self updateWithCurrentLocation: loc];
    }
}

time_t timer;

- (void)receivedTag:(NSString *)tag withValue:(double)val {
    if ([tag isEqualToString: @"LA"]) {
        timer = time(NULL);
        lat = val;
        [self updateLoc];
    } else if ([tag isEqualToString: @"LN"]) {
        timer = time(NULL);
        lon = val;
        [self updateLoc];
    } else if ([tag isEqualToString: @"MC"]) mcc = val;
    else if ([tag isEqualToString: @"MN"]) mnc = val;
    else if ([tag isEqualToString: @"CD"]) cid = val;
    else if ([tag isEqualToString: @"LC"]) lac = val;
    timer = time(NULL);
    if (mnc && mcc && cid && lac && timer - time(NULL) > TIMEOUT) {
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"http://www.opencellid.org/cell/get?key=f146d401108de36297356ce9d026c8c6&mnc=%d&mcc=%d&lac=%d&cellid=%d", mnc, mcc, lac, cid]];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL: url]; // this could be too slow. also check it's right.
        CLLocationCoordinate2D loc = {[[dict valueForKey: @"lat"] doubleValue], [[dict valueForKey: @"lon"] doubleValue]};
        [self updateWithCurrentLocation: loc];
    }
}

@end
