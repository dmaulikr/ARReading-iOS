//
//  ARRSimpleGLShader.m
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "ARRSimpleGLShader.h"

// Nice Stuff!!!
#define GLSL(src) #src

@implementation ARRSimpleGLShader

-(BOOL)compileShaders:(const char*)vsrc :(const char*)fsrc {
    BOOL ret = [super compileShaders:vsrc :fsrc];
    if (!ret) {
        return NO;
    }
    
    // 获得变量指针
    _colorSlot = glGetAttribLocation(_programId, "SourceColor");
    
    // 维护 Uniform 指针
    _projectionUniform = glGetUniformLocation(_programId, "Projection");
    _modelViewUniform = glGetUniformLocation(_programId, "Modelview");
    return YES;
}

// override loadShaders
-(void)loadShaders{
	const char *src[2] = {
		GLSL(
             attribute vec4 Position; // 1
             attribute vec4 SourceColor; // 2
             
             varying vec4 DestinationColor; // 3
             
             uniform mat4 Projection;    // add a Projection
             
             uniform mat4 Modelview;     // add Model-view Matrix
             
             void main(void) { // 4
                 DestinationColor = SourceColor; // 5
                 gl_Position = Projection * Modelview * Position; // 6
             }
        ),
		GLSL(
             varying lowp vec4 DestinationColor; // 1
             
             void main(void) { // 2
                 gl_FragColor = DestinationColor; // 3
             }
        )
	};
	[self compileShaders:src[0] :src[1]];
}

@end
