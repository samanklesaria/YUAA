//
//  Prefs.h
//  viewer
//
//  Created by Sam Anklesaria on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Prefs : NSObject {
    NSString *uuid;
    NSString *localServer;
    int port;
    NSString *remoteServer;
    int autoAdjust;
    NSString *deviceName;
    NSString *postServer;
}

@property (retain) NSString *uuid;
@property (retain) NSString *localServer;
@property int port;
@property (retain) NSString *remoteServer;
@property bool autoUpdate;
@property int autoAdjust;
@property (retain) NSString *deviceName;
@property (retain) NSString *postServer;

@end
