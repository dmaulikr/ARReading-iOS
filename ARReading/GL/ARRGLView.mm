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

//@synthesize cameraFrameSize;
//@synthesize codeListRef;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _shader = [[ARRSimpleGLShader alloc] init];
        
        [ARRGLVBOSimple setupVertexBufferObjects];
    }
    return self;
}

-(void)setupOpenGLViewWithFocalX:(float)focalX focalY:(float)focalY {
//	const GLfloat			lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
//	const GLfloat			lightDiffuse[] = {1.0, 0.6, 0.0, 1.0};
//	const GLfloat			matAmbient[] = {0.6, 0.6, 0.6, 1.0};
//	const GLfloat			matDiffuse[] = {1.0, 1.0, 1.0, 1.0};
//	const GLfloat			matSpecular[] = {1.0, 1.0, 1.0, 1.0};
//	const GLfloat			lightPosition[] = {0.0, 1.0, 1.0, 0.0};
//	const GLfloat			lightShininess = 100.0;
//	
//	//Configure OpenGL lighting
//	glEnable(GL_LIGHTING);
//	glEnable(GL_LIGHT0);
//	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
//	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
//	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matSpecular);
//	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, lightShininess);
//	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
//	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
//	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);
//	glShadeModel(GL_SMOOTH);
//	glEnable(GL_DEPTH_TEST);

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

- (void)render {
//	[EAGLContext setCurrentContext:_context];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [_shader bind];
    glEnableVertexAttribArray(_shader.positionSlot);
    glEnableVertexAttribArray(_shader.colorSlot);
    
    glVertexAttribPointer(_shader.positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_shader.colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
	
	glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, _projection.glMatrix);
    
	if (_codeListRef) {
		CRCodeList::iterator it = _codeListRef->begin();
		while(it != _codeListRef->end()) {
			float r[4];
			
			// only when using OpenGL for rendering
			(*it)->rotateOptimizedMatrixForOpenGL();
			
            // 根据识别出的 code，的变换矩阵，渲染
			CRMatrixMat4x42Quaternion(r, (*it)->optimizedMatrix);  // 矩阵 -> quaternion: 四元数
            
            glUniformMatrix4fv(_modelViewUniform, 1, GL_FALSE, (*it)->optimizedMatrixGL);
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
