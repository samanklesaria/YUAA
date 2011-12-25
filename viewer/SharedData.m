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
@synthesize map;
@synthesize rotationX;
@synthesize rotationY;
@synthesize rotationZ;
@synthesize server;
@synthesize port;
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
@synthesize logViewController;
@synthesize ushift;
@synthesize deviceName;
@synthesize con;

- (id)init
{
    self = [super init];
    if (self) {
        logData = [[NSMutableArray alloc] initWithObjects:@"Starting app...", nil];
        autoAdjust = AUTO;
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
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serverString = [defaults stringForKey: @"server"];
    if (serverString != nil) {
        self.server = serverString;
    }
    NSString *portString = [defaults objectForKey: @"port"];
    if (portString != nil) {
        self.port = [portString integerValue];
    }
    NSString *phoneNum = [defaults objectForKey: @"phoneNumber"];
    if (phoneNum != nil) {
        self.phoneNumber = phoneNum;
    }
    NSString *devName = [defaults objectForKey: @"deviceName"];
    if (devName != nil) {
        self.deviceName = devName;
    }
    NSInteger adjVal = [defaults integerForKey: @"autoAdjust"];
    self.autoAdjust = (enum mapAdjust)adjVal;
    [self updateConnector];
    return self;
}

- (void) updateConnector {
    if (self.server && [self.server length] > 0 && self.port > 0) {
        [self.con release];
        [self setCon: [[[Connector alloc] init] autorelease]];
    }
}

/*
- (void)dealloc {
    self.map = nil;
    self.logViewController = nil;
    self.table = nil;
    self.connectorDelegate = nil;
    self.grapher = nil;
    self.plistData = nil;
    self.phoneNumber = nil;
    self.server = nil;
    self.bayOpenData = nil;
    self.bayCloseData = nil;
    self.images = nil;
    self.statArray = nil;
    self.balloonStats = nil;
    self.logData =  nil;
}
*/

static SharedData *gInstance = NULL;


+ (void)logString:(NSString*)str
{
    SharedData *a = [SharedData instance];
    [a.logData addObject: str]; // space leak? oh well.
    [a.logViewController reloadLog];
    // do we need to reloadData on the table?
}

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
