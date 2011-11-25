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
@synthesize yaw;
@synthesize pitch;
@synthesize roll;
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
        bayOpenData = [[NSMutableDictionary alloc] initWithCapacity:5];
        bayCloseData = [[NSMutableDictionary alloc] initWithCapacity:5];
        images = [[NSMutableArray alloc] initWithCapacity:50];
        statArray = [[NSMutableArray alloc] initWithCapacity:10];
        balloonStats = [[NSMutableDictionary alloc] initWithCapacity:10];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"Info.plist"];
        plistData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
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
