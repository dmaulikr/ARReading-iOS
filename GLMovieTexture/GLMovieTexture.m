//
//  GLMovieTexture.m
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//
#import "GLMovieTexture.h"
#import "MovieDecoder.h"
#import "GLFBOTexture.h"
#import "GLImageShader.h"

// iOS
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#define DECODE_FORMAT '420v'
#define USE_GL_TEXTURE_CACHE (1)

// Mac
#elif TARGET_OS_MAC
#import <OpenGL/gl.h>
#define DECODE_FORMAT 'BGRA'
#define USE_GL_TEXTURE_CACHE (0)
#endif

// (iPhone5)
// '420v' '420f' : 3.8msec
// '420v' '420f' : 2.5msec (TextureCache)
// 'BGRA' : 4.0msec
// (iPod touch 4G)
// '420v' : 12msec
// '420f' : 70msec!!!
// 'BGRA' : 18msec

// GLMovieTexture 实现 MovieDecoderDelegate 协议
@interface GLMovieTexture () <MovieDecoderDelegate>
@end

@implementation GLMovieTexture

@synthesize width = _displayWidth;
@synthesize height = _height;
@synthesize format = _format;

-(id)init{
	self = [super init];
	_format = DECODE_FORMAT;
	return self;
}

// 外部调用
-(id)initWithMovie:(NSString*)path context:(EAGLContext*)context{
	self = [super init];
	_format = DECODE_FORMAT;
	[self setGLContext:context];
	[self setMovie:path];
	return self;
}

- (void)dealloc{
	[_decoder stop];
	
#if USE_GL_TEXTURE_CACHE
	if( _textureCache ){
		for (int i=0;i<_texNum;i++){
			if( _textureRef[i] ){
				CFRelease(_textureRef[i]);
			}
		}
		CVOpenGLESTextureCacheFlush(_textureCache,0);
		CFRelease(_textureCache);
	}
#endif
	
	[_fboTexture release];
	[_imageShader release];
	[_decoder release];
	[_context release];
	[super dealloc];
}

-(uint32_t)textureId{
	return _fboTexture.textureId;
}

// setMovie
-(void)setMovie:(NSString*)path{
	_initFlag = NO;
	[_fboTexture release];
	_fboTexture = nil;
	[_decoder release];
	_decoder = [[MovieDecoder movieDecoderWithMovie:path format:_format] retain];   // MovieDecoder 的静态方法
	_width = 0;
	_height = 0;
}

-(void)setGLContext:(EAGLContext*)context{
	_initFlag = NO;
	_mainContext = [context retain];
	[_imageShader release];
	_imageShader = nil;
	[_fboTexture release];
	_fboTexture = nil;
	[_context release];
	[EAGLContext setCurrentContext:context];
	
	uint32_t currentTextureId = 0;
	glGetIntegerv(GL_TEXTURE_BINDING_2D,(int*)&currentTextureId);
	
	if( _format == 'BGRA' ){
		_texNum = 1;
		_textures[0].textureId = [self createTexture];
		_textures[0].format = GL_RGBA;
		_textures[1].textureId = 0;
		_imageShader = [[GLBGRAShader alloc] init];
	}else{
		_texNum = 2;
		_textures[0].textureId = [self createTexture];
		_textures[0].format = GL_LUMINANCE;
		_textures[1].textureId = [self createTexture];
		_textures[1].format = GL_LUMINANCE_ALPHA;
		_imageShader = [[GLYUVShader alloc] init];
	}
	
	_context = [[EAGLContext alloc] initWithAPI:[context API] sharegroup:[context sharegroup]];
	
#if	USE_GL_TEXTURE_CACHE
	if( _textureCache ){
		CFRelease(_textureCache);
		_textureCache = NULL;
	}
	if( CVOpenGLESTextureCacheCreate ){
		CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,NULL, _context, NULL, &_textureCache);
	}
#endif
	
	glBindTexture(GL_TEXTURE_2D, currentTextureId);
}

-(void)setTextureId:(uint32_t)textureId{
	_initFlag = NO;
	_targetTextureId = textureId;
}

