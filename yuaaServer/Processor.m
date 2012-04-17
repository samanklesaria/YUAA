//
//  Processor.m
//  viewer
//
//  Created by Sam Anklesaria on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Processor.h"

//Mallocs a formatted string based on printf
char* formattedString(char* format, ...)
{
    va_list args;
    va_start(args, format);
    //Include null byte in length
    int length = 1 + vsnprintf(NULL, 0, format, args);
    va_end(args);
    
    char* formatted = malloc(sizeof(char) * length);
    va_start(args, format);
    vsnprintf(formatted, length, format, args);
    va_end(args);
    
    return formatted;
}


@implementation Processor
@synthesize delegate;

- (NSData *) lastData {
    return [[[NSData alloc] initWithBytes: cachedString length: cacheStringIndex] autorelease];
}

- (id)initWithPrefs: (Prefs *)p
{
    self = [super init];
    if (self) {
        prepCrc();
        myUrl = [[NSURL URLWithString: @"http://yuaa.tc.yale.edu/scripts/raw.php"] retain];
        storeUrl = [[NSURL URLWithString: @"http://yuaa.tc.yale.edu/scripts/store.php"] retain];
        prefs = [p retain];
        lastUpdate = [[NSDate date] retain];
        okToSend = 1;
        okToGet = 1;
        threadAvailable = 1;
        [NSThread detachNewThreadSelector: @selector(posterThread) toTarget:self withObject:nil];
    }
    return self;
}

