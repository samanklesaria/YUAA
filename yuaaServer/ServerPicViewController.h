//
//  PicViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface PicViewController : NSViewController {
    IBOutlet NSImageView *imageView;
    NSMutableArray *images;
    bool displayed;
    IBOutlet NSTextField *imageCounter;
    int imageIndex;
}

- (void) updatePics;
- (IBAction)goLeft:(id)sender;
- (IBAction)goRight:(id)sender;

@end
