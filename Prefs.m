//
//  Prefs.m
//  viewer
//
//  Created by Sam Anklesaria on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Prefs.h"

@implementation Prefs
@synthesize uuid;
@synthesize localServer;
@synthesize port;
@synthesize remoteServer;
@synthesize autoAdjust;
@synthesize autoUpdate;
@synthesize deviceName;
@synthesize postServer;

- (id)init {
    self = [super init];
    if (self) {
        CFUUIDRef myuid = CFUUIDCreate(kCFAllocatorDefault);
        uuid = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, myuid);
        CFRelease(myuid);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        localServer = [defaults stringForKey: @"server"];
        port = [defaults integerForKey: @"port"];
        deviceName = [defaults stringForKey: @"deviceName"];
        autoAdjust = (int)[defaults integerForKey: @"autoAdjust"];
        postServer = [defaults stringForKey: @"postServer"];
    }
    return self;
}

- (void) dealloc {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    [super dealloc];
}
@end
