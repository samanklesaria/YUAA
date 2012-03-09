//
//  FlightData.h
//  viewer
//
//  Created by Sam Anklesaria on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightData : NSObject {
    NSMutableArray *netLogData;
    NSMutableArray *parseLogData;
    NSMutableString *akpLogData;
    NSDictionary *plistData;
    NSMutableArray *pictures;
    NSMutableDictionary *balloonStats;
    NSMutableArray *nameArray;
    NSMutableArray *bayOpenData;
    NSMutableArray *bayCloseData;
    
    NSDate *lastIMUTime;
    NSDate *lastImageTime;
    NSDate *lastLocTime;
    
    float rotationX;
    float rotationY;
    float rotationZ;

    double lat;
    double lon;
}

+ (FlightData *)instance;

@property (retain) NSMutableArray *pictures;
@property (retain) NSMutableArray *nameArray;
@property (retain) NSMutableDictionary *balloonStats;
@property (retain) NSDate *lastIMUTime;
@property (retain) NSDate *lastImageTime;
@property (retain) NSDate *lastLocTime;
@property (retain) NSDictionary *plistData;
@property (retain) NSMutableArray *parseLogData;
@property (retain) NSMutableArray *netLogData;
@property (retain) NSMutableString *akpLogData;

@property float rotationX;
@property float rotationY;
@property float rotationZ;
@property double lat;
@property double lon;
@end
