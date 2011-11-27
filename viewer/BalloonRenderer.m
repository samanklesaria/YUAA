//
//  BalloonRenderer.m
//  viewer
//
//  Created by Sam Anklesaria on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BalloonRenderer.h"
#include "OpenGLCommon.h"
#import "PlaneBody.h"
#import "SharedData.h"

@implementation BalloonRenderer

static GLuint texture = 0;

static float rColor = .945;
static float gColor = .180;
static float bColor = .820;

static float objectR = 0.1;
static float objectG = 0.1;
static float objectB = 0.1;


-(float)valueForComponent:(int)i color:(int)c {
	float b = 0;
	if (i==0) {
		//Background
		switch (c) {
			case 0:
				b = rColor;
				break;
			case 1:
				b = gColor;
				break;
			case 2:
				b = bColor;
				break;
			default:
				break;
		}
		
	} else {
		//Object
		switch (c) {
			case 0:
				b = objectR;
				break;
			case 1:
				b = objectG;
				break;
			case 2:
				b = objectB;
				break;
			default:
				break;
		}
		
	}
	return b;
}

void drawBackground() {
	glDisableClientState(GL_LIGHTING);
	glLoadIdentity();
	glScalef(3.5f, 4.5f, 1.0f);
	static const Vertex3D vertices[] = { 
		{-1.0,1.0,-7.0},
		{1.0,1.0,-7.0},
		{-1.0,-1.0,-7.0},
		{1.0,-1.0,-7.0}						
	};
	
	Color3D colors[] = {
		{rColor,gColor,bColor,1.0},
		{rColor,gColor,bColor,1.0},
		{rColor,gColor,bColor,1.0},
		{rColor,gColor,bColor,1.0},
	};
	static const Vector3D normals[] = {
        {0.0, 0.0, 1.0}, 
        {0.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.0, 0.0, 1.0}
    };
	
	
	static const GLfloat texCoords[] = {
        0.0,1.0,
        1.0,1.0,
        0.0,0.0,
        1.0,0.0
	};
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
    
	glBindTexture(GL_TEXTURE_2D, texture);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glNormalPointer(GL_FLOAT, 0, normals);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_LIGHTING);
}

void setUpView(GLint backingWidth, GLuint backingHeight) {
	glViewport(0, 0, backingWidth, backingHeight);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	
	const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0; 
	GLfloat size; 
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION); 
	size = zNear * tanf(fieldOfView/180*3.14159 / 2.0); 
	//NSLog(@"Viewport Size: %f", size);
	
	CGRect rect = [UIScreen mainScreen].bounds;
	//CGRect rect = CGRectMake(0.0, 0.0, 320.0, 480.0);
	
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / 
			   (rect.size.width / rect.size.height), zNear, zFar); 
	glViewport(0, 0, rect.size.width, rect.size.height);  
	glMatrixMode(GL_MODELVIEW);
	
	
	//Lighting
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	
	const GLfloat light0Ambient[] = {0.5, 0.5, 0.5, 1.0};
	glLightfv(GL_LIGHT0, GL_AMBIENT, light0Ambient);
	const GLfloat light0Diffuse[] = {0.7, 0.7, 0.7, 1.0};
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light0Diffuse);
	const GLfloat light0Specular[] = {0.8, 0.8, 0.8, 1.0};
	glLightfv(GL_LIGHT0, GL_SPECULAR, light0Specular);
	
	const GLfloat light0Position[] = {0.0, 7.0, 1.5, 1.0}; 
	glLightfv(GL_LIGHT0, GL_POSITION, light0Position); 
	
	glEnable(GL_COLOR_MATERIAL);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_DST_COLOR);
	glShadeModel(GL_SMOOTH);
	glEnable(GL_DEPTH_TEST);
	
	
	glEnable(GL_TEXTURE_2D);
    //glEnable(GL_BLEND);
    //glBlendFunc(GL_ONE, GL_SRC_COLOR);
	
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ComponentsBackgroundBW" ofType:@"png"];
	NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
	UIImage *image = [[UIImage alloc] initWithData:texData];
	if (image == nil) {
		NSLog(@"No Texture");
	}
	GLuint width = CGImageGetWidth(image.CGImage);
	GLuint height = CGImageGetHeight(image.CGImage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	void *imageData = malloc(height*width*4);
	CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextClearRect(context, CGRectMake(0.0, 0.0, width, height));
	CGContextTranslateCTM(context, 0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), image.CGImage);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	CGContextRelease(context);
	free(imageData);
	[image release];
	[texData release];
}

// Create an OpenGL ES 1.1 context
- (id)init
{
    if ((self = [super init]))
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context])
        {
            [self release];
            return nil;
        }
        
        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		
        
		
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
		
		
		
		setUpView(backingWidth, backingHeight);
		transZ = 0;
    }
    
    return self;
}

-(void)setBGColorComponent:(int)c value:(float)v {
    switch (c) {
        case 0:
            rColor = v;
            break;
        case 1:
            gColor = v;
            break;
        case 2:
            bColor = v;
            break;
        default:
            break;
    }	
}

-(void)setOBJColorComponent:(int)c value:(float)v {
	switch (c) {
		case 0:
			objectR = v;
			break;
		case 1:
			objectG = v;
			break;
		case 2:
			objectB = v;
			break;
		default:
			break;
	}	
}

void drawPlaneBody() {
	glColor4f(objectR, objectG, objectB, 1.0f);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glVertexPointer(3, GL_FLOAT, sizeof(TexturedVertexData3D), &PlanebodyVertexData[0].vertex);
	glNormalPointer(GL_FLOAT, sizeof(TexturedVertexData3D), &PlanebodyVertexData[0].normal);
	glTexCoordPointer(2, GL_FLOAT, sizeof(TexturedVertexData3D), &PlanebodyVertexData[0].texCoord);
	glDrawArrays(GL_TRIANGLES, 0, kPlanebodyNumberOfVertices);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);	
}

-(void)render
{
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
	
	
	glClearColor(1.0, 1.0, 1.0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	drawBackground();
	
	
	glLoadIdentity();
	glScalef(0.5f, 0.5f, 0.5f);
	
	glTranslatef(-2.5f,-2.5f,-10.0f+transZ); // glTranslatef(0.0f,0.0f,-4.0f+transZ);
    SharedData *s = [SharedData instance];
	glRotatef(s.rotationY, 0.0f, 1.0f, 0.0f);
	glRotatef(s.rotationX, 1.0f, 0.0f, 0.0f);
    glRotatef(s.rotationZ, 0.0f, 0.0f, 1.0f);
	
	GLfloat ambientAndDiffuse[] = {0.0, 0.1, 0.9, 1.0};
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, ambientAndDiffuse);
    GLfloat specular[] = {0.1, 0.1, 0.1, 1.0};
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, specular);
    glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 2.0);
	
	
	glColor4f(0.1f, 0.1f, 0.1f, 1.0);
    drawPlaneBody();
	
	// This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{	
    // Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
	
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

-(void)adjustScale:(float)z {
	transZ+=z;
}

- (void)dealloc
{
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffersOES(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
    
    if (colorRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
	
    
    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    context = nil;
    
    [super dealloc];
}

@end
