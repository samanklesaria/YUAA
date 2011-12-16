//
//  SharedData.h
//  viewer
//
//  Created by Sam Anklesaria on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Grapher.h"

enum mapAdjust {
    AUTO,
    CAR,
    MANUAL
};

@class LogViewController;

@interface SharedData : NSObject {
    // arrays
    NSMutableArray *logData;
    NSDictionary *plistData;
    
    //misc
    Grapher *grapher;
    UITableView *table;
    id connectorDelegate;
    float lshift;
    float ushift;
    float vshift;
    LogViewController * logViewController;
    MKMapView *map;
    
    // prefs
    NSString *server;
    NSInteger port;
    enum mapAdjust autoAdjust;
    NSString *phoneNumber;
    
    // stats
    float rotationX;
    float rotationY;
    float rotationZ;
    NSMutableArray *images;
    NSMutableArray *bayOpenData;
    NSMutableArray *bayCloseData;
    NSMutableDictionary *balloonStats;
    NSMutableArray *statArray;
}


@property (retain) MKMapView *map;
@property (retain) LogViewController *logViewController;
@property float lshift;
@property float ushift;
@property float vshift;
@property (retain) UITableView *table;
@property (retain) id connectorDelegate;
@property float rotationX;
@property float rotationY;
@property float rotationZ;
@property (retain) Grapher *grapher;
@property (retain) NSDictionary *plistData;
@property (retain) NSString *phoneNumber;
@property (retain) NSString *server;
@property NSInteger port;
@property enum mapAdjust autoAdjust;
@property (retain) NSMutableArray *bayOpenData;
@property (retain) NSMutableArray *bayCloseData;
@property (retain) NSMutableArray *images;
@property (retain) NSMutableArray *statArray;
@property (retain) NSMutableDictionary *balloonStats;
@property (retain) NSMutableArray *logData;

+ (SharedData *)instance;

+ (void)logString:(NSString *)logString;


@end
