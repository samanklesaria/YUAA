//
//  FlightData.m
//  viewer
//
//  Created by Sam Anklesaria on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlightData.h"

@implementation FlightData

@synthesize plistData;
@synthesize pictures;
@synthesize nameArray;
@synthesize balloonStats;
@synthesize lastIMUTime;
@synthesize lastImageTime;
@synthesize rotationX;
@synthesize rotationY;
@synthesize rotationZ;
@synthesize netLogData;
@synthesize parseLogData;
@synthesize lastLocTime;
@synthesize lat;
@synthesize lon;
@synthesize akpLogData;

- (id)init
{
    self = [super init];
    if (self) {
        pictures = [[NSMutableArray alloc] init];
        bayOpenData = [[NSMutableArray alloc] initWithCapacity:5];
        bayCloseData = [[NSMutableArray alloc] initWithCapacity:5];
        nameArray = [[NSMutableArray alloc] initWithCapacity:50];
        balloonStats = [[NSMutableDictionary alloc] initWithCapacity:50];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"protocol" ofType:@"plist"];
        plistData = [[NSDictionary dictionaryWithContentsOfFile:filePath] retain];        
        netLogData = [[NSMutableArray alloc] initWithCapacity: 128];
        akpLogData = [[NSMutableString alloc] initWithCapacity:1024];
        parseLogData = [[NSMutableArray alloc] initWithCapacity: 128];
    }
    return self;
}

static FlightData *gInstance = NULL;

+ (FlightData *)instance
{
    @synchronized(self)
    {
        if (gInstance == NULL) {
            gInstance = [[self alloc] init];
        }
    }
    
    return(gInstance);
}

@end
