//
//  PicViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "FlightData.h"

@interface ServerPicController : NSViewController {
    IBOutlet IKImageView *imageView;
    bool displayed;
    IBOutlet NSTextField *imageCounter;
    int imageIndex;
}

- (void) updatePics;
- (IBAction)goLeft:(id)sender;
- (IBAction)goRight:(id)sender;
- (void) addedImage;

@end
