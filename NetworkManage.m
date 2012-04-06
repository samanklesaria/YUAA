//
//  NetworkManage.m
//  Babelon
//
//  Created by Stephen Hall on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkManage.h"

@implementation NetworkManage
@synthesize delegate;
- (id)initWithDelegate:(id<NetworkManageDelegate>)del port: (NSInteger)port
{
    self = [super init];
    if (self) {
        NSLog(@"Using port %ld", port);
        NSLog(@"Initializing a network manager");
        // Initialization code here.
        connections = [[NSMutableArray alloc] init];
        requests = [[NSMutableArray alloc] init];
        
        delegate = del;
        
        NSSocketPort* serverSock = [[NSSocketPort alloc] initWithTCPPort: port];
        int set = 1;
        setsockopt([serverSock socket], SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
        fileHandle = [[NSFileHandle alloc] initWithFileDescriptor: [serverSock socket]
                                                     closeOnDealloc: YES];
        [serverSock release];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(newConnection:) 
                                                     name: NSFileHandleConnectionAcceptedNotification
                                                   object: fileHandle];
        [fileHandle acceptConnectionInBackgroundAndNotify];
    }
    
    return self;
}



-(void)broadcast:(NSString *)s {
    NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
    for (NetworkConnection *nc in connections) {
        [nc writeData:d];
    }
}
-(void)writeData:(NSData *)d {
    for (NetworkConnection *nc in connections) {
        [nc writeData:d];
    }
}

- (void)recieveData: (NSData *)d {
    [delegate recieveData: d];
}

-(void)newConnection:(NSNotification *)notif {
    NSDictionary *userInfo = [notif userInfo];
    NSFileHandle *writeHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
    NSNumber *errorNo = [userInfo objectForKey:@"NSFileHandleError"];
    if (errorNo) {
        NSLog(@"ERROR:%@",errorNo);
    }
    NSLog(@"New Connection");
        
    if (writeHandle) {
     
        NetworkConnection *connection = [[NetworkConnection alloc] initWithFileHandle:writeHandle delegate:self];
        if (connection) {
            NSIndexSet *insertedIndexes;
            insertedIndexes = [NSIndexSet indexSetWithIndex:[connections count]];
            [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"connections"];
            [connections addObject:connection];
            [connection release];
            [delegate newConnection:connection];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionUpdate" object:[NSNumber numberWithInt:(int)[connections count]]];
        }
    }
     [fileHandle acceptConnectionInBackgroundAndNotify];
}

-(void)closeConnection:(NetworkConnection *)nc {
    [connections removeObject:nc];
    NSLog(@"Closed Connection");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionUpdate" object:[NSNumber numberWithInt:(int)[connections count]]];
}


- (void)dealloc
{
    NSLog(@"Deallocating");
    if (connections) {
        for (id a in connections) {
            [a release];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionUpdate" object:[NSNumber numberWithInt: 0]];
    [connections release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [fileHandle release];
    [super dealloc];
}

@end