-(void)play{
	if( ![_decoder isRunning] ){
		_decoder.delegate = self;
		[_decoder start];
	}
}

-(void)pause{
	[_decoder pause];
}

-(void)stop{
	[_decoder stop];
	_decoder.delegate = nil;
}

-(float)currentTime{
	return (float)_decoder.currentTime;
}

-(void)setCurrentTime:(float)t{
	[_decoder setCurrentTime:t];
}

-(BOOL)loop{
	return _decoder.loop;
}

-(void)setLoop:(BOOL)loop{
	_decoder.loop = loop;
}

-(BOOL)isPlaying{
	return _decoder.isRunning;
}

// 委托
-(void)movieDecoderDidDecodeFrame:(MovieDecoder *)decoder pixelBuffer:(CVPixelBufferRef)pixBuff{
	[EAGLContext setCurrentContext:_context];
	if( _textureCache ){
		[self pixelTransferWithTextureCache:pixBuff];
	}else{
		[self pixelTransferDefault:pixBuff];
	}
	glFlush();
	[EAGLContext setCurrentContext:_mainContext];
}

-(void)movieDecoderDidFinishDecoding:(MovieDecoder *)decoder{
	
}

// 传入 pixBuff；textrue <- pixBuff
-(void)pixelTransferWithTextureCache:(CVPixelBufferRef)pixBuff
{
#if USE_GL_TEXTURE_CACHE
	BOOL firstFrame = NO;
	if( !_initFlag ){
		_initFlag = YES;
		firstFrame = YES;
		if( _format == 'BGRA' ){
			_width = CVPixelBufferGetBytesPerRow(pixBuff)/4;
			_height = CVPixelBufferGetHeight(pixBuff);
			_displayWidth = CVPixelBufferGetWidth(pixBuff);
		}else{
			_width = CVPixelBufferGetBytesPerRowOfPlane(pixBuff,0);
			_height = CVPixelBufferGetHeightOfPlane(pixBuff,0);
			_displayWidth = CVPixelBufferGetWidthOfPlane(pixBuff,0);
		}
		if( _targetTextureId ){
			_fboTexture = [[GLFBOTexture alloc] initWithTextureId:_targetTextureId size:CGSizeMake(_displayWidth,_height)]; // _fboTexture <- _targetTextureId
		}else{
			_fboTexture = [[GLFBOTexture alloc] initWithSize:CGSizeMake(_displayWidth,_height)];
		}
	}
	for (int i=0;i<_texNum;i++){
		if( _textureRef[i] ){
			CFRelease(_textureRef[i]);
			_textureRef[i] = NULL;
		}
	}
	CVOpenGLESTextureCacheFlush(_textureCache,0);   // Core Video
	
	uint32_t textureIds[2];
	for (int i=0;i<_texNum;i++){
		glActiveTexture(GL_TEXTURE0+i);
		CVReturn ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,_textureCache,pixBuff,NULL,GL_TEXTURE_2D,_textures[i].format,_width>>i,_height>>i,_textures[i].format,GL_UNSIGNED_BYTE,i,&_textureRef[i]);
		if( ret != kCVReturnSuccess ){      // fail？
			if( firstFrame ){
				CFRelease(_textureCache);
				_textureCache = NULL;
				_initFlag = YES;
				[_fboTexture release];
				[self pixelTransferDefault:pixBuff];
			}
			return;
		}
		textureIds[i] = CVOpenGLESTextureGetName(_textureRef[i]);
		glBindTexture(GL_TEXTURE_2D,textureIds[i]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
	}
	float wr = (float)_width/_displayWidth;
	[_fboTexture bind];
	[_imageShader renderWithTexture:textureIds num:_texNum size:CGSizeMake(wr,1)];
	[_fboTexture unbind];
#endif
}


