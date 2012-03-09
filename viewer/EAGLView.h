//
//  EAGLView.h
//  viewer
//
//  Created by Sam Anklesaria on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESRenderer.h"
#import "FlightData.h"

@interface EAGLView : UIView {
    id <ESRenderer> renderer;
    id displayLink;
	int touchesCount;
    UITouch *touch1;
	UITouch *touch2;
    BOOL displaying;
}

- (void)drawIfOpen;
- (void)checkNeedsRender;

@property BOOL displaying;
@property (retain) id renderer;
@end
