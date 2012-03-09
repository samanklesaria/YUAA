//
//  NetworkConnection.m
//  Babelon
//
//  Created by Stephen Hall on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkConnection.h"

#define WELCOME_STRING @"<WELCOME>"

@implementation NetworkConnection
@synthesize hasWrittenWelcome;
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
        NSLog(@"YOU JUST DISCONNECTED");
        [(NetworkManage *)delegate closeConnection:self];
        [fileHandle closeFile];
    } else {
        //We really don't care about incoming data...
    }
}

-(void)writeData:(NSData *)data {
    if (fileHandle != nil) {
        if (!hasWrittenWelcome) {
            [fileHandle writeData:[WELCOME_STRING dataUsingEncoding:NSASCIIStringEncoding]];
            hasWrittenWelcome = YES;
        } 
        [fileHandle writeData:data];
    }
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegate autorelease];
    [fileHandle release];
    [super dealloc];
}

@end
