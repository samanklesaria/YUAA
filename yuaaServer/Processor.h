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

@protocol ProcessorDelegate
@optional
-(void)receivedTag:(NSString *)theData withValue:(double)val;
-(void)receivedPicture;
-(void)receivedLocation;
-(void)serverStatus:(bool) isUp;
-(void)gettingTags: (bool)b;
@end

char* formattedString(char* format, ...);

@interface Processor : NSObject <NSXMLParserDelegate> {
    id delegate;
    
    int okToSend;
    int okToGet;
    BOOL cellNew;
    BOOL threadAvailable;
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

- (void)addLocationToCache;
- (void)updateData: (char) c fromSerial: (int) fromSerial;
- (void)posterThread;
- (id)initWithPrefs: (Prefs *)p;
- (NSData *)lastData;
- (void) handleRequestFinished: (ASIHTTPRequest *) request;

@property (retain) id delegate;

@end
