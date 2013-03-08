//
//  ARRGLVBOSimple.m
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "ARRGLVBOSimple.h"

#define CUBE 1

#if !CUBE
// 4个点
Vertex Vertices[] = {       // WHY: 按CoreAR的，不知道为什么中心不在原点
    {{0, 0, 0}, {1, 0, 0, 1}},     // r
    {{1, 0, 0}, {0, 1, 0, 1}},      // g
    {{1, 1, 0}, {0, 0, 1, 1}},     // b
    {{0, 1, 0}, {0, 0, 0, 1}}     // black
    
    //    {{-1, -1, 0}, {1, 0, 0, 1}},     // r
    //    {{1, -1, 0}, {0, 1, 0, 1}},      // g
    //    {{1, 1, 0}, {0, 0, 1, 1}},     // b
    //    {{-1, 1, 0}, {0, 0, 0, 1}}     // black
    
    // OpenGL 的 z轴是垂直屏幕向外的，所以 z坐标为负数
};
// 三角形顶点的 数组 , 存顶点index
GLubyte Indices[] = {
    0, 1, 2,    // 右上
    2, 3, 0     // 左下
};

#else

//// 8个点
Vertex Vertices[] = {
    {{0, 0, 0}, {1, 0, 0, 1}},     // r
    {{1, 0, 0}, {0, 1, 0, 1}},      // g
    {{1, 1, 0}, {0, 0, 1, 1}},     // b
    {{0, 1, 0}, {0, 0, 0, 1}},     // black

    {{0, 0, -1}, {1, 0, 0, 1}},     // r
    {{1, 0, -1}, {0, 1, 0, 1}},      // g
    {{1, 1, -1}, {0, 0, 1, 1}},     // b
    {{0, 1, -1}, {0, 0, 0, 1}}     // black
};

// 6个面，每个面2个三角形
GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4
};

#endif

@implementation ARRGLVBOSimple

// VBO: vertex buffer object
+ (void)setupVertexBufferObjects {     //防止指针退化
    
    // 顶点buffer
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);    // GL_STATIC_DRAW 不能被更新
    
    // 顶点索引buffer
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

+ (void)drawElements {
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

@end
