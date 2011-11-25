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
    [mainstream close];
    [mainstream removeFromRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [mainstream release];
    mainstream = nil;
    [super dealloc];
}

#define BUFLEN 1024
char buffer[BUFLEN];
int buffidx = 0;

- (void)handleIO {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    SharedData *mydata = [SharedData instance];
    CFHostRef host;
    CFReadStreamRef readStream;
    readStream = NULL;
    
    NSInputStream *inputStream;
    
    host = CFHostCreateWithName(NULL, (CFStringRef) mydata.server);
    while (readStream == NULL) {
        (void) CFStreamCreatePairWithSocketToCFHost(NULL, host, mydata.port, &readStream, nil);
    }
    CFRelease(host);
    inputStream = [(NSInputStream *)readStream autorelease];
    [inputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    [inputStream open];
    mainstream = inputStream;
    [pool release];
    [[NSRunLoop currentRunLoop] run];
}

- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable: {
            while ([stream hasBytesAvailable]) {
                uint8_t readloc[1];
                [stream read:readloc maxLength:1];
                char c = (char)readloc[0];
                
                if (c == '\r') continue;
                if (c == '\n') {
                    buffer[buffidx] = '\0';
                    buffidx = 0;
                    [LogViewController logString: [@"Received string: " stringByAppendingString: [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding]]];
                    printf("Buffer is %s\n", buffer);
                    update_cache(buffer);
                    [self updateData];
                    return;
                }
                if (!(buffidx == BUFLEN - 1)) buffer[buffidx++] = c;
            }
        }
    }
}

- (void) updateData {
    SharedData *s = [SharedData instance];
    
    if (strstr(updated_tags, "BB")) {
        bayCounter++;
        int b = to_int('B')-1;
        data *db = craft_info[b][b];
        int bayVal = [[[NSString alloc] initWithBytes: db->content length: (NSUInteger)(db->length) encoding:NSASCIIStringEncoding] intValue];
        if (bayVal == 1)
            [s.bayOpenData addObject: [NSNumber numberWithInt:bayCounter]];
        else
            [s.bayCloseData addObject: [NSNumber numberWithInt:bayCounter]];

    }
    int k;
    for (k=0; k < TAGLISTSIZE; k+=2) {
        if (updated_tags[k]) {
            if (strncmp(updated_tags + k, "BB", 2) != 0) {
                int i = to_int(updated_tags[k]) -1;
                int j = to_int(updated_tags[k +1]) -1;
                if (craft_info[i][j]) {
                    data *d = craft_info[i][j];
                    char *tag = malloc(sizeof(char) * 2);
                    tag[0] = to_char(i+1);
                    tag[1] = to_char(j+1);
                    NSString *strTag = [NSString stringWithCString:tag encoding:NSASCIIStringEncoding];
                    if ([strTag isEqualToString: @"DI"]) {
                        NSData *data = [NSData dataWithBytes: d->content length: (NSUInteger)(d->length)];
                        [s.images addObject: data];
                        return;
                    }
                    NSString *strVal = [[NSString alloc] initWithBytes: d->content length: (NSUInteger)(d->length) encoding:NSASCIIStringEncoding];
                    NSLog(@"StrTag: %@, strVal: %@", strTag, strVal);
                    free(tag);
                    double doubleVal = [strVal doubleValue];
                    if (doubleVal != 0) {
                        if ([strTag isEqualToString: @"DL"]) {
                            [LogViewController logString: [NSString stringWithFormat:@"Balloon log: %@", strVal]];
                            continue;
                        }
                        [LogViewController logString: [NSString stringWithFormat:@"Updating tag %@ with value %@", strTag, strVal]];
                        if ([strTag isEqualToString: @"YA"]) {
                            s.yaw = doubleVal;
                            continue;
                        }
                        if ([strTag isEqualToString: @"PI"]) {
                            s.pitch = doubleVal;
                            continue;
                        }
                        if ([strTag isEqualToString: @"RO"]) {
                            s.roll = doubleVal;
                            continue;
                        }
                        if (!([strTag isEqualToString: @"LA"] || [strTag isEqualToString: @"LN"])) {
                            StatPoint *stat = [s.balloonStats objectForKey: strTag];
                            if (stat == nil) {
                                stat = [[StatPoint alloc] init];
                                [s.balloonStats setObject: stat forKey: strTag];
                            }
                            if (![s.statSet containsObject: strTag]) {
                                [s.statArray addObject: strTag];
                                [s.statSet addObject:strTag];
                            }
                            if (!stat.minval || stat.minval > doubleVal) stat.minval = doubleVal;
                            if (!stat.maxval || stat.maxval < doubleVal) stat.maxval = doubleVal;
                            NSNumber *idx = [NSNumber numberWithInteger: [stat.points count]];
                            NSDictionary *point = [NSDictionary dictionaryWithObjectsAndKeys: idx, @"x", [NSNumber numberWithDouble: doubleVal] , @"y", NULL];
                            [stat.points addObject:point];
                            [stat.bayNumToPoints setObject:point forKey: [NSNumber numberWithInt:bayCounter]];
                            id c = [[SharedData instance] connectorDelegate];
                            if (c != NULL)
                                [c receivedTag: strTag withValue: doubleVal];
                        }
                    }
                }
            }
        }
    }
    id c = [[SharedData instance] connectorDelegate];
    if (c != NULL) [c endOfTags];
    [[[SharedData instance] table] reloadData];
}

@end