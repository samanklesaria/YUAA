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
        displayed = NO;
        imageIndex = 0;
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

- (void)viewDidAppear:(BOOL)animated {
    FlightData *flightData = [FlightData instance];
    imageIndex = [flightData.pictures count] - 1;
    displayed = YES;
    [self updatePics];
}

- (void)viewDidDisappear:(BOOL)animated {
    displayed = NO;
}

- (void)handleGesture: (UIPanGestureRecognizer *)gestureRecognizer {
    if (handleSwipe) {
        FlightData *flightData = [FlightData instance];
        if ([flightData.pictures count] > 0) {
            if ([gestureRecognizer translationInView: image].x < 0) {
                if ([flightData.pictures count] <= ++imageIndex) imageIndex = 0;
            }
            if ([gestureRecognizer translationInView: image].x > 0) {
                if (--imageIndex < 0) imageIndex = [flightData.pictures count] - 1;
            }
            image.image = [flightData.pictures objectAtIndex: imageIndex];
             imageCounter.text = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [flightData.pictures count]];
        }
        handleSwipe = NO;
    }
}

- (void) updatePics {
    FlightData *flightData = [FlightData instance];
    NSLog(@"Updating pictures with imageIndex %d, image count: %d", imageIndex, [flightData.pictures count]);
    if ([flightData.pictures count] > imageIndex) {
        UIImage *im = [flightData.pictures objectAtIndex: imageIndex];
        image.image = im;
    }
    if ([flightData.pictures count] > 0)
        imageCounter.text = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [flightData.pictures count]];
}

- (void) addedImage {
    FlightData *flightData = [FlightData instance];
    if (imageIndex == [flightData.pictures count] -2) {
        imageIndex++;
    }
    if (displayed) [self updatePics];
}

- (int)imagesCount {
    FlightData *flightData = [FlightData instance];
    return [flightData.pictures count];
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
