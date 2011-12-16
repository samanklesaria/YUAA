//
//  Connector.m
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Connector.h"

@implementation Connector

- (id)init
{
    self = [super init];
    if (self) {
        bayCounter = 0;
        [NSThread detachNewThreadSelector:@selector(handleIO) toTarget:self withObject:nil]; 
    }
    
    return self;
}


- (void) dealloc {
    if (mainstream) {
        [mainstream close];
        [mainstream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
        [mainstream release];
        mainstream = nil;
    }
    [super dealloc];
}

- (void)handleIO {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    SharedData *mydata = [SharedData instance];
    CFHostRef host;
    CFReadStreamRef readStream;
    readStream = NULL;
    
    NSInputStream *inputStream;
    
    host = CFHostCreateWithName(NULL, (CFStringRef) mydata.server);
    if (host != NULL) {
        while (readStream == NULL) {
            (void) CFStreamCreatePairWithSocketToCFHost(NULL, host, mydata.port, &readStream, nil);
        }
        CFRelease(host);
        inputStream = [(NSInputStream *)readStream autorelease];
        mainstream = inputStream;
        [mainstream setDelegate:self];
        [mainstream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [mainstream open];
        [[NSRunLoop currentRunLoop] run];
    }
    [pool release];
}

- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"Got bytes!");
            erred = 0;
            while ([stream hasBytesAvailable]) {
                uint8_t readloc;
                [stream read:&readloc maxLength:1];
                char *newtag = handle_char((char)readloc);
                if (newtag) {
                    [self updateData: newtag];
                }
            }
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [SharedData logString: @"Encountered end of input stream."];
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [stream release];
            [self handleIO];
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"Error: %@", [[stream streamError] localizedDescription]);
            if (!erred) {
                [SharedData logString: @"Streaming Error. Trying again."];
                erred = 1;
            }
            [NSThread sleepForTimeInterval: 10];
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [stream release];
            stream = nil;
            [self handleIO];
            break;
        }
    }
}

- (void) updateData: (char *)tag {
    SharedData *s = [SharedData instance];
    if (strncmp(tag, "BB", 2) == 0) {
        bayCounter++;
        int b = to_int('B')-1;
        data *db = craft_info[b][b];
        int bayVal = [[[NSString alloc] initWithBytes: db->content length: (NSUInteger)(db->length) encoding:NSASCIIStringEncoding] intValue];
        if (bayVal == 1)
            [s.bayOpenData addObject: [NSNumber numberWithInt:bayCounter]];
        else
            [s.bayCloseData addObject: [NSNumber numberWithInt:bayCounter]];
    } else {
        data *d = craft_info[to_int(tag[0])-1][to_int(tag[1])-1];
        NSString *strTag = [[NSString alloc] initWithBytes:tag length: 2 encoding:NSASCIIStringEncoding];
        if ([strTag isEqualToString: @"DI"]) {
            NSData *data = [NSData dataWithBytes: d->content length: (NSUInteger)(d->length)];
            [s.images addObject: data];
            return;
        }
        NSString *strVal = [[NSString alloc] initWithBytes: d->content length: (NSUInteger)(d->length) encoding:NSASCIIStringEncoding];
        double doubleVal = [strVal doubleValue];
        if (doubleVal != 0) {
            [SharedData logString: [NSString stringWithFormat:@"Updating tag %@ with value %@", strTag, strVal]];
            if ([strTag isEqualToString: @"DL"])
                [SharedData logString: [NSString stringWithFormat:@"Balloon log: %@", strVal]];
            else if ([strTag isEqualToString: @"YA"])
                s.rotationZ = doubleVal;
            else if ([strTag isEqualToString: @"PI"])
                s.rotationY = doubleVal;
            else if ([strTag isEqualToString: @"RO"])
                s.rotationX = doubleVal;
            else if (!([strTag isEqualToString: @"LA"] || [strTag isEqualToString: @"LN"])) {
                StatPoint *stat = [s.balloonStats objectForKey: strTag];
                if (![s.balloonStats objectForKey: strTag]) {
                    [s.statArray addObject: strTag];
                }
                if (stat == nil) {
                    stat = [[StatPoint alloc] init];
                    [s.balloonStats setObject: stat forKey: strTag];
                }
                if (!stat.minval || stat.minval > doubleVal) stat.minval = doubleVal;
                if (!stat.maxval || stat.maxval < doubleVal) stat.maxval = doubleVal;
                NSNumber *idx = [NSNumber numberWithInteger: [stat.points count]];
                NSDictionary *point = [NSDictionary dictionaryWithObjectsAndKeys: idx, @"x", [NSNumber numberWithDouble: doubleVal] , @"y", NULL];
                [stat.points addObject:point];
                [stat.bayNumToPoints setObject:point forKey: [NSNumber numberWithInt:bayCounter]];
            }
            [[s table] reloadData];
            id c = [[SharedData instance] connectorDelegate];
            if (c != NULL) [c receivedTag: strTag withValue: doubleVal];
        }
    }
}

@end