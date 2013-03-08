/*
 * Real time image processing framework for iOS
 * CameraViewController.h
 *
 * Copyright (c) Yuichi YOSHIDA, 11/04/20
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

#ifdef __cplusplus
extern "C" {
#endif
	
void _tic(void);				// not thread safe
double _toc(void);
double _tocp(void);				// with printf

// 低 4 位
typedef enum _CameraViewControllerType{
	BufferTypeMask				= 0x0f,
	BufferGrayColor				= 0,
	BufferRGBColor				= 1,
}CameraViewControllerType;

// 中间 4 位（5~8）
typedef enum _CameraViewControllerSize{
	BufferSizeMask				= 0xf0,
	BufferSize1280x720			= 0 << 4,
	BufferSize640x480			= 1 << 4,
	BufferSize480x360			= 2 << 4,
	BufferSize192x144			= 3 << 4,
}CameraViewControllerSize;

// 高 1 位（9）
typedef enum _CameraViewControllerMultiThreading{
	MultiThreadingMask			= 0x100,
	NotSupportMultiThreading	= 0 << 8,
	SupportMultiThreading		= 1 << 8,
}CameraViewControllerMultiThreading;

#ifdef __cplusplus
}
#endif

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>
- (void)didUpdateBufferCameraViewController:(CameraViewController*)CameraViewController;
@end

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
	CGSize							bufferSize;
	unsigned char					*buffer;
	AVCaptureSession				*session;
	AVCaptureVideoPreviewLayer		*previewLayer;
	UIView							*previewView;
	float							aspectRatio;
	CameraViewControllerType		type;
	id<CameraViewControllerDelegate>delegate;
	
	// for mesasure frame per second
	NSTimer							*fpsTimer;
	int								frameCounter;
	double							fpsTimeStamp;
	BOOL							canRotate;
}
- (id)initWithCameraViewControllerType:(CameraViewControllerType)value;
- (void)startToMeasureFPS;
@property (nonatomic, readonly) CGSize bufferSize;
@property (nonatomic, assign) id <CameraViewControllerDelegate> delegate;
@end
