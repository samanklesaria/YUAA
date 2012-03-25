//
//  NetworkConnection.h
//  Babelon
//
//  Created by Stephen Hall on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManage.h"

@class NetworkManage;

@interface NetworkConnection : NSObject {
@private
    NSFileHandle *fileHandle;
    id delegate;
    
    //NSMutableData *incomingData;    
}
- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl;
-(void)writeData:(NSData *)data;

@end
