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



@end
