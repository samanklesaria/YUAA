//
//  PicViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerPicController.h"

@implementation ServerPicController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        displayed = NO;
        imageIndex = 0;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    [self updatePics];
}

- (void)showPictures {
    FlightData *f = [FlightData instance];
    imageIndex = (int)[f.pictures count] - 1;
    [self.view setHidden: NO];
    displayed = YES;
    [self updatePics];
}

- (void)hidePictures {
    [self.view setHidden: YES];
    displayed = NO;
}

- (IBAction)goLeft:(id)sender {
    FlightData *f = [FlightData instance];
    if ([f.pictures count] <= ++imageIndex) imageIndex = 0;
    [imageView setImage: [[f.pictures objectAtIndex: imageIndex] pointerValue] imageProperties: nil];
    imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [f.pictures count]];
}
- (IBAction)goRight:(id)sender {
    FlightData *f = [FlightData instance];
    if (--imageIndex < 0) imageIndex = (int)[f.pictures count] - 1;
    [imageView setImage: [[f.pictures objectAtIndex: imageIndex] pointerValue] imageProperties: nil];
    imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [f.pictures count]];
}

- (void) updatePics {
    FlightData *f = [FlightData instance];
    NSLog(@"Updating pictures with imageIndex %d, image count: %d", imageIndex, (int)[f.pictures count]);
    if ([f.pictures count] > imageIndex) {
         [imageView setImage: [[f.pictures objectAtIndex: imageIndex] pointerValue] imageProperties: nil];
    }
    if ([f.pictures count] > 0)
        imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, (int)[f.pictures count]];
}

- (void) addedImage {
    FlightData *f = [FlightData instance];
    if (imageIndex == [f.pictures count] -2) {
        imageIndex++;
    }
    if (displayed) [self updatePics];
}


@end
