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
@synthesize prefs;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            if (prefs.postServer != nil) {
                [postUrlCell setValue: prefs.postServer];
            }
            if (prefs.port != 0) {
                [serialPortCell setValue: [NSString stringWithFormat: @"%i", prefs.port]];
            }
            if (prefs.deviceName != nil) {
                [deviceIdCell setValue: prefs.deviceName];
            }
            
    }
    return self;
}

- (IBAction)serverPortChanged:(NSTextFieldCell *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    prefs.port = [sender intValue];
    [defaults setObject: prefs.postServer forKey: @"port"];
    [delegate restartPort: prefs.port];
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
