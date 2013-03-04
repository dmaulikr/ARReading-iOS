//
//  GLView.m
//  ARReading
//
//  Created by tclh123 on 13-3-4.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "GLView.h"

#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface GLView (private)

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)setupView;

@end

@implementation GLView

@dynamic animationFrameInterval;

#pragma mark -
#pragma mark Accessor

- (NSInteger) animationFrameInterval {
	return _animationFrameInterval;
}
- (void) setAnimationFrameInterval:(NSInteger)frameInterval {
	if (frameInterval >= 1)	{
		_animationFrameInterval = frameInterval;
		
		if (_animating) {
			[self stopAnimation];
			[self startAnimation];
		}
	}
}


#pragma mark -
#pragma mark Class method

+ (Class) layerClass {
	return [CAEAGLLayer class];
}

#pragma mark -
#pragma mark GLView (private)

- (BOOL)initializeOpenGLES {
    // CAEAGLLayer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	eaglLayer.opaque = NO;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

    // EAGLContext
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        return NO;
    }
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        return NO;
    }
    
	_animating = FALSE;
	_displayLinkSupported = FALSE;
	_animationFrameInterval = 1;
	_displayLink = nil;
	_animationTimer = nil;

	// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
	// class is used as fallback when it isn't available.
	NSString *reqSysVer = @"3.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
		_displayLinkSupported = TRUE;
    
    return YES;
}

// 当 GLView 作为 subView 加入到 父View 时
-(void)layoutSubviews {
    [super layoutSubviews];
    
//	[EAGLContext setCurrentContext:_context];
    
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self render];
}

- (BOOL)createFramebuffer {
    // frame buffer
	glGenFramebuffers(1, &_frameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // render buffer
	glGenRenderbuffers(1, &_renderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
	[_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER,GL_RENDERBUFFER_WIDTH,&_backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER,GL_RENDERBUFFER_HEIGHT,&_backingHeight);
	
    // depth buffer
	glGenRenderbuffers(1, &_depthRenderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
	
    // attach
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER, _depthRenderBuffer);
    
    
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer {
	glDeleteFramebuffers(1, &_frameBuffer);
	_frameBuffer = 0;
	glDeleteRenderbuffers(1, &_renderBuffer);
	_renderBuffer = 0;
	
	if(_depthRenderBuffer) {
		glDeleteRenderbuffers(1, &_depthRenderBuffer);
		_depthRenderBuffer = 0;
	}
}

#pragma mark -
#pragma mark GLView (public)

- (void) startAnimation {
	if (!_animating) {
		if (_displayLinkSupported) {
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			
			_displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(render)];
			[_displayLink setFrameInterval:_animationFrameInterval];
			[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			_animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * _animationFrameInterval) target:self selector:@selector(render) userInfo:nil repeats:TRUE];
		
		_animating = TRUE;
	}
}

- (void)stopAnimation {
	if (_animating) {
		if (_displayLinkSupported) {
			[_displayLink invalidate];
			_displayLink = nil;
		}
		else {
			[_animationTimer invalidate];
			_animationTimer = nil;
		}
		_animating = FALSE;
	}
}

#pragma mark -
#pragma mark If you use subclass of this, overide following methods

-(void)setupGLView {
	// dummy
}

- (void)render {
	// dummy
}

#pragma mark -
#pragma mark Override

//- (id)initWithCoder:(NSCoder*)coder {
//    if ((self = [super initWithCoder:coder])) {
//		if (![self initializeOpenGLES]) {  
//            self = nil;
//			return nil;
//		}
//		[self setupGLView];
//	}
//	return self;
//}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		if (![self initializeOpenGLES]) {    // init
            self = nil;
			return nil;
		}
		[self setupGLView];     // setup GLView
	}
	return self;
}

@end
