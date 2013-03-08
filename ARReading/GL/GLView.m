//
//  GLView.m
//  ARReading
//
//  Created by tclh123 on 13-3-4.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "GLView.h"

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
    _eaglLayer = (CAEAGLLayer *)self.layer;
	_eaglLayer.opaque = NO;

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
    
	[self destroyFramebuffer];
	[self createFramebuffer];
}

// 要先 bind depth，再 bind color；不然，后面还要 bind color 貌似。TODO：搞懂。
- (BOOL)createFramebuffer {
    // depth buffer
	glGenRenderbuffers(1, &_depthRenderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
//	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
    
    // render buffer
	glGenRenderbuffers(1, &_renderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];   //..?
//	glGetRenderbufferParameteriv(GL_RENDERBUFFER,GL_RENDERBUFFER_WIDTH,&_backingWidth);
//	glGetRenderbufferParameteriv(GL_RENDERBUFFER,GL_RENDERBUFFER_HEIGHT,&_backingHeight);
	
    // frame buffer
	glGenFramebuffers(1, &_frameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // attach
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER, _depthRenderBuffer);
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer {
    if( _frameBuffer ){
		glDeleteFramebuffers(1,&_frameBuffer);
		_frameBuffer = 0;
	}
	if( _renderBuffer ){
		glDeleteRenderbuffers(1,&_renderBuffer);
		_renderBuffer = 0;
	}
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

// 创建 _targetTextureId
-(GLuint)createTexture{
    _targetTextureId = 0;
	glGenTextures(1,&_targetTextureId);
	glBindTexture(GL_TEXTURE_2D,_targetTextureId);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glBindTexture(GL_TEXTURE_2D,0);
	return _targetTextureId;
}

//-(GLuint)createTextureWithSize:(CGSize)size format:(int)fmt{
//	int w = (int)size.width;
//	int h = (int)size.height;
//    
//	GLuint format = GL_LUMINANCE;
//	if( fmt == 2 ){ format = GL_LUMINANCE_ALPHA; }
//	else if( fmt == 3 ){ format = GL_RGB; }
//	else if( fmt == 4 ){ format = GL_RGBA; }
//    
//	GLuint textureId = 0;
//	glGenTextures(1,&textureId);
//	glBindTexture(GL_TEXTURE_2D,textureId);
//	glTexImage2D(GL_TEXTURE_2D,0,format,w, h, 0, format,GL_UNSIGNED_BYTE,NULL);     // NULL
//	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
//	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
//	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
//	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
//	glBindTexture(GL_TEXTURE_2D,0);
//	return textureId;
//}

-(void)beginRendering
{
	[EAGLContext setCurrentContext:_context];
	glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
//	glClearDepthf(1.f);
//	glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}

-(void)endRendering
{
	glFlush();
	glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
	[_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark -
#pragma mark If you use subclass of this, overide following methods

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
	}
	return self;
}

@end
