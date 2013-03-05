//
//  ARRMainViewController.m
//  ARReading
//
//  Created by tclh123 on 13-3-4.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "ARRMainViewController.hpp"

//#import "ARRGLView.hpp"

@implementation ARRMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // alloc init camera
    _DP("camera will init.")
    _camera = [[ARRCameraViewController alloc] initWithCameraViewControllerType:(CameraViewControllerType)(BufferGrayColor|BufferSize480x360)];

    // add camera
    _DP("camera.view will add.")
    [_camera.view setFrame:self.view.bounds];
	[self.view addSubview:_camera.view];    // on iOS 5, addSubview also will call viewWillAppear!!

    
//    CGRect r = self.view.frame;
//	r.size.height = r.size.width / 360.0 * 480.0;
//    _DP("glView will init")
//	ARRGLView *glView = [[ARRGLView alloc] initWithFrame:r];
//    
//	[glView setCameraFrameSize:CGSizeMake(480, 360)];
//    [glView setupOpenGLViewWithFocalX:457.89 focalY:457.89];
//	[glView startAnimation];  // startAnimation?
//    
////    [glView renderTest];
//    
//    [self.view addSubview:glView];
}

@end