-(void)pixelTransferDefault:(CVPixelBufferRef)pixBuff
{
	CVPixelBufferLockBaseAddress(pixBuff, 0);
	
	for(int i=GL_TEXTURE0;i<GL_ACTIVE_TEXTURE;i++){
		glActiveTexture(i);
		glBindTexture(GL_TEXTURE_2D,0);
	}
	
	if( _format == 'BGRA' ){
		_textures[0].data = CVPixelBufferGetBaseAddress(pixBuff);       // _textures[0].data
	}else{
		_textures[0].data = CVPixelBufferGetBaseAddressOfPlane(pixBuff,0);
		_textures[1].data = CVPixelBufferGetBaseAddressOfPlane(pixBuff,1);
	}
	
	if( !_initFlag ){
		_initFlag = YES;
		if( _format == 'BGRA' ){
			_width = CVPixelBufferGetBytesPerRow(pixBuff)/4;
			_height = CVPixelBufferGetHeight(pixBuff);
			_displayWidth = CVPixelBufferGetWidth(pixBuff);
		}else{
			_width = CVPixelBufferGetBytesPerRowOfPlane(pixBuff,0);
			_height = CVPixelBufferGetHeightOfPlane(pixBuff,0);
			_displayWidth = CVPixelBufferGetWidthOfPlane(pixBuff,0);
		}
		for (int i=0;i<_texNum;i++){
			glBindTexture(GL_TEXTURE_2D, _textures[i].textureId);
			glTexImage2D(GL_TEXTURE_2D, 0, _textures[i].format, _width>>i, _height>>i, 0,
						 _textures[i].format, GL_UNSIGNED_BYTE, _textures[i].data);     // gl <- _textures.data
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
		}		
		if( _targetTextureId ){
			_fboTexture = [[GLFBOTexture alloc] initWithTextureId:_targetTextureId size:CGSizeMake(_displayWidth,_height)];
		}else{
			_fboTexture = [[GLFBOTexture alloc] initWithSize:CGSizeMake(_displayWidth,_height)];
		}
	}else{
		for (int i=0;i<_texNum;i++){
			glBindTexture(GL_TEXTURE_2D, _textures[i].textureId);
			glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, _width>>i, _height>>i, _textures[i].format, GL_UNSIGNED_BYTE, _textures[i].data);
		}
	}
	CVPixelBufferUnlockBaseAddress(pixBuff, 0);
	
	uint32_t textureIds[2] = {_textures[0].textureId,_textures[1].textureId};
	float wr = (float)_width/_displayWidth;
	[_fboTexture bind];
	[_imageShader renderWithTexture:textureIds num:_texNum size:CGSizeMake(wr,1)];
	[_fboTexture unbind];
	glBindTexture(GL_TEXTURE_2D, 0);
	
}

-(uint32_t)createTexture{
	uint32_t textureId = 0;
	glGenTextures(1,&textureId);
	glBindTexture(GL_TEXTURE_2D,textureId);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glBindTexture(GL_TEXTURE_2D,0);
	return textureId;
}

@end

#if !(TARGET_OS_IPHONE||TARGET_IPHONE_SIMULATOR)

@implementation EAGLContext

-(id)init{
	self = [super init];
	_context = CGLGetCurrentContext();
	if( _context ){
		CGLRetainContext(_context);
	}
	return self;
}

-(id)initWithContext:(CGLContextObj)context{
	self = [super init];
	_context = context;
	return self;
}

-(id)initWithAPI:(int)api sharegroup:(void*)context{
	self = [super init];
	CGLPixelFormatObj fmt = CGLGetPixelFormat(context);
	CGLCreateContext(fmt, context, (CGLContextObj*)&_context);
	return self;
}

-(int)API{
	return 1;
}

-(void*)sharegroup{
	return _context;
}

- (void)dealloc{
    if( _context ){
		CGLReleaseContext(_context);
	}
    [super dealloc];
}

+(EAGLContext*)currentContext{
	return [[[EAGLContext alloc] init] autorelease];
}

+(void)setCurrentContext:(EAGLContext *)context{
	if( context && context->_context ){
		CGLSetCurrentContext(context->_context);
	}else{
		CGLSetCurrentContext(NULL);
	}
}

@end

#endif


