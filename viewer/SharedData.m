//
//  SharedData.m
//  viewer
//
//  Created by Sam Anklesaria on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SharedData.h"
#import "Connector.h"

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
@synthesize statSet;

- (id)init
{
    self = [super init];
    if (self) {
        logData = [[NSMutableArray alloc] initWithObjects:@"Starting app...", nil];
        port = 80;
        remotePort = 80;
        autoAdjust = YES;
        server = @"localhost";
        mapType = MKMapTypeStandard;
        grapher = [[Grapher alloc] initWithNibName:@"Grapher" bundle:nil];
        bayOpenData = [[NSMutableArray alloc] initWithCapacity:5];
        bayCloseData = [[NSMutableArray alloc] initWithCapacity:5];
        images = [[NSMutableArray alloc] initWithCapacity:50];
        statArray = [[NSMutableArray alloc] initWithCapacity:10];
        statSet = [[NSMutableSet alloc] initWithCapacity:10];
        balloonStats = [[NSMutableDictionary alloc] initWithCapacity:10];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"protocol.plist"];
        plistData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
        rotationX = 0;
        rotationY = 0;
        rotationZ = 0;
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
