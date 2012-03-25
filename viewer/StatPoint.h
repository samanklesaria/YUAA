//
//  StatPoint.h
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatPoint : NSObject {
    float minval;
    float maxval;
    NSMutableArray *points;
    NSMutableDictionary *bayNumToPoints;
    NSDate *lastTime;
}

@property (retain) NSDate *lastTime;
@property float minval;
@property float maxval;
@property (retain) NSMutableArray *points;
@property (retain) NSMutableDictionary *bayNumToPoints;

@end
