//
//  StatPoint.m
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatPoint.h"

@implementation StatPoint
@synthesize bayNumToPoints;
@synthesize minval;
@synthesize maxval;
@synthesize points;

- (id)init
{
    self = [super init];
    if (self) {
        points = [[NSMutableArray alloc] initWithCapacity: 400];
        bayNumToPoints = [[NSMutableDictionary alloc] initWithCapacity: 400];
    }
    
    return self;
}

@end
