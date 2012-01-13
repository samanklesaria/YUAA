//
//  Connector.m
//  viewer
//
//  Created by Sam Anklesaria on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Connector.h"
#import "IPAddress.h"
#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation Connector

- (id)init
{
    self = [super init];
    if (self) {
        InitAddresses();
        GetHWAddresses();
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
    CFWriteStreamRef writeStream;
    readStream = NULL;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    host = CFHostCreateWithName(NULL, (CFStringRef) mydata.server);
    if (host != NULL) {
        while (readStream == NULL || writeStream == NULL) {
            (void) CFStreamCreatePairWithSocketToCFHost(NULL, host, mydata.port, &readStream, &writeStream);
        }
        CFRelease(host);
        inputStream = [(NSInputStream *)readStream autorelease];
        outputStream = [(NSOutputStream *)writeStream autorelease]; 
        mainstream = inputStream;
        mainOutput = outputStream;
        [mainstream setDelegate:self];
        [mainOutput setDelegate:self];
        [mainstream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [mainstream open];
        [mainOutput open];
        [[NSRunLoop currentRunLoop] run];
    }
    [pool release];
}

- (NSString *)getTag:(char *)mytag {
    NSMutableData *mydata = [NSMutableData dataWithCapacity: 5];
    int i = to_int(mytag[0]) - 1;
    int j = to_int(mytag[1]) - 1;
    if (get_info(i,j)->exists) {
        data *d = get_info(i,j);
        char checksum = crc8(mytag,0,2);
        checksum = crc8(d->content, checksum, d->length);
        [mydata appendBytes: mytag length: 2];
        [mydata appendBytes: (d->content) length: (d->length)];
        [mydata appendBytes: ":" length: 1];
        char *message = (char *)malloc(sizeof(char) * 2);
        sprintf(message, "%.2x", (unsigned char)checksum);
        [mydata appendBytes: message length: 2];
        free(message);
    }
    return [[[[NSString alloc] initWithData: mydata encoding: NSASCIIStringEncoding] autorelease] stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
}

- (NSData *)getImageTag {
    SharedData *s = [SharedData instance];
    return UIImageJPEGRepresentation([s.images lastObject], 1);
}

- (void)sendMessage:(NSString *)str {
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
                if (newtag) {
                    [self updateData: newtag];
                    if (strncmp(newtag, "DI", 2) == 0) {
                        NSData *imageData = [self getImageTag];
                        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"http://yuaa.tc.yale.edu/scripts/upload.php"]];
                        ASIFormDataRequest *r = [ASIFormDataRequest requestWithURL:url];
                        [r setPostValue: [NSString stringWithCString: hw_addrs[0] encoding: NSASCIIStringEncoding] forKey:@"uid"];
                        [r setPostValue: @"berkeley" forKey: @"password"];
                        [r setPostValue: @"balloon" forKey:@"devname"];
                        [r setData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
                        [r setDelegate:self];
                        [r startAsynchronous];
                    } else {
                        if (newtag && strncmp(newtag, "MS", 2) != 0) {
                            NSURLRequest *r = [NSURLRequest requestWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://yuaa.tc.yale.edu/scripts/store.php?uid=%s&password=berkeley&devname=%@&data=%@", hw_addrs[0], @"balloon", [self getTag: newtag]]]];
                            if ([NSURLConnection canHandleRequest: r])
                                [NSURLConnection connectionWithRequest: r delegate: nil];
                        }
                    }
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
        data *db = get_info(b,b);
        int bayVal = [[[[NSString alloc] initWithBytes: db->content length: (NSUInteger)(db->length) encoding:NSASCIIStringEncoding] autorelease] intValue];
        if (bayVal == 1)
            [s.bayOpenData addObject: [NSNumber numberWithInt:bayCounter]];
        else
            [s.bayCloseData addObject: [NSNumber numberWithInt:bayCounter]];
    } else {
        data *d = get_info(to_int(tag[0])-1, to_int(tag[1])-1);
        NSString *strTag = [[[NSString alloc] initWithBytes:tag length: 2 encoding:NSASCIIStringEncoding] autorelease];
        if ([strTag isEqualToString: @"DI"]) {
            int width = 160;
            int height = 120;
            Byte *rawImage = (Byte *)d->content;
            
            char* rgba = (char*)malloc(width*height*4);
            int i;
            for(i=0; i < width*height; ++i) {
                rgba[4*i] = rawImage[3*i];
                rgba[4*i+1] = rawImage[3*i+1];
                rgba[4*i+2] = rawImage[3*i+2];
                rgba[4*i+3] = 0;
            }
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef bitmapContext = CGBitmapContextCreate(
               rgba,
               width,
               height,
               8,
               4*width, // bytesPerRow
               colorSpace,
               kCGImageAlphaNoneSkipLast);
            
            CFRelease(colorSpace);
            CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
            [s.images addObject: [UIImage imageWithCGImage: cgImage]];
            return;
        }
        NSString *strVal = [[[NSString alloc] initWithBytes: d->content length: (NSUInteger)(d->length) encoding:NSASCIIStringEncoding] autorelease];
        if ([strTag isEqualToString: @"MS"]) {
            NSLog(@"Getting a message");
            [strVal enumerateLinesUsingBlock: ^(NSString *str, BOOL *stop) {
                [SharedData logString: str];
            }];
            return;
        }
        double doubleVal = [strVal doubleValue];
        if (doubleVal != 0) {
            NSString *str = [NSString stringWithFormat:@"Updating tag %@ with value %@", strTag, strVal];
            NSLog(@"%@", str);
            [SharedData logString: str];
            if ([strTag isEqualToString: @"YA"])
                s.rotationZ = doubleVal;
            else if ([strTag isEqualToString: @"PI"])
                s.rotationY = doubleVal;
            else if ([strTag isEqualToString: @"RO"])
                s.rotationX = doubleVal;
            else if (!([strTag isEqualToString: @"LA"] || [strTag isEqualToString: @"LN"] || [strTag isEqualToString: @"BB"])) {
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
                [stat.bayNumToPoints setObject:point forKey: [NSNumber numberWithInt:bayCounter]];
            }
            [[s table] reloadData];
            id c = [[SharedData instance] connectorDelegate];
            if (c != NULL) [c receivedTag: strTag withValue: doubleVal];
        }
    }
}

@end