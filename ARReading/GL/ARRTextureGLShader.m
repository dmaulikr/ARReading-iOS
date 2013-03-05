//
//  ARRTextureGLShader.m
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "ARRTextureGLShader.h"

// Nice Stuff!!!
#define GLSL(src) #src

static int textureUnitIndex = 0;

@interface ARRTextureGLShader () {
    int     _textures[16];  // _textures
}

@end

@implementation ARRTextureGLShader

-(void)resetTextures {
	for(int i=0;i<textureUnitIndex;i++){
		glActiveTexture(GL_TEXTURE0+i);
		glBindTexture(GL_TEXTURE_2D, 0);
	}
	textureUnitIndex = 0;
}

-(void)setTexture:(uint32_t)textureId forKey:(NSString*)key {
	glUniform1i(glGetUniformLocation(_programId,[key UTF8String]), textureUnitIndex);
	glActiveTexture(GL_TEXTURE0+textureUnitIndex);
	glBindTexture(GL_TEXTURE_2D, textureId);
	textureUnitIndex++;
}

-(void)setTexture:(uint32_t)textureId atIndex:(int)index {
	if( index < 0 || index >= 16 ){ return; }
	glUniform1i(_textures[index], textureUnitIndex);
	glActiveTexture(GL_TEXTURE0+textureUnitIndex);
	glBindTexture(GL_TEXTURE_2D, textureId);
	textureUnitIndex++;
}

#pragma mark -

-(void)bind{
    [super bind];
    [self resetTextures];
}

-(void)unbind{
	[self resetTextures];
    [super unbind];
}

-(BOOL)compileShaders:(const char*)vsrc :(const char*)fsrc {
    BOOL ret = [super compileShaders:vsrc :fsrc];
    if (!ret) {
        return NO;
    }
    
    // 获得变量指针
    _positionSlot = glGetAttribLocation(_programId,"Position");
    _texcoordSlot = glGetAttribLocation(_programId, "Texcoord");
    
    // 维护 Uniform 指针
    _projectionUniform = glGetUniformLocation(_programId, "Projection");
    _modelViewUniform = glGetUniformLocation(_programId, "Modelview");
    
    // 支持 16 个 texture（这里只用到一个 _MainTex）
	_textures[0] = glGetUniformLocation(_programId,"_MainTex");
	char texname[16];
	for(int i=1;i<16;i++){
		sprintf(texname,"_SubTex%d",i);
		_textures[i] = glGetUniformLocation(_programId,texname);
	}
    
    return YES;
}

// override loadShaders
-(void)loadShaders{
	const char *src[2] = {
		GLSL(
			 attribute vec4 Position;
			 attribute vec2 Texcoord;
             
             uniform mat4 Modelview;
             uniform mat4 Projection;
             
			 varying vec2 v_TexCoord;
			 void main(){
				 gl_Position = Projection * Modelview * Position;
				 v_TexCoord = Texcoord;
			 }
        ),
		GLSL(
			 varying lowp vec2 v_TexCoord;
			 uniform sampler2D _MainTex;
			 void main(){
				 gl_FragColor = texture2D(_MainTex,v_TexCoord);
			 }
        )
	};
	[self compileShaders:src[0] :src[1]];
}

@end
