//
//  Connector.h
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prefs.h"
#import "Processor.h"

@protocol ConnectorDelegate
@optional
-(void)gotAkpString: (NSString *)akp;
@end

@class BalloonMapLogic;

@interface Connector : NSObject <NSStreamDelegate> {
    id delegate;
    NSInputStream *mainstream;
    NSOutputStream *mainOutput;
    bool erred;
    Prefs *prefs;
    Processor *processor;
}

- (void)handleIO;
- (void)ioThread;
- (id)initWithProcessor: (Processor *)p prefs: (Prefs *)pr;

- (void)sendMessage:(NSString *)str;

@property (retain) id delegate;

@end
