//
//  PrefsPopupController.h
//  viewer
//
//  Created by Sam Anklesaria on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SerialRestart <NSObject>
- (void)restartSerial: (NSString *)port;
@end

@interface PrefsPopupController : NSViewController <NSPopoverDelegate> {
    id <SerialRestart> delegate;
    IBOutlet NSTextFieldCell *deviceIdCell;
    IBOutlet NSTextFieldCell *postUrlCell;
    IBOutlet NSTextFieldCell *serverPortCell;
    IBOutlet NSPopUpButtonCell *serialPortCell;
}

- (IBAction)serialPortChanged:(NSPopUpButtonCell *)sender;

@property (retain) NSPopUpButtonCell *serialPortCell;

@end
