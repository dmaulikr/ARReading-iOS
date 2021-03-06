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
        
//        [ARRGLVBOSimple setupVertexBufferObjects];
//        _simpleShader = [[ARRSimpleGLShader alloc] init];
        
        
        _textureShader = [[ARRTextureGLShader alloc] init];
//        shader = [[GLTexShader alloc] init];
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

- (void)render {
//    _DP("render:")
//    _CRTic();
    
    [self beginRendering];
    
    BOOL useMovieTextrue = YES;
    
    if (useMovieTextrue) {
        // AttribArray
        const float v[8] = {
            0,  0,
            1,  0,
            1,  1,
            0,  1
        };
        const float t[8] = {
            0,  0,
            1,  0,
            1,  1,
            0,  1
        };
        const float m[16] = {
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        };
        
        
        glEnable(GL_DEPTH_TEST);    // 开启深度测试
        
//        [shader bind];
//        [shader setTexture:self.targetTextureId atIndex:0];
//        glEnableVertexAttribArray(shader.position);
//        glEnableVertexAttribArray(shader.texcoord);
//        glVertexAttribPointer(shader.position, 2, GL_FLOAT, 0, 0, v);   // 顶点坐标
//        glVertexAttribPointer(shader.texcoord, 2, GL_FLOAT, 0, 0, t);   // 顶点纹理映射坐标
//        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);    // 012, 023 组成一个矩形
//        glDisableVertexAttribArray(shader.position);
//        glDisableVertexAttribArray(shader.texcoord);
//        glUniformMatrix4fv(shader.modelView, 1, 0, m);
//        [shader unbind];
        
        
        [_textureShader bind];
        [_textureShader setTexture:self.targetTextureId atIndex:0];
        glEnableVertexAttribArray(_textureShader.positionSlot);
        glEnableVertexAttribArray(_textureShader.texcoordSlot);
        
        glVertexAttribPointer(_textureShader.positionSlot, 2, GL_FLOAT, 0, 0, v);   // 顶点坐标
        glVertexAttribPointer(_textureShader.texcoordSlot, 2, GL_FLOAT, 0, 0, t);   // 顶点纹理映射坐标
        
        glUniformMatrix4fv(_textureShader.projectionUniform, 1, GL_FALSE, _projection.glMatrix);
        
        // Test draw
//        CC3Vector vec;
//        vec.x = 0;
//        vec.y = 0;
//        vec.z = -7;
//        CC3GLMatrix *modelView = [CC3GLMatrix matrix];
//        [modelView populateFromTranslation:vec];    // 平移 (x,y,z)
//        glUniformMatrix4fv(_textureShader.modelViewUniform, 1, 0, modelView.glMatrix);
//        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);    // 012, 023 组成一个矩形        // draw 就卡 TODO：我觉得是 MovieTexture里面有 shareContext 的问题！
        
        if (_codeListRef) {
            CRCodeList::iterator it = _codeListRef->begin();
            while(it != _codeListRef->end()) {

                glUniformMatrix4fv(_textureShader.modelViewUniform, 1, 0, (*it)->optimizedMatrixGL);
                glDrawArrays(GL_TRIANGLE_FAN, 0, 4);    // 012, 023 组成一个矩形

                ++it;
            }
        }
        
        glDisableVertexAttribArray(_textureShader.positionSlot);
        glDisableVertexAttribArray(_textureShader.texcoordSlot);
        [_textureShader unbind];
        
        
        ////////////////////////////////////////////////////////////////////////
    }
    else {
        glEnable(GL_DEPTH_TEST);    // 开启深度测试
        
        [_simpleShader bind];
        
        glEnableVertexAttribArray(_simpleShader.positionSlot);
        glEnableVertexAttribArray(_simpleShader.colorSlot);
        
        glVertexAttribPointer(_simpleShader.positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
        glVertexAttribPointer(_simpleShader.colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
        
        glUniformMatrix4fv(_simpleShader.projectionUniform, 1, GL_FALSE, _projection.glMatrix);
        
//        if (_codeListRef) {
//            CRCodeList::iterator it = _codeListRef->begin();
//            while(it != _codeListRef->end()) {
//                
//                glUniformMatrix4fv(_simpleShader.modelViewUniform, 1, 0, (*it)->optimizedMatrixGL);
//                [ARRGLVBOSimple drawElements];  // draw VBO Elements
//                
//                ++it;
//            }
//        }
        
        // model-view matrix
        CC3Vector v;
        v.x = 0;
        v.y = 0;
        v.z = -7;
        CC3GLMatrix *modelView = [CC3GLMatrix matrix];
        [modelView populateFromTranslation:v];    // 平移 (x,y,z)
        glUniformMatrix4fv(_simpleShader.modelViewUniform, 1, 0, modelView.glMatrix);
        [ARRGLVBOSimple drawElements];  // draw VBO Elements
        
        
        glDisableVertexAttribArray(_simpleShader.positionSlot);
        glDisableVertexAttribArray(_simpleShader.colorSlot);
        [_simpleShader unbind];
        
    }
    
    [self endRendering];
    
//    _CRToc();
}


- (void)renderTest {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    //    // model-view matrix
    //    CC3Vector v;
    //	v.x = 0;
    //	v.y = 0;
    //	v.z = -7;
    //    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    //    [modelView populateFromTranslation:v];    // 平移 (x,y,z)
    //    glUniformMatrix4fv(_simpleShader.modelViewUniform, 1, 0, modelView.glMatrix);
    //
    //    [ARRGLVBOSimple drawElements];  // draw VBO Elements
}

@end
