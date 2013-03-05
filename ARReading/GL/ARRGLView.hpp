//
//  ARRGLView.h
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "GLView.h"
#import "CC3GLMatrix.h"
#import "ARRCameraViewController.hpp"
#import "ARRSimpleGLShader.h"

//#import "CoreAR.h"  //??
#include "CoreAR.h"

@interface ARRGLView : GLView {
    
    // uniform matrix
//    GLuint _projectionUniform;
//    GLuint _modelViewUniform;
    
    CC3GLMatrix *_projection;
    
    ARRSimpleGLShader *_shader;
    
    //
    
	CGSize							_cameraFrameSize;
	CRCodeListRef					_codeListRef;
}
@property (nonatomic, assign) CGSize cameraFrameSize;
@property (nonatomic, assign) CRCodeListRef codeListRef;        // assign?
-(void)setupOpenGLViewWithFocalX:(float)focalX focalY:(float)focalY;

- (void)renderTest;

@end
