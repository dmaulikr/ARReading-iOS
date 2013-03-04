//
//  GLShader.h
//  ARReading
//
//  Created by tclh123 on 13-3-5.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface GLShader : NSObject {
    uint32_t _programId;
}

@property (readonly) GLuint positionSlot;

-(void)bind;
-(void)unbind;
-(void)loadShaders;
-(BOOL)compileShaders:(const char*)vsrc :(const char*)fsrc;

@end