- (void) posterThread {
    [NSTimer scheduledTimerWithTimeInterval: 2 target:self selector:@selector(postTags) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void) updateData: (char) c fromSerial: (int) fromSerial {
    result *r = handle_char((char)c, &pState);
    if (r) {
        if (!gotTags) {
            if ([delegate respondsToSelector:@selector(gettingTags:)] && fromSerial) {
                [delegate gettingTags: YES];
                gotTags = YES;
                okToSend++;
            }
        }
        FlightData *flightData = [FlightData instance];
        [lastUpdate release];
        lastUpdate = [[NSDate date] retain];
        if (cacheStringIndex + (r->length + 5) < 1024 && strncmp(r->tag, "IM", 2) != 0 && strncmp(r->tag, "LA", 2) != 0 && strncmp(r->tag, "LO", 2) != 0) {
            NSLog(@"Updating with tag %2s", r->tag);
            createProtocolMessage(cachedString + cacheStringIndex, r->tag, r->content, r->length);
            cacheStringIndex += r->length + 5;
        }
        NSString *strTag = [[[NSString alloc] initWithBytes: r->tag length: 2 encoding:NSASCIIStringEncoding] autorelease];
        NSLog(@"String tag is %@", strTag);
        if ([strTag isEqualToString: @"IM"]) {
            flightData.lastImageTime = [NSDate date];
            
            int width = 80;
            int height = 60;
            Byte *rawImage = (Byte *)r->content;
            
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
            CFRelease(bitmapContext);
            id theValue;
            NSData *imageData;
            
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_EMBEDDED
            theValue = [UIImage imageWithCGImage: cgImage];
            imageData = UIImageJPEGRepresentation(theValue, 1);
#else
            CFMutableDataRef mutableImageData = CFDataCreateMutable(NULL, 0);
            theValue = [[[NSImage alloc] initWithCGImage: cgImage size: NSZeroSize] autorelease];
            CGImageDestinationRef idst = CGImageDestinationCreateWithData(mutableImageData, kUTTypeJPEG, 1, NULL);
            CGImageDestinationAddImage(idst, cgImage, NULL);
            CGImageDestinationFinalize(idst);
            CFRelease(idst);
            imageData = [NSData dataWithData: (NSMutableData *)mutableImageData];
            CFRelease(mutableImageData);
#endif
            CFRelease(cgImage);
            [flightData.pictures addObject: theValue];
            if ([delegate respondsToSelector: @selector(receivedPicture)])
                [delegate receivedPicture];

            ASIFormDataRequest *r = [ASIFormDataRequest requestWithURL:storeUrl];
            [r setPostValue: prefs.uuid forKey:@"uid"];
            [r setPostValue: @"berkeley" forKey: @"password"];
            [r setPostValue: @"balloon" forKey:@"devname"];
            [r setData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
            [r setDelegate:self];
            [r startAsynchronous];
            [imageData release];
            return;
        }
        NSString *strVal = [[[NSString alloc] initWithBytes: r->content length: (NSUInteger)(r->length) encoding:NSASCIIStringEncoding] autorelease];
        if ([strTag isEqualToString: @"MS"]) {
            [flightData.parseLogData addObject: @"Balloon message: "];
            [strVal enumerateLinesUsingBlock: ^(NSString *str, BOOL *stop) {
                [flightData.parseLogData addObject: str];
            }];
            return;
        }
        [flightData.parseLogData addObject: [NSString stringWithFormat: @"Updating tag %@ with value %@", strTag, strVal]];
        double floatVal = [strVal floatValue];
        if (floatVal != 0 || [strTag isEqualToString: @"GS"]) {
            
            if ([strTag isEqualToString: @"YA"]) {
                flightData.rotationZ = floatVal;
                flightData.lastIMUTime = [NSDate date];
            }
            else if ([strTag isEqualToString: @"PI"]) {
                flightData.rotationY = floatVal;
                flightData.lastIMUTime = [NSDate date];
            }
            else if ([strTag isEqualToString: @"RO"]) {
                flightData.rotationX = floatVal;
                flightData.lastIMUTime = [NSDate date];
            }
            else if (!([strTag isEqualToString: @"LA"] || [strTag isEqualToString: @"LO"] || [strTag isEqualToString: @"BB"])) {
                StatPoint *stat = [flightData.balloonStats objectForKey: strTag];
                if (![flightData.balloonStats objectForKey: strTag]) {
                    [flightData.nameArray performSelectorOnMainThread:@selector(addObject:) withObject:strTag waitUntilDone:NO];    
                }
                if (stat == nil) {
                    stat = [[[StatPoint alloc] init] autorelease];
                    [flightData.balloonStats setObject: stat forKey: strTag];
                }
                if (!stat.minval || stat.minval > floatVal) stat.minval = floatVal;
                if (!stat.maxval || stat.maxval < floatVal) stat.maxval = floatVal;
                NSNumber *idx = [NSNumber numberWithInteger: [stat.points count]];
                NSDictionary *point = [NSDictionary dictionaryWithObjectsAndKeys: idx, @"x", [NSNumber numberWithFloat: floatVal] , @"y", NULL];
                // this seems really inefficiant. we could do better ^^
                [stat.points performSelectorOnMainThread:@selector(addObject:) withObject:point waitUntilDone:NO];
                stat.lastTime = [NSDate date];
                [stat.bayNumToPoints setObject:point forKey: [NSNumber numberWithInt:bayCounter]];
            } 
            if ([strTag isEqualToString: @"MC"]) {mcc = (int)floor(floatVal); cellNew = YES; }
            if ([strTag isEqualToString: @"MN"]) {mnc = (int)floor(floatVal); cellNew = YES; }
            if ([strTag isEqualToString: @"CI"]) {cid = (int)floor(floatVal); cellNew = YES; }
            if ([strTag isEqualToString: @"LC"]) {lac = (int)floor(floatVal); cellNew = YES; }
            if ([strTag isEqualToString: @"LA"] || [strTag isEqualToString: @"LO"]) {
                double valAbs = fabs(floatVal);
                double newVal = (((valAbs - floor(valAbs)) * 100) / 60 + floor(valAbs)) * (floatVal>0?1.0:-1.0);
                if ([strTag isEqualToString: @"LA"]) {
                    flightData.lat = newVal;
                    flightData.lastLocTime = [NSDate date];
                } else if ([strTag isEqualToString: @"LO"]) {
                    flightData.lon = newVal;
                    flightData.lastLocTime = [NSDate date];
                }
                if (flightData.lat && flightData.lon) {
                    [self addLocationToCache];
                    [delegate receivedLocation];
                }
            }
            if (mnc && mcc && cid && lac && cellNew && threadAvailable) {
                cellNew = NO;
                threadAvailable = NO;
                NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"http://www.opencellid.org/cell/get?key=f146d401108de36297356ce9d026c8c6&mnc=%d&mcc=%d&lac=%d&cellid=%d", mnc, mcc, lac, cid]];
                [NSThread detachNewThreadSelector: @selector(updateWithURL:) toTarget:self withObject:url];
            }
            if ([delegate respondsToSelector: @selector(receivedTag:withValue:)]) {
                [delegate receivedTag: strTag withValue: floatVal];
            }
        }
    }
}

