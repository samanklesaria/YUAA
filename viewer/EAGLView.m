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
@synthesize displaying;
@synthesize renderer;

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
        self.exclusiveTouch = YES;
        [NSThread detachNewThreadSelector: @selector(checkNeedsRender) toTarget:self withObject:nil];
    }
    return self;
}

-(void) checkNeedsRender {
    [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector:@selector(drawIfOpen) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void)drawIfOpen
{
    if (displaying) {
        [renderer render];
    }
}

- (void)layoutSubviews
{
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
}

- (void)dealloc
{
    [renderer release];
    [super dealloc];
}



@end
