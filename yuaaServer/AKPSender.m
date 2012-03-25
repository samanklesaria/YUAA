//
//  AKPSender.m
//  viewer
//
//  Created by Sam Anklesaria on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AKPSender.h"

@implementation AKPSender
@synthesize networkLog;
@synthesize serialPort;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (IBAction)userReturn:(id)sender {
    NSLog(@"User returned");
    NSString *str = [messageField stringValue];
    if ([str length] > 0 && serialPort) {
        NSData *d = [str dataUsingEncoding:NSASCIIStringEncoding];
        [serialPort writeData:d error:NULL];
        FlightData *f = [FlightData instance];
        [f.netLogData addObject: [NSString stringWithFormat: @"Sending: %@", str]];
        [messageField setValue: @""];
    }
}

- (void) showMe {
    [messageField becomeFirstResponder];
}

- (void) dealloc {
    [serialPort autorelease];
    [networkLog release];
    [super dealloc];
}
@end
