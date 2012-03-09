//
//  AKPSender.h
//  viewer
//
//  Created by Sam Anklesaria on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"
#import "AMSerialPortAdditions.h"

@interface AKPSender : NSViewController {
    IBOutlet NSTextField *messageField;
    AMSerialPort *serialPort;
    NSMutableArray *networkLog;
}

- (void)showMe;
- (IBAction)userReturn:(id)sender;

@property (retain) AMSerialPort *serialPort;
@property (retain) NSMutableArray *networkLog;
@end
