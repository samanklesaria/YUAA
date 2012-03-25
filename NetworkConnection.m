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
        delegate = [dl retain];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(dataReceived:) name:NSFileHandleReadCompletionNotification object:fileHandle];
        [fileHandle readInBackgroundAndNotify];
        
    }
    return self;
}

-(void)dataReceived:(NSNotification *)notif {
    NSData *dat = [[notif userInfo] objectForKey:NSFileHandleNotificationDataItem];
    
    if ([dat length] == 0) {
        [(NetworkManage *)delegate closeConnection:self];
    } else {
        [(NetworkManage *)delegate recieveData: dat];
    }
}

-(void)writeData:(NSData *)data {
    if ([fileHandle fileDescriptor]) {
        @try {
            [fileHandle writeData:data];
        }
        @catch (NSException *a) {
            NSLog(@"I caught the error");
        }
        @finally {
        }
    }
}


- (void)dealloc
{
    NSLog(@"Deallocating the connection");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegate autorelease];
    [fileHandle autorelease];
    [super dealloc];
}

@end
