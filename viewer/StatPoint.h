//
//  StatPoint.h
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatPoint : NSObject {
    double minval;
    double maxval;
    NSMutableArray *points;
    NSMutableDictionary *bayNumToPoints;
    NSDate *lastTime;
}

@property (retain) NSDate *lastTime;
@property double minval;
@property double maxval;
@property (retain) NSMutableArray *points;
@property (retain) NSMutableDictionary *bayNumToPoints;

@end
