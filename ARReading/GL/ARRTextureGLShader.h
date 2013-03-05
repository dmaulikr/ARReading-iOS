//
//  ARRTextureGLShader.h
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "GLShader.h"

@interface ARRTextureGLShader : GLShader

// attr slot
@property (readonly) GLuint positionSlot;
@property (readonly) GLuint texcoordSlot;

// uniform matrix
@property (readonly) GLuint projectionUniform;
@property (readonly) GLuint modelViewUniform;


-(void)setTexture:(uint32_t)textureId forKey:(NSString*)key;
-(void)setTexture:(uint32_t)textureId atIndex:(int)index;

@end
