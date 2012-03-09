//
//  PicViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PicViewController.h"

@implementation PicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        displayed = NO;
        imageIndex = 0;
        images = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    [self updatePics];
}

- (void)showPictures {
    imageIndex = (int)[images count] - 1;
    [self.view setHidden: NO];
    displayed = YES;
    [self updatePics];
}

- (void)hidePictures {
    [self.view setHidden: YES];
    displayed = NO;
}

- (IBAction)goLeft:(id)sender {
    if ([images count] <= ++imageIndex) imageIndex = 0;
    imageView.image = [images objectAtIndex: imageIndex];
    imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [images count]];
}
- (IBAction)goRight:(id)sender {
    if (--imageIndex < 0) imageIndex = (int)[images count] - 1;
    imageView.image = [images objectAtIndex: imageIndex];
    imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [images count]];
}

- (void) updatePics {
    NSLog(@"Updating pictures with imageIndex %d, image count: %d", imageIndex, (int)[images count]);
    if ([images count] > imageIndex) {
        NSImage *im = [images objectAtIndex: imageIndex];
        imageView.image = im;
    }
    if ([images count] > 0)
        imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, (int)[images count]];
}

- (void) addImage:(NSImage *)theImage {
    [images addObject: theImage];
    if (imageIndex == [images count] -2) {
        imageIndex++;
    }
    if (displayed) [self updatePics];
}

- (int)imagesCount {
    return (int)[images count];
}

@end
