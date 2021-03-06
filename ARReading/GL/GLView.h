//
//  GLView.h
//  ARReading
//
//  Created by tclh123 on 13-3-4.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h> 

@interface GLView : UIView {
    // The pixel dimensions of the backbuffer. From OpenGL
    GLint _backingWidth;
    GLint _backingHeight;
    
    CAEAGLLayer *_eaglLayer;
//    EAGLContext *_context;
    
    GLuint _renderBuffer;
    GLuint _frameBuffer;
    GLuint _depthRenderBuffer;
    
    BOOL _displayLinkSupported;
    NSInteger _animationFrameInterval;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.     // VSync: 垂直同步
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink      // fallback : 备用
    // isn't available.
    id _displayLink;     // 主循环是靠 camera 的 Capture Loop，这里刷新是否有用？
    NSTimer *_animationTimer;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

@property (nonatomic) EAGLContext *context;
@property (nonatomic) GLuint targetTextureId;

-(void)startAnimation;
-(void)stopAnimation;

-(GLuint)createTexture;
//-(GLuint)createTextureWithSize:(CGSize)size format:(int)fmt;
-(GLuint) createTextureWithImageFile:(NSString *)fileName;

-(void)beginRendering;
-(void)endRendering;

// for override
-(void)render;

@end