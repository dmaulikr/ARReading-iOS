//
//  ARRGLVBOSimple.h
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import <Foundation/Foundation.h>

// 顶点 信息的结构Vertex
typedef struct {
    float Position[3];  //位置
    float Color[4];     //颜色
} Vertex;

@interface ARRGLVBOSimple : NSObject

+ (void)setupVertexBufferObjects;
+ (void)drawElements;

@end
