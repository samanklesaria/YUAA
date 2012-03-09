//
//  Processor.h
//  viewer
//
//  Created by Sam Anklesaria on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"
#import "Prefs.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "StatPoint.h"
#import "FlightData.h"

@protocol ConnectorDelegate
@optional
-(void)receivedTag:(NSString *)theData withValue:(double)val;
-(void)receivedPicture;
-(void)receivedLocation;
-(void)serverStatus:(bool) isUp;
-(void)gettingTags: (bool)b;
@end

@interface Processor : NSObject {
    id delegate;
    
    char cachedString[1024];
    int cacheStringIndex;
    parserState pState;
    int bayCounter;
    Prefs *prefs;
    
    NSURL *myUrl;
    NSURL *storeUrl;
    
    int mcc;
    int mnc;
    int lac;
    int cid;
    
    BOOL gotTags;
    
    NSDate *lastUpdate;
}

- (void)updateData: (char) c;
- (void)posterThread;
- (id)initWithPrefs: (Prefs *)p;

@property (retain) id delegate;

@end
