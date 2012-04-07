//
//  NetworkConnection.m
//  Babelon
//
//  Created by Stephen Hall on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkConnection.h"

@implementation NetworkConnection
- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl
{
    self = [super init];
    if (self) {
        
        fileHandle = [fh retain];
        delegate = dl;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(dataReceived:) name:NSFileHandleReadCompletionNotification object:fileHandle];
        [fileHandle readInBackgroundAndNotify];
        
    }
    return self;
}

-(void)dataReceived:(NSNotification *)notif {
    NSData *dat = [[notif userInfo] objectForKey:NSFileHandleNotificationDataItem];
    
    if ([dat length] == 0) {
        NSLog(@"Received null data");
        [(NetworkManage *)delegate closeConnection:self];
    } else {
        [(NetworkManage *)delegate recieveData: dat];
    }
}

-(void)writeData:(NSData *)data {
    if (fileHandle) {
        @try {
            [fileHandle writeData:data];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
}


- (void)dealloc
{
    NSLog(@"Deallocating the connection");
    // [fileHandle writeData: 
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    unsigned char end[4] = {4, 4, 4, 4};
    [fileHandle writeData: [NSData dataWithBytes: &end length:4]];
    // close([fileHandle fileDescriptor]);
    // [fileHandle closeFile];
    [fileHandle closeFile];
    [fileHandle autorelease];
    NSLog(@"I should have closed the connection");
    [super dealloc];
}

@end
