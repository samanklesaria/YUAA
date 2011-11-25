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

@interface SharedData : NSObject {
    // arrays
    NSMutableArray *logData;
    NSDictionary *plistData;
    
    //misc
    Grapher *grapher;
    id connectorDelegate;
    
    // prefs
    NSString *server;
    NSString *remoteServer;
    NSInteger port;
    NSInteger remotePort;
    MKMapType mapType;
    bool autoAdjust;
    NSString *phoneNumber;
    
    // stats
    float yaw;
    float pitch;
    float roll;
    NSMutableArray *images;
    NSMutableArray *bayOpenData;
    NSMutableArray *bayCloseData;
    NSMutableDictionary *balloonStats;
    NSMutableArray *statArray;
}

@property (retain) id connectorDelegate;
@property float yaw;
@property float pitch;
@property float roll;
@property (retain) Grapher *grapher;
@property (retain) NSDictionary *plistData;
@property (retain) NSString *phoneNumber;
@property (retain) NSString *server;
@property (retain) NSString *remoteServer;
@property NSInteger port;
@property NSInteger remotePort;
@property MKMapType mapType;
@property bool autoAdjust;
@property (retain) NSMutableArray *bayOpenData;
@property (retain) NSMutableArray *bayCloseData;
@property (retain) NSMutableArray *images;
@property (retain) NSMutableArray *statArray;
@property (retain) NSMutableDictionary *balloonStats;
@property (retain) NSMutableArray *logData;

+ (SharedData *)instance;

@end
