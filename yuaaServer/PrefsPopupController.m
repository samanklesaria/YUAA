//
//  PrefsPopupController.m
//  viewer
//
//  Created by Sam Anklesaria on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PrefsPopupController.h"

@implementation PrefsPopupController
@synthesize serialPortCell;
@synthesize delegate;

- (Prefs *) prefs {
    return prefs;
}

-(void) setPrefs:(Prefs *)p {
    prefs = p;
    NSLog(@"Setting prefs");
    if (self.prefs.postServer != nil) {
        [postUrlCell setObjectValue: prefs.postServer];
    }
    if (prefs.port != 0) {
        [serverPortCell setObjectValue: [NSString stringWithFormat: @"%i", prefs.port]];
    }
    if (prefs.deviceName != nil) {
        [deviceIdCell setObjectValue: prefs.deviceName]; 
    }
}

- (IBAction)serverPortChanged:(NSTextFieldCell *)sender {
    NSInteger portVal = [sender integerValue];
    NSInteger tester = prefs.port;
    if ((tester != portVal) && portVal) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        prefs.port = portVal;
        [defaults setInteger: portVal forKey: @"port"];
        [delegate restartPort: portVal];
    }
}

- (IBAction)postUrlChanged:(NSTextFieldCell *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    prefs.postServer = [sender stringValue];
    [defaults setObject: prefs.postServer forKey: @"postServer"];
}

- (IBAction)deviceIdChanged:(NSTextFieldCell *)sender {
    prefs.deviceName = [sender stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: prefs.deviceName forKey: @"deviceId"];
}

- (IBAction)serialPortChanged:(NSPopUpButtonCell *)sender {
    NSString *item = [[serialPortCell selectedItem] title];
    if (item) {
        NSLog(@"Item exists with delegate %@", delegate);
        [delegate restartSerial: item];
    }
}

@end
