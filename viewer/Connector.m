//
//  Connector.m
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Connector.h"
#import <UIKit/UIKit.h>
#import "FlightData.h"

@implementation Connector

- (id)initWithProcessor: (Processor *)p prefs: (Prefs *)pr
{
    self = [self init];
    if (self) {
        processor = p;
        prefs = pr;
        [NSThread detachNewThreadSelector: @selector(ioThread) toTarget: self withObject:nil];
    }
    return self;
}


- (void)ioThread {
    [self handleIO];
    [[NSRunLoop currentRunLoop] run];
}


- (void) dealloc {
    NSLog(@"Connector being deallocated");
    if (mainstream) {
        [mainstream close];
        [mainstream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
        [mainstream release];
        mainstream = nil;
    }
    if (mainOutput) {
        [mainOutput close];
        [mainstream release];
        mainstream = nil;
    }
    [processor release];
    [prefs release];
    [super dealloc];
}

- (void)handleIO {
    NSLog(@"Handing IO");
    if (self) NSLog(@"I exist");
    if (self) {
        CFHostRef host;
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        readStream = NULL;
        
        NSInputStream *inputStream;
        NSOutputStream *outputStream;
        
        host = CFHostCreateWithName(NULL, (CFStringRef) prefs.localServer);
        if (host != NULL) {
            while (readStream == NULL || writeStream == NULL) {
                (void) CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, prefs.port, &readStream, &writeStream);
            }
            NSLog(@"I made some streams");
            CFRelease(host);
            inputStream = (NSInputStream *)readStream;
            outputStream = (NSOutputStream *)writeStream; 
            [mainstream close];
            [mainstream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
            [mainstream release];
            mainstream = inputStream;
            [mainOutput close];
            [mainOutput release];
            mainOutput = outputStream;
            [mainstream setDelegate:self];
            [mainOutput setDelegate:self];
            NSRunLoop *r = [NSRunLoop currentRunLoop];
            [mainstream scheduleInRunLoop: r
                                   forMode:NSDefaultRunLoopMode];
            [mainstream open];
            [mainOutput open];
            NSLog(@"I opened some streams");
        }
    }
}

- (void)sendMessage:(NSString *)str {
    NSLog(@"I'm sending a message");
    NSStreamStatus status = [mainOutput streamStatus];
    if (status == NSStreamStatusOpen || status == NSStreamStatusWriting)
        [mainOutput write: [[str dataUsingEncoding: NSASCIIStringEncoding] bytes] maxLength: [str length]];
}

- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)eventCode {
        switch(eventCode) {
            case NSStreamEventHasBytesAvailable: {
                NSLog(@"Bytes are found!");
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                erred = 0;
                while ([stream hasBytesAvailable]) {
                    uint8_t readloc[256];
                    int len = [stream read:readloc maxLength:256];
                    NSString *toAppend = [[NSString alloc] initWithBytes: readloc length: len encoding:NSASCIIStringEncoding];
                    FlightData *f = [FlightData instance];
                    [f.akpLogData appendString: toAppend];
                    int i;
                    for (i=0; i < len; i++)
                        [processor updateData: readloc[i]];
                }
                break;
            }
            case NSStreamEventEndEncountered:
            {
                NSLog(@"Got end");
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                [[FlightData instance].netLogData addObject: @"Encountered end of input stream."];
                [stream close];
                [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
                [self handleIO];
                break; 
            }
            case NSStreamEventErrorOccurred:
            {
                NSLog(@"Err occurred");
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                NSLog(@"Error: %@", [[stream streamError] localizedDescription]);
                if (!erred) {
                    [[FlightData instance].netLogData addObject: @"Streaming Error. Trying again."];
                    erred = 1;
                }
                [NSThread sleepForTimeInterval: 1];
                [stream close];
                [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
                [self handleIO];
                break;
            }
        }
}

@end