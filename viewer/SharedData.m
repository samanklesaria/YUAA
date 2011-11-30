//
//  SharedData.m
//  viewer
//
//  Created by Sam Anklesaria on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SharedData.h"
#import "Connector.h"
#import "StatPoint.h"

@implementation SharedData
@synthesize rotationX;
@synthesize rotationY;
@synthesize rotationZ;
@synthesize mapType;
@synthesize server;
@synthesize port;
@synthesize remoteServer;
@synthesize remotePort;
@synthesize autoAdjust;
@synthesize logData;
@synthesize images;
@synthesize bayOpenData;
@synthesize bayCloseData;
@synthesize balloonStats;
@synthesize phoneNumber;
@synthesize statArray;
@synthesize plistData;
@synthesize grapher;
@synthesize connectorDelegate;
@synthesize table;
@synthesize lshift;
@synthesize vshift;

- (id)init
{
    self = [super init];
    if (self) {
        logData = [[NSMutableArray alloc] initWithObjects:@"Starting app...", nil];
        autoAdjust = YES;
        mapType = MKMapTypeStandard;
        grapher = [[Grapher alloc] initWithNibName:@"Grapher" bundle:nil];
        bayOpenData = [[NSMutableArray alloc] initWithCapacity:5];
        bayCloseData = [[NSMutableArray alloc] initWithCapacity:5];
        images = [[NSMutableArray alloc] initWithCapacity:10];
        statArray = [[NSMutableArray alloc] initWithCapacity:50];
        balloonStats = [[NSMutableDictionary alloc] initWithCapacity:50];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"protocol.plist"];
        plistData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
        rotationX = 0;
        rotationY = 0;
        rotationZ = 0;
        StatPoint *ALstat = [[StatPoint alloc] init];
        ALstat.minval = 0; ALstat.maxval = 100;
        StatPoint *TIstat = [[StatPoint alloc] init];
        TIstat.minval = 10; TIstat.maxval = 11;
        [balloonStats setObject: ALstat forKey: @"AL"];
        [balloonStats setObject: TIstat forKey: @"TI"];
    }
    return self;
}

static SharedData *gInstance = NULL;

+ (SharedData *)instance
{
    @synchronized(self)
    {
        if (gInstance == NULL)
            gInstance = [[self alloc] init];
    }
    
    return(gInstance);
}

@end
