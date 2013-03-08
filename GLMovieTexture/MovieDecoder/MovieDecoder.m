#import "MovieDecoder.h"
#import "MovieDecoderInternal.h"

#define synthesize_getter(t,p) -(t)p{ return _data->_##p; }

@implementation MovieDecoder

synthesize_getter(int,format)
synthesize_getter(int,frameRate)
synthesize_getter(double,currentTime)
synthesize_getter(BOOL,loop)
synthesize_getter(id<MovieDecoderDelegate>,delegate)    // _data->_delegate

-(id)init{
	self = [super init];
	[self init_];
	return self;
}

-(id)initWithMovie:(NSString*)path format:(int)format{
	self = [super init];
	[self init_];
	_data->_format = format;
    
    _data->_frameRate = 24; // TODO: with movie
	
    [self loadMovie:path];  // 子类重载
	return self;
}

-(void)init_{
	_data = (MovieDecoderData*)malloc(sizeof(MovieDecoderData));
	memset(_data, 0, sizeof(MovieDecoderData));
	_data->_lock = [[NSRecursiveLock alloc] init];
	_data->_stopWatch = [[QCStopWatch stopWatchWithSampleCount:100] retain];
	_data->_format = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;   // why?
	_data->_frameRate = 30;
}

-(void)dealloc{
	[_data->_lock lock];
	NSRecursiveLock *lock = _data->_lock;
//	[_data->_timer invalidate];
	[_data->_stopWatch release];
	free(_data);
	[lock unlock];
	[lock release];
    [super dealloc];
}

-(void)setLoop:(BOOL)loop{
	_data->_loop = loop;
}

-(void)setDelegate:(id<MovieDecoderDelegate>)delegate{
	_data->_delegate = delegate;
}

-(void)setCurrentTime:(double)currentTime{
	_data->_currentTime = currentTime;
}

-(void)setFormat:(int)format{
	_data->_format = format;
}

-(void)setFrameRate:(int)frameRate{
	_data->_frameRate = frameRate;
}

-(BOOL)loadMovie:(NSString*)path{
    // dummy
	return FALSE;
}

// start
-(void)start{
	[_data->_lock lock];
	if( [self isRunning] ){
		[_data->_lock unlock];
		return;
	}
	_data->_initFlag = NO;
	[self preprocessForDecoding];
    
    // 定时循环
//	_data->_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/_data->_frameRate)
//											  target:self
//											selector:@selector(captureLoop)
//											userInfo:nil repeats:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // create our timer source
    _data->_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // set the time to fire (we're only going to fire once,
    // so just fill in the initial time).
    dispatch_source_set_timer(_data->_timer,
                              dispatch_walltime(NULL, 0),
                              1.0/_data->_frameRate * NSEC_PER_SEC, 0);
    
    // Hey, let's actually do something when the timer fires!
    dispatch_source_set_event_handler(_data->_timer, ^{
        [self captureLoop];
        //        dispatch_source_cancel(_timer);
    });
    
    // now that our timer is all set to go, start it
    dispatch_resume(_data->_timer);
    
	[_data->_lock unlock];
}

-(void)pause{
	[_data->_lock lock];
	if( ![self isRunning] ){
		[_data->_lock unlock];
		return;
	}
//	[_data->_timer invalidate];
	_data->_timer = nil;
	[self processForPausing];
	[_data->_lock unlock];
}

-(void)stop{
	[_data->_lock lock];
	_data->_currentTime  = 0;
//	[_data->_timer invalidate];
	_data->_timer = nil;
	[self postprocessForDecoding];
	[_data->_lock unlock];
}

-(void)captureLoop{
//    [_data->_stopWatch start];
    _DP("movie texture:");
    _CRTic();
	[self captureNext];
    _CRToc();
//    [_data->_stopWatch stop];
}

-(void)captureNext{
	[_data->_lock lock];
	[self processForDecoding];
	[_data->_lock unlock];
}

-(BOOL)isFinished{
	return NO;
}

-(BOOL)isRunning{
    // TODO
	return [_data->_timer isValid]? YES : NO;
}

-(void)preprocessForDecoding{}

-(void)postprocessForDecoding{}

-(void)processForDecoding{}

-(void)processForPausing{}

/////////////////////////////////////

+(id)movieDecoder{
	MovieDecoder *decoder = nil;
	if( [AVPlayerMovieDecoder isAvailable] ){
		decoder = [AVPlayerMovieDecoder alloc];
	}else{
		decoder = [AVAssetMovieDecoder alloc];
	}
	return [[decoder init] autorelease];
}

// 静态方法，外部调用
+(id)movieDecoderWithMovie:(NSString*)path format:(int)format{
	MovieDecoder *decoder = nil;
	if( [AVPlayerMovieDecoder isAvailable] ){
		decoder = [AVPlayerMovieDecoder alloc];
	}else{
		decoder = [AVAssetMovieDecoder alloc];
	}
	return [[decoder initWithMovie:path format:format] autorelease];
}

@end
