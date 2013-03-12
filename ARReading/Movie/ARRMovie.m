//
//  ARRMovie.m
//  ARReading
//
//  Created by tclh123 on 13-3-11.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "ARRMovie.h"

@implementation ARRMovie

- (id)initWithPath:(NSString*)path frameRate:(int)frameRate {
    self = [super init];
    if (self) {
        
        _frameRate = frameRate;
        
        glGenTextures(1, &_targetTextureId); // 创建一个纹理对象
        glBindTexture(GL_TEXTURE_2D, _targetTextureId);  // 把我们新建的纹理名字加载到当前的纹理单元中

        _asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
        [self initReader];
        [self initTimer];
    }
    return self;
}

- (void)initReader {
    // video track
    AVAssetTrack *track = [[_asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    NSDictionary *setting = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                        forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    
    // AVAssetReaderTrackOutput
    _assetReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:setting];
    
    // important for decoding perfomance!!! (>=iOS5.0)
    if( [_assetReaderOutput respondsToSelector:@selector(alwaysCopiesSampleData)] ){
        _assetReaderOutput.alwaysCopiesSampleData = NO;
    }
    
    // AssetReader
    _assetReader = [[AVAssetReader alloc] initWithAsset:_asset error:nil];
    [_assetReader addOutput:_assetReaderOutput];
    
    // 时间
//    CMTime tm = CMTimeMake((int64_t)(_currentTime*30000), 30000);
//    [_assetReader setTimeRange:CMTimeRangeMake(tm,_asset.duration)];
    
    [_assetReader startReading];
}

- (void)initTimer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // create our timer source
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // set the time to fire (we're only going to fire once,
    // so just fill in the initial time).
    dispatch_source_set_timer(_timer,
                              dispatch_walltime(NULL, 0),
                              1.0/_frameRate * NSEC_PER_SEC, 0);
    
    // Hey, let's actually do something when the timer fires!
    dispatch_source_set_event_handler(_timer, ^{
        [self captureLoop];
    });
}

- (void)start {
//    if (_timer) {
    dispatch_resume(_timer);
}

- (void)stop {
    dispatch_suspend(_timer);
}

// 漆黑一片，不知道为什么
- (void)captureLoop {
    CMSampleBufferRef sampleBuffer = [_assetReaderOutput copyNextSampleBuffer];     // copyNextSampleBuffer ！！
	if( !sampleBuffer ){ return; }
	_currentTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
	CVPixelBufferRef pixBuff = CMSampleBufferGetImageBuffer(sampleBuffer);  // 获得 pixBuff
    
    ////////
    
    CVPixelBufferLockBaseAddress(pixBuff, 0);
	
	for(int i=GL_TEXTURE0;i<GL_ACTIVE_TEXTURE;i++){
		glActiveTexture(i);
		glBindTexture(GL_TEXTURE_2D,0);
	}
	
    unsigned char* baseAddress = (unsigned char*)CVPixelBufferGetBaseAddress(pixBuff);       // _textures[0].data
	
    _width = CVPixelBufferGetBytesPerRow(pixBuff)/4;
    _height = CVPixelBufferGetHeight(pixBuff);
    _displayWidth = CVPixelBufferGetWidth(pixBuff);

    glBindTexture(GL_TEXTURE_2D, _targetTextureId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, baseAddress);     // gl <- _textures.data
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);


	CVPixelBufferUnlockBaseAddress(pixBuff, 0);
	
//	uint32_t textureIds[2] = {_textures[0].textureId,_textures[1].textureId};
//	float wr = (float)_width/_displayWidth;
//	[_fboTexture bind];
//	[_imageShader renderWithTexture:textureIds num:_texNum size:CGSizeMake(wr,1)];
//	[_fboTexture unbind];
//	glBindTexture(GL_TEXTURE_2D, 0);
    
    ///////
    
	CVPixelBufferRelease(pixBuff);
	CMSampleBufferInvalidate(sampleBuffer);
}

@end