-(void)updateWithURL: (NSURL *)url {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[request responseData]];
        [parser setDelegate: self];
        [parser parse];
        [parser release];
        [FlightData instance].lastLocTime = [NSDate date];
        [self addLocationToCache];
        if ([delegate respondsToSelector:@selector(receivedLocation)])
            [delegate receivedLocation];
    }
    threadAvailable = YES;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)dict
{
    if ([elementName isEqualToString: @"cell"]) {
        // NSLog(@"Got location %@", dict);
        FlightData *flightData = [FlightData instance];
        flightData.lat = [[dict valueForKey: @"lat"] floatValue];
        flightData.lon = [[dict valueForKey: @"lon"] floatValue];
        // NSLog(@"Flightdata is %f, %f", flightData.lat, flightData.lon);
    }
}

-(void)addLocationToCache {
    FlightData *f = [FlightData instance];
    char *latStr = formattedString("%f", f.lat);
    int latLen = (int)strlen(latStr);
    char *lonStr = formattedString("%f", f.lon);
    int lonLen = (int)strlen(lonStr);
    if ((cacheStringIndex + (latLen + 5) + (lonLen + 5)) < 1024) {
        createProtocolMessage(cachedString + cacheStringIndex, "LA", latStr, latLen);
        cacheStringIndex += latLen + 5;
        createProtocolMessage(cachedString + cacheStringIndex, "LO", lonStr, lonLen);
        cacheStringIndex += lonLen + 5;
    }
    free(latStr);
    free(lonStr);
}

- (void)postTags {
    if ([lastUpdate timeIntervalSinceNow] < -10) {
        NSLog(@"I am no longer getting tags");
        if ([delegate respondsToSelector:@selector(gettingTags:)]) {
            [delegate gettingTags: NO];
            NSLog(@"Delegate informed of no tags");
        }
        gotTags = NO;
        okToSend--;
        okToGet--;
    }
    if (gotTags && okToSend == 2) {
        if (cacheStringIndex > 0) {
            NSString *cache = [[[NSString alloc] initWithBytes: cachedString length: cacheStringIndex encoding:NSASCIIStringEncoding] autorelease];
            ASIFormDataRequest *r = [ASIFormDataRequest requestWithURL:storeUrl];
            [r setPostValue: prefs.uuid forKey:@"uid"];
            [r setPostValue: @"balloon" forKey:@"devname"];
            [r setPostValue: cache forKey: @"data"];
            [r setDelegate:self];
            cacheStringIndex = 0;
            NSLog(@"Putting tags on server");
            okToSend = 0;
            okToGet--;
            [r startAsynchronous];
        }
    }
    if (!gotTags && okToGet == 1) {
        okToSend--;
        okToGet--;
        NSLog(@"Trying to get tags");
        ASIFormDataRequest *r = [ASIFormDataRequest requestWithURL:myUrl];
        [r setPostValue: prefs.uuid forKey:@"uid"];
        [r setPostValue: @"balloon" forKey:@"devname"];
        [r setDelegate:self];
        [r startAsynchronous];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self performSelectorInBackground:@selector(handleRequestFinished:) withObject:request];
}

- (void) handleRequestFinished: (ASIHTTPRequest *) request {
    NSLog(@"Request succeeded");
    //NSLog( @"Response is %@", [request responseString]);
    if ([delegate respondsToSelector: @selector(serverStatus:)])
        [delegate serverStatus: YES];
    FlightData *flightData = [FlightData instance];
    [flightData.netLogData addObject: @"Request Succeeded: "];
    [[request responseString] enumerateLinesUsingBlock: ^(NSString *str, BOOL *stop) {
        [flightData.netLogData addObject: str];
    }];
    if ([request.url isEqual: myUrl]) {
        NSData *responseData = [request responseData];
        int i;
        char *chars = (char *)[responseData bytes];
        for (i=0; i < [responseData length]; i++) {
            [self updateData: chars[i] fromSerial: 0];
        }
    }
    okToSend++;
    okToGet++;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Request failed");
    FlightData *flightData = [FlightData instance];
    [flightData.netLogData addObject: @"Request Failed: "];
    [flightData.netLogData addObject: [[request error] description]];
    if ([delegate respondsToSelector:@selector(serverStatus:)])
        [delegate serverStatus: NO];
    okToSend++;
    okToGet++;
}

- (void) dealloc {
    [prefs release];
    [myUrl release];
    [storeUrl release];
    [lastUpdate release];
    [super dealloc];
}

@end
