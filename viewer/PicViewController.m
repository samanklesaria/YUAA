//
//  PicViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 11/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PicViewController.h"
#import "SharedData.h"

@implementation PicViewController
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        handleSwipe = NO;
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
    NSArray *images = [[SharedData instance] images];
    if ([images count] > 0) {
        image.image = [images objectAtIndex: 0];
        imageIndex = 0;
    }
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [gesture setMinimumNumberOfTouches:1];
	[gesture setMaximumNumberOfTouches:1];
    [image addGestureRecognizer:gesture];
    [gesture release];
}

- (void)handleGesture: (UIPanGestureRecognizer *)gestureRecognizer {
    if (handleSwipe) {
        NSArray *images = [[SharedData instance] images];
        if ([images count] > 0) {
            if ([gestureRecognizer translationInView: image].x > 0) {
                if ([images count] <= ++imageIndex) imageIndex = 0;
            }
            if ([gestureRecognizer translationInView: image].x < 0) {
                if (--imageIndex < 0) imageIndex = [images count] - 1;
            }
            image.image = [images objectAtIndex: imageIndex];
        }
        handleSwipe = NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    handleSwipe = YES;
}

- (void)viewDidUnload
{
    [self setImage:nil];
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
    [super dealloc];
}
@end
