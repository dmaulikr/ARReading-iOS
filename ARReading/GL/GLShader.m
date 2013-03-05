//
//  GLShader.m
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "GLShader.h"
//#import <QuartzCore/QuartzCore.h>

// Nice Stuff!!!
#define GLSL(src) #src

@interface GLShader ( Private )

-(BOOL)compileShader:(const char*)src type:(uint32_t)type;

@end

@implementation GLShader

-(void)bind{
	if( _programId==0 ){
		[self loadShaders];
	}
	if( _programId == 0 ){
		return;
	}
	glUseProgram(_programId);
//	[self resetTextures];
}

-(void)unbind{
//	[self resetTextures];
	glUseProgram(0);
}

-(void)loadShaders{
    // dummy
}

// 加载 vs、fs，重载它以获得其他指针
-(BOOL)compileShaders:(const char*)vsrc :(const char*)fsrc
{
    // 创建 program
	_programId = glCreateProgram();
	if( _programId == 0 ){
		NSLog(@"Failed to create program");
		return FALSE;
	}
    
    // 分别加载 vs、fs
	if( ![self compileShader:vsrc type:GL_VERTEX_SHADER] ){
		return FALSE;
	}
	if( ![self compileShader:fsrc type:GL_FRAGMENT_SHADER] ){
		return FALSE;
	}
	
	glLinkProgram(_programId);
	
	GLint status;
	glGetProgramiv(_programId, GL_LINK_STATUS, &status);
	if( status == 0 ){
		NSLog(@"Failed to link program");
		return FALSE;
	}
	
	return TRUE;
}

#pragma mark -
#pragma mark GLShader ( Private )

// 创建一个 shader
-(BOOL)compileShader:(const char*)src type:(uint32_t)type {
	if( !src ){
		NSLog(@"Failed to load shader");
		return FALSE;
	}
    
    // create
	GLuint shaderId = glCreateShader(type);
	glShaderSource(shaderId, 1, &src, NULL);
	glCompileShader(shaderId);
	
    // log
    GLint loglen;
	glGetShaderiv(shaderId, GL_INFO_LOG_LENGTH, &loglen);
    if( loglen > 0 ){
		char *log = (char *)malloc(loglen);
		glGetShaderInfoLog(shaderId, loglen, &loglen, log);
		NSLog(@"Shader compile log: [%s]", log);
		free(log);
	}
    
    // status
	GLint status = 0;
    glGetShaderiv(shaderId, GL_COMPILE_STATUS, &status);
    if (status == 0){
        glDeleteShader(shaderId);
		NSLog(@"Failed to compile shader");
        return FALSE;
    }
    
    // attach
	glAttachShader(_programId, shaderId);
	glDeleteShader(shaderId);
	return TRUE;
}

@end
