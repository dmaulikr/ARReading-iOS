//
//  GLYUVShader.h
//  GLMovieTexture
//
//  Created by hayashi on 12/23/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLShaderTest : NSObject
@property (readonly) int position;
//@property (readonly) int normal;
@property (readonly) int texcoord;
@property (readonly) int modelView;
-(void)bind;
-(void)unbind;
-(void)setTexture:(uint32_t)textureId atIndex:(int)index;
-(void)setTexture:(uint32_t)textureId forKey:(NSString*)key;
-(void)resetTextures;
-(void)loadShaders;
@end


// GLTexShader 继承于 GLShader
@interface GLTexShader : GLShaderTest
@end
