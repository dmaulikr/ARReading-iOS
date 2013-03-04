//
//  ARRCameraViewController.h
//  ARReading
//
//  Created by tclh123 on 13-3-4.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "CameraViewController.h"

#include "CoreAR.h"

@class ARRGLView;

@interface ARRCameraViewController : CameraViewController {
    unsigned char	*chaincodeBuff;
	ARRGLView	*glView;
	CRCodeListRef	codeListRef;
}

@end
