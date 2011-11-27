//
//  BalloonRenderer.h
//  viewer
//
//  Created by Sam Anklesaria on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface BalloonRenderer : NSObject  <ESRenderer>
{
@private
    EAGLContext *context;
    
    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
	GLuint depthRenderbuffer;
	
	GLuint texture;
	
	
	float transZ;
}

-(float)valueForComponent:(int)i color:(int)c;

-(void)setBGColorComponent:(int)c value:(float)v;
-(void)setOBJColorComponent:(int)c value:(float)v;

-(void)adjustScale:(float)z;

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
@end

void drawBackground(void);
void drawPlaneBody(void);
void setUpView(GLint backingWidth, GLuint backingHeight);