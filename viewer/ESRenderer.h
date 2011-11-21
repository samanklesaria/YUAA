//
//  ESRenderer.h
//  Components
//
//  Created by Stephen Hall on 5/31/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderer <NSObject>

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)toggleRotation;
- (void)adjustScale:(float)scale;
- (void)appendRotationX:(float)xrot rotationY:(float)yrot;
- (BOOL)rotates;
@end
