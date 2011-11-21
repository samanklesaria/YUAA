//
//  EAGLView.h
//  viewer
//
//  Created by Sam Anklesaria on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESRenderer.h"

@interface EAGLView : UIView {
    id <ESRenderer> renderer;
    NSInteger animationFrameInterval;
    id displayLink;
    NSTimer *animationTimer;
	BOOL animating;
	int touchesCount;
	BOOL isPinching;
    UITouch *touch1;
	UITouch *touch2;

}

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;

@property (nonatomic, assign) BOOL rotates;

@end
