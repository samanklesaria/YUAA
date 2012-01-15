//
//  PicViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 11/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PicViewController.h"

@implementation PicViewController
@synthesize image;
@synthesize imageCounter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        handleSwipe = NO;
        imageIndex = 0;
        images = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updatePics];
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [gesture setMinimumNumberOfTouches:1];
	[gesture setMaximumNumberOfTouches:1];
    [image addGestureRecognizer:gesture];
    [gesture release];
}

- (void)handleGesture: (UIPanGestureRecognizer *)gestureRecognizer {
    if (handleSwipe) {
        if ([images count] > 0) {
            if ([gestureRecognizer translationInView: image].x < 0) {
                if ([images count] <= ++imageIndex) imageIndex = 0;
            }
            if ([gestureRecognizer translationInView: image].x > 0) {
                if (--imageIndex < 0) imageIndex = [images count] - 1;
            }
            image.image = [images objectAtIndex: imageIndex];
             imageCounter.text = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [images count]];
        }
        handleSwipe = NO;
    }
}

- (void) updatePics {
    NSLog(@"Updating pictures with imageIndex %d, image count: %d", imageIndex, [images count]);
    if ([images count] > imageIndex) {
        UIImage *im = [images objectAtIndex: imageIndex];
        image.image = im;
    }
    if ([images count] > 0)
        imageCounter.text = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [images count]];
}

- (void) addImage:(UIImage *)theImage {
    [images addObject: theImage];
    [self updatePics];
}

- (NSData *)getImageTag {
    if ([images count] > 0) return UIImageJPEGRepresentation([images lastObject], 1); else return NULL;
}

- (int)imagesCount {
    return [images count];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    handleSwipe = YES;
}

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setImageCounter:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [image release];
    [imageCounter release];
    [super dealloc];
}
@end
