//
//  Connector.h
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharedData.h"
#import "LogViewController.h"
#import "Parser.h"
#import "StatPoint.h"

@protocol ConnectorDelegate
@required
-(void)receivedTag:(NSString *)theData withValue:(double)val;
-(void)endOfTags;
@end

@interface Connector : NSObject <NSStreamDelegate> {
    bool shouldEndConnection;
    NSStream *mainstream;
    int bayCounter;
}

- (void)updateData;
- (void)handleIO;

@end
