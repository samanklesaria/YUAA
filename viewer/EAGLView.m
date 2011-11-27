//
//  EAGLView.m
//  viewer
//
//  Created by Sam Anklesaria on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EAGLView.h"
#import "BalloonRenderer.h"

@implementation EAGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		renderer = [[BalloonRenderer alloc] init];
		
		if (!renderer)
		{
			[self release];
			return nil;
		}
        displayLink = nil;
		self.multipleTouchEnabled = YES;
		isPinching = NO;
        self.exclusiveTouch = YES;
    }
    return self;
}

- (void)drawView:(id)sender
{
    [renderer render];
}

- (void)layoutSubviews
{
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (void)dealloc
{
    [renderer release];
    [super dealloc];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] == 1) {
		touch1 = [touches anyObject];
		isPinching = NO;
	} else if ([touches count] == 2) {
		NSArray *touchArray = [touches allObjects];
		touch1 = [touchArray objectAtIndex:0];
		touch2 = [touchArray objectAtIndex:1];
		isPinching = YES;
	}
}

#define kRotationScale 0.5
static float kPinchScaleFactor =  27000;

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSArray *touchArray = [touches allObjects];
	if ([touchArray count]==2) {
		touch1 = [touchArray objectAtIndex:0];
		touch2 = [touchArray objectAtIndex:1];
		CGPoint f =  [touch1  previousLocationInView:self];
		CGPoint d = [touch2  previousLocationInView:self];
		CGPoint ff =  [touch1  locationInView:self];
		CGPoint dd = [touch2  locationInView:self];
		
		float d1 = (f.x-d.x)*(f.x-d.x)+(f.y-d.y)*(f.y-d.y);
		float d2 = (ff.x-dd.x)*(ff.x-dd.x)+(ff.y-dd.y)*(ff.y-dd.y);
        //	NSLog(@"D1: %f D2: %f", d1,d2);
		[renderer adjustScale:(d2-d1)/kPinchScaleFactor];
	}    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}


@end
