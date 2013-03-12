//
//  ARRMainViewController.m
//  ARReading
//
//  Created by tclh123 on 13-3-4.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "ARRMainViewController.hpp"

#import "ARRGLView.hpp"
#import "ARRMovie.h"
#import "GLMovieTexture.h"

@interface ARRMainViewController() {
    GLMovieTexture *movie;
}

@end

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
    _camera = [[ARRCameraViewController alloc] initWithCameraViewControllerType:(CameraViewControllerType)(BufferGrayColor|BufferSize480x360|SupportMultiThreading)];

    // add camera
    [_camera.view setFrame:self.view.bounds];
	[self.view addSubview:_camera.view];    // on iOS 5, addSubview also will call viewWillAppear!!
    
    
    /*
    //////////// Test Without Camera
    
    CGRect r = self.view.frame;
	r.size.height = r.size.width / 360.0 * 480.0;
	ARRGLView *glView = [[ARRGLView alloc] initWithFrame:r];
    
	[glView setCameraFrameSize:CGSizeMake(480, 360)];
    [glView setupOpenGLViewWithFocalX:457.89 focalY:457.89];
    [self.view addSubview:glView];
    [glView createTexture];
    
    // Image Texture
//    glView.targetTextureId = [glView createTextureWithImageFile:@"tile_floor.png"];
    
    // Movie Texture
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sintel.ipad" ofType:@"mp4"];
//    ARRMovie *movie = [[ARRMovie alloc] initWithPath:path frameRate:24];
//    glView.targetTextureId = movie.targetTextureId;
//    [movie start];
    
    movie = [[GLMovieTexture alloc] initWithMovie:path context:glView.context];
	[movie setTextureId:glView.targetTextureId];    // movieTexture -> targetTextureId
	[movie setLoop:YES];
	[movie play];
    
    [glView startAnimation];  // startAnimation?
//	[self.view addSubview:glView];
    */
    
}

@end
