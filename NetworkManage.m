//
//  NetworkManage.m
//  Babelon
//
//  Created by Stephen Hall on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkManage.h"

#define PORT_NUMBER 3313
@implementation NetworkManage
@synthesize delegate;
- (id)initWithDelegate:(id<NetworkManageDelegate>)del
{
    self = [super init];
    if (self) {
        NSLog(@"Initializing a network manager");
        // Initialization code here.
        connections = [[NSMutableArray alloc] init];
        requests = [[NSMutableArray alloc] init];
        
        delegate = del;
        
        int fd = -1;
        CFSocketRef socket;
        socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM,
                                IPPROTO_TCP, 0, NULL, NULL);
        if( socket ) {
            fd = CFSocketGetNative(socket);
            int yes = 1;
            setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
            
            struct sockaddr_in addr;
            memset(&addr, 0, sizeof(addr));
            addr.sin_len = sizeof(addr);
            addr.sin_family = AF_INET;
            addr.sin_port = htons(PORT_NUMBER);
            addr.sin_addr.s_addr = htonl(INADDR_ANY);
            NSData *address = [NSData dataWithBytes:&addr length:sizeof(addr)];
            if( CFSocketSetAddress(socket, (CFDataRef)address) !=
               kCFSocketSuccess ) {
                NSLog(@"Could not bind to address");
            }
        } else {
            NSLog(@"SUPER FAILURE");
        }
            
        
        fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(newConnection:) name:NSFileHandleConnectionAcceptedNotification object:nil];
        [fileHandle acceptConnectionInBackgroundAndNotify];
        
        /*
         NSSocketPort* serverSock = [[NSSocketPort alloc] initWithTCPPort: 1234];
         socketHandle = [[NSFileHandle alloc] initWithFileDescriptor: [serverSock socket]
         closeOnDealloc: NO];
         
         [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(newConnection:) 
         name: NSFileHandleConnectionAcceptedNotification
         object: socketHandle];
         
         [socketHandle acceptConnectionInBackgroundAndNotify];
         */
        
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
    if (connections) {
        for (id a in connections) {
            [a release];
        }
    }
    [connections release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [fileHandle release];
    [super dealloc];
}

@end
