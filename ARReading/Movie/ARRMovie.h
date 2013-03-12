//
//  ARRMovie.h
//  ARReading
//
//  Created by tclh123 on 13-3-11.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@interface ARRMovie : NSObject {
    AVAsset *_asset;
    AVAssetReader *_assetReader;
    AVAssetReaderTrackOutput *_assetReaderOutput;
    
    dispatch_source_t _timer;

    int _frameRate;
    double _currentTime;
    
	int            _width;
	int            _height;
	int            _displayWidth;
}

@property (nonatomic) u_int32_t targetTextureId;

- (id)initWithPath:(NSString*)path frameRate:(int)frameRate;
- (void)start;
- (void)stop;

@end
