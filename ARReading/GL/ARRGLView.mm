//
//  ARRGLView.m
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "ARRGLView.hpp"

#import "ARRGLVBOSimple.h"

@implementation ARRGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _DP("VBO will setup.")
        [ARRGLVBOSimple setupVertexBufferObjects];
        
        _DP("shader will init.")
        _shader = [[ARRSimpleGLShader alloc] init];
    }
    return self;
}

-(void)setupOpenGLViewWithFocalX:(float)focalX focalY:(float)focalY {

	// Set Projection
    _projection = [CC3GLMatrix matrix];
    float left = -0.5 * self.cameraFrameSize.height / focalY;
	float right = 0.5 * self.cameraFrameSize.height / focalY;
	float bottom = -0.5 * self.cameraFrameSize.width / focalX;
	float top = 0.5 * self.cameraFrameSize.width / focalX;
    [_projection populateFromFrustumLeft:left andRight:right andBottom:bottom andTop:top andNear:1 andFar:1000];
    
    // glViewport 设置UIView中用于渲染的部分
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)renderTest {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
//    // model-view matrix
//    CC3Vector v;
//	v.x = 0;
//	v.y = 0;
//	v.z = -7;
//    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
//    [modelView populateFromTranslation:v];    // 平移 (x,y,z)
//    glUniformMatrix4fv(_shader.modelViewUniform, 1, 0, modelView.glMatrix);
//    
//    [ARRGLVBOSimple drawElements];  // draw VBO Elements
}

- (void)render {
    _DP("glView render.")
    
//    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
//    glEnable(GL_DEPTH_TEST);    // 开启深度测试
    
    [_shader bind];
    glEnableVertexAttribArray(_shader.positionSlot);
    glEnableVertexAttribArray(_shader.colorSlot);
    
    glVertexAttribPointer(_shader.positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_shader.colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) *3));

	glUniformMatrix4fv(_shader.projectionUniform, 1, GL_FALSE, _projection.glMatrix);

	if (_codeListRef) {
		CRCodeList::iterator it = _codeListRef->begin();
		while(it != _codeListRef->end()) {
			// only when using OpenGL for rendering
			(*it)->rotateOptimizedMatrixForOpenGL();
            
            glUniformMatrix4fv(_shader.modelViewUniform, 1, 0, (*it)->optimizedMatrixGL);
            [ARRGLVBOSimple drawElements];  // draw VBO Elements
            
			++it;
		}
	}
    
    glDisableVertexAttribArray(_shader.positionSlot);
    glDisableVertexAttribArray(_shader.colorSlot);    
    [_shader unbind];
    
	[_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
