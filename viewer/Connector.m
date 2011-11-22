//
//  Connector.m
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Connector.h"
#import "IndirectInt.h"
#import "GTMStringEncoding.h"

@implementation Connector
@synthesize delegate;

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

char buffer[1024];
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
}

- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable: {
            while (1) {
                if ([stream hasBytesAvailable]) {
                    uint8_t readloc[1];
                    [stream read:readloc maxLength:1];
                    char c = (char)readloc[0];
                    if (c == '\r') continue;
                    if (c == '\n') {
                        buffer[buffidx] = '\0';
                        [LogViewController logString: [@"Received string: " stringByAppendingString: [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding]]];
                        update_cache(buffer);
                        [self updateData];
                    }
                    if (!(buffidx == 1024 - 1)) buffer[buffidx++] = c;
                }
            }
            break;
        }
    }
}

- (void) updateData {
    SharedData *s = [SharedData instance];
    IndirectInt *bayNum = [[IndirectInt alloc] init];
    [bayNum setIntValue: bayCounter];
    int i;
    for (i=0; i < 23; i++) {
        int j;
        for (j=0; j < 23; j++) {
            if (craft_info[i][j]) {
                char *tag = malloc(sizeof(char) * 2);
                tag[0] = to_char(i+1);
                tag[1] = to_char(j+1);
                NSString *strTag = [NSString stringWithCString:tag encoding:NSASCIIStringEncoding];
                NSString *strVal = [NSString stringWithCString:craft_info[i][j] encoding:NSASCIIStringEncoding];
                free(tag);
                if ([strTag isEqualToString: @"DI"]) {
                    NSData *data = [[GTMStringEncoding rfc4648Base64StringEncoding] decode: strVal];
                    [s.images addObject: data];
                    return;
                }
                double doubleVal = [strVal doubleValue];
                if (doubleVal != 0) {
                    if ([strTag isEqualToString: @"DL"]) {
                        [LogViewController logString: [NSString stringWithFormat:@"Balloon log: %@", strVal]];
                        return;
                    }
                    [LogViewController logString: [NSString stringWithFormat:@"Updating tag %@ with value %@", strTag, strVal]];
                    if ([strTag isEqualToString: @"BB"]) {
                        [bayNum setIntValue: ++bayCounter];
                        if (doubleVal == 1)
                            [s.bayOpenData addObject: bayNum];
                        else
                            [s.bayCloseData addObject: bayNum];
                        return;
                    }
                    if ([strTag isEqualToString: @"YA"]) {
                        s.yaw = doubleVal;
                        return;
                    }
                    if ([strTag isEqualToString: @"PI"]) {
                        s.pitch = doubleVal;
                        return;
                    }
                    if ([strTag isEqualToString: @"RO"]) {
                        s.roll = doubleVal;
                        return;
                    }
                    if (!([strTag isEqualToString: @"LA"] || [strTag isEqualToString: @"LN"])) {
                        StatPoint *stat = [s.balloonStats objectForKey: strTag];
                        if (stat == nil) {
                            stat = [[StatPoint alloc] init];
                            [s.balloonStats setObject: stat forKey: strTag];
                        }
                        [s.statArray addObject: strTag];
                        if (!stat.minval || stat.minval > doubleVal) stat.minval = doubleVal;
                        if (!stat.maxval || stat.maxval < doubleVal) stat.maxval = doubleVal;
                        NSNumber *idx = [NSNumber numberWithInteger: [stat.points count]];
                        NSDictionary *point = [NSDictionary dictionaryWithObjectsAndKeys: idx, @"x", [NSNumber numberWithDouble: doubleVal] , @"y", NULL];
                        [stat.points addObject:point];
                        [stat.bayNumToPoints setObject:point forKey:bayNum];
                        [delegate receivedTag: strTag withValue: doubleVal];
                    }
                }
            }
        }
    }
    [delegate endOfTags];
}

@end