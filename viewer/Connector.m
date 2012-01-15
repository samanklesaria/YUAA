//
//  Connector.m
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Connector.h"
#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "PicViewController.h"

@implementation Connector

- (id)init
{
    self = [super init];
    if (self) {
        bayCounter = 0;
        [self retain];
        [NSThread detachNewThreadSelector:@selector(handleIO) toTarget:self withObject:nil];
        [NSThread detachNewThreadSelector:@selector(postItToServer) toTarget:self withObject:nil];
        [self release];
    }
    return self;
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
    [super dealloc];
}

- (void)handleIO {
    // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    SharedData *mydata = [SharedData instance];
    CFHostRef host;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    readStream = NULL;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    host = CFHostCreateWithName(NULL, (CFStringRef) mydata.server);
    if (host != NULL) {
        while (readStream == NULL || writeStream == NULL) {
            (void) CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, host, mydata.port, &readStream, &writeStream);
        }
        CFRelease(host);
        inputStream = [(NSInputStream *)readStream autorelease];
        outputStream = [(NSOutputStream *)writeStream autorelease]; 
        mainstream = inputStream; // Is this needed?
        mainOutput = outputStream;
        [mainstream setDelegate:self];
        [mainOutput setDelegate:self];
        [mainstream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [mainstream open];
        [mainOutput open];
        [[NSRunLoop currentRunLoop] run];
    }
    // [pool release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Response was: %@", [request responseString]);
    // NSLog(@"Success uploading image");
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Failed uploading image");
}

- (NSString *)getTag:(char *)mytag {
    NSMutableData *mydata = [NSMutableData dataWithCapacity: 5];
    int i = to_int(mytag[0]) - 1;
    int j = to_int(mytag[1]) - 1;
    data *d = get_info(i,j);
    char checksum = crc8(mytag,0,2);
    checksum = crc8(d->content, checksum, d->length);
    [mydata appendBytes: mytag length: 2];
    [mydata appendBytes: (d->content) length: (d->length)];
    [mydata appendBytes: ":" length: 1];
    char message[3];
    sprintf(message, "%.2x", (unsigned char)checksum);
    [mydata appendBytes: message length: 2];
    return [[[[NSString alloc] initWithData: mydata encoding: NSASCIIStringEncoding] autorelease] stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
}

- (void)sendMessage:(NSString *)str {
    NSStreamStatus status = [mainOutput streamStatus];
    if (status == NSStreamStatusOpen || status == NSStreamStatusWriting)
        [mainOutput write: [[str dataUsingEncoding: NSASCIIStringEncoding] bytes] maxLength: [str length]];
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
                    if (newtag && [self isKindOfClass: [Connector class]]) {
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
                NSLog(@"About to release due to end");
                if ([self isKindOfClass: [Connector class]]) [self handleIO];
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
                NSLog(@"About to release due to err");
                // do I know if leaks? huh?
                if ([self isKindOfClass: [Connector class]]) [self handleIO];
                break;
            }
        }
}

- (void) postItToServer {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    SharedData *s = [SharedData instance];
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [SharedData instance].theId);
    char *latstr = malloc(sizeof(char) * 20);
    char *lonstr = malloc(sizeof(char) * 20);
    while (1) {
         CLLocationCoordinate2D coord = s.map.userLocation.location.coordinate;
         sprintf(latstr,"%+.5f",coord.latitude);
         sprintf(lonstr,"%+.5f",coord.longitude);
         char *lats = createProtocolMessage("LA", latstr, strlen(latstr));
         char *lons = createProtocolMessage("LO", lonstr, strlen(lonstr));
         NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [SharedData instance].theId);
         NSURLRequest *r = [NSURLRequest requestWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://yuaa.kolmas.cz/store.php?uid=%s&devname=%@&data=%s%s", uuid, s.deviceName, lats, lons]]];
         if ([NSURLConnection canHandleRequest: r])
         [NSURLConnection connectionWithRequest: r delegate: nil];

        int i;
        for (i=0; i < 24; i++) {
            int j;
            for (j=0; j < 24; j++) {
                if (get_info(i,j)) {
                    char newtag[3];
                    newtag[0] = to_char(i+1);
                    newtag[1] = to_char(j+1);
                    if (strncmp(newtag, "IM", 2) == 0) {
                        NSData *imageData = [s.picViewController getImageTag];
                        if (imageData) {
                            NSURL *url = [NSURL URLWithString: @"http://yuaa.tc.yale.edu/scripts/upload.php"];
                            ASIFormDataRequest *r = [ASIFormDataRequest requestWithURL:url];
                            [r setPostValue: uuid forKey:@"uid"];
                            [r setPostValue: @"berkeley" forKey: @"password"];
                            [r setPostValue: @"balloon" forKey:@"devname"];
                            [r setData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
                            [r setDelegate:self];
                            [r startAsynchronous];
                        }
                        remove_tag(i,j);
                    }
                    else if (strncmp(newtag, "MS", 2) != 0) {
                            NSURLRequest *r = [NSURLRequest requestWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://yuaa.tc.yale.edu/scripts/store.php?uid=%@&password=berkeley&devname=%@&data=%@", uuid, @"balloon", [self getTag: newtag]]]];
                            if ([NSURLConnection canHandleRequest: r])
                                [NSURLConnection connectionWithRequest: r delegate: nil];
                    }
                }
            }
        }
        [NSThread sleepForTimeInterval: 1];
    }
    free(latstr);
    free(lonstr);
    [uuid release];
    [pool release];
}

- (void) updateData: (char *)tag {
    /*
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
	app.networkActivityIndicatorVisible = NO;
     */
    
    SharedData *s = [SharedData instance];
    if (strncmp(tag, "BB", 2) == 0) {
        bayCounter++;
        int b = to_int('B')-1;
        data *db = get_info(b,b);
        int bayVal = [[[[NSString alloc] initWithBytes: db->content length: (NSUInteger)(db->length) encoding:NSASCIIStringEncoding] autorelease] intValue];
        if (bayVal == 1)
            [s.bayOpenData addObject: [NSNumber numberWithInt:bayCounter]];
        else
            [s.bayCloseData addObject: [NSNumber numberWithInt:bayCounter]];
    } else {
        data *d = get_info(to_int(tag[0])-1, to_int(tag[1])-1);
        NSString *strTag = [[[NSString alloc] initWithBytes:tag length: 2 encoding:NSASCIIStringEncoding] autorelease];
        [[s table] reloadData];
        if ([strTag isEqualToString: @"IM"]) {
            [SharedData logString: @"Getting an image"];
            s.lastImageTime = [NSDate date];
            int width = 80;
            int height = 60;
            Byte *rawImage = (Byte *)d->content;
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
            CGContextRef bitmapContext = CGBitmapContextCreate(
               rawImage,
               width,
               height,
               8,
               width,
               colorSpace,
               kCGImageAlphaNone);
            
            CFRelease(colorSpace);
            CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
            [s.picViewController addImage: [UIImage imageWithCGImage: cgImage]];
            return;
        }
        NSString *strVal = [[[NSString alloc] initWithBytes: d->content length: (NSUInteger)(d->length) encoding:NSASCIIStringEncoding] autorelease];
        NSString *str = [NSString stringWithFormat: @"Updating tag %@ with value %@", strTag, strVal];
        [SharedData logString: str];
        if ([strTag isEqualToString: @"MS"]) {
            [SharedData logString: @"Getting a message"];
            [strVal enumerateLinesUsingBlock: ^(NSString *str, BOOL *stop) {
                [SharedData logString: str];
            }];
            return;
        }
        double doubleVal = [strVal doubleValue];
        if (doubleVal != 0 || [strTag isEqualToString: @"GS"]) {
            
            if ([strTag isEqualToString: @"YA"]) {
                s.rotationZ = doubleVal;
                s.lastIMUTime = [NSDate date];
            }
            else if ([strTag isEqualToString: @"PI"]) {
                s.rotationY = doubleVal;
                s.lastIMUTime = [NSDate date];
            }
            else if ([strTag isEqualToString: @"RO"]) {
                s.rotationX = doubleVal;
                s.lastIMUTime = [NSDate date];
            }
            else if (!([strTag isEqualToString: @"LA"] || [strTag isEqualToString: @"LO"] || [strTag isEqualToString: @"BB"])) {
                StatPoint *stat = [s.balloonStats objectForKey: strTag];
                if (![s.balloonStats objectForKey: strTag]) {
                    [s.statArray addObject: strTag];
                }
                if (stat == nil) {
                    stat = [[[StatPoint alloc] init] autorelease];
                    [s.balloonStats setObject: stat forKey: strTag];
                }
                if (!stat.minval || stat.minval > doubleVal) stat.minval = doubleVal;
                if (!stat.maxval || stat.maxval < doubleVal) stat.maxval = doubleVal;
                NSNumber *idx = [NSNumber numberWithInteger: [stat.points count]];
                NSDictionary *point = [NSDictionary dictionaryWithObjectsAndKeys: idx, @"x", [NSNumber numberWithDouble: doubleVal] , @"y", NULL];
                [stat.points addObject:point];
                stat.lastTime = [NSDate date];
                [stat.bayNumToPoints setObject:point forKey: [NSNumber numberWithInt:bayCounter]];
            }
            id c = [[SharedData instance] connectorDelegate];
            if (c != NULL) [c receivedTag: strTag withValue: doubleVal];
        }
    }
}

@end