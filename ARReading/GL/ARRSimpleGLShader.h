//
//  ARRSimpleGLShader.h
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "GLShader.h"

@interface ARRSimpleGLShader : GLShader

// attr slot
@property (readonly) GLuint positionSlot;
@property (readonly) GLuint colorSlot;

// uniform matrix
@property (readonly) GLuint projectionUniform;
@property (readonly) GLuint modelViewUniform;

@end
