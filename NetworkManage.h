//
//  NetworkManage.h
//  Babelon
//
//  Created by Stephen Hall on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import "NetworkConnection.h"
#import <sys/socket.h>   // for AF_INET, PF_INET, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR
#import <netinet/in.h>   // for IPPROTO_TCP, sockaddr_in


@class NetworkConnection;
@protocol NetworkManageDelegate <NSObject>
-(void)newConnection:(NetworkConnection *)conn;
@end

@interface NetworkManage : NSObject {
@private
    NSFileHandle *fileHandle;
    NSMutableArray *connections;
    NSMutableArray *requests;
    id<NetworkManageDelegate>delegate;
}

-(void)broadcast:(NSString *)s;

-(id)initWithDelegate:(id)del;
-(void)closeConnection:(NetworkConnection *)conn;
-(void)writeData:(NSData *)d;


@property (nonatomic, assign) id<NetworkManageDelegate>delegate;

@end
