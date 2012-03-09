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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)serialPortChanged:(NSPopUpButtonCell *)sender {
    NSString *item = [[sender selectedItem] title];
    if (item)
        [delegate restartSerial: item];
}

@end
