//
//  Camera.m
//  Camera-Metal
//
//  Created by Xcode Developer on 5/29/21.
//

#import "Camera.h"

@implementation Camera

@synthesize videoOutputDelegate = _videoOutputDelegate;

+ (Camera *)sharedCamera
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    static Camera *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)setVideoOutputDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)videoOutputDelegate
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    _videoOutputDelegate = videoOutputDelegate;
}

- (id<AVCaptureVideoDataOutputSampleBufferDelegate>)videoOutputDelegate
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return _videoOutputDelegate;
}

- (void)sharedCaptureDeviceWithVideoOutputDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)videoOutputDelegate
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self setVideoOutputDelegate:videoOutputDelegate];
    self->sampleBufferQueue = dispatch_queue_create_with_target("sample buffer delegate queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
    __weak typeof(sampleBufferQueue) w_sampleBufferQueue = self->sampleBufferQueue;
    
    sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_CONCURRENT );
    if (!self->_captureSession) {
        @try {
            self->_captureSession = [[AVCaptureSession alloc] init];
            dispatch_async(sessionQueue, ^{
                [self->_captureSession beginConfiguration];
                if ([self->_captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
                    [self->_captureSession setSessionPreset:AVCaptureSessionPreset3840x2160];
                }
                
                //                self->_captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
                //                if ([self->_captureDevice isExposureModeSupported:AVCaptureExposureModeCustom]) {
                //                    CMTime maxExposure = self->_captureDevice.activeFormat.maxExposureDuration;
                //                    if ( [self->_captureDevice lockForConfiguration:NULL] == YES ) {
                //                        [self->_captureDevice setExposureMode:AVCaptureExposureModeCustom];
                //                        __weak typeof(AVCaptureDevice *) w_captureDevice = self->_captureDevice;
                //                        [self->_captureDevice setExposureModeCustomWithDuration:maxExposure ISO:self->_captureDevice.activeFormat.minISO completionHandler:^(CMTime syncTime) {
                //                            __strong typeof(AVCaptureDevice *) s_captureDevice = w_captureDevice;
                //                            [s_captureDevice unlockForConfiguration];
                //                        }];
                //                    }
                //                }
                
                self->_captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
                @try {
                    __autoreleasing NSError *error = NULL;
                    [self->_captureDevice lockForConfiguration:&error];
                    if (error) {
                        NSException* exception = [NSException
                                                  exceptionWithName:error.domain
                                                  reason:error.localizedDescription
                                                  userInfo:@{@"Error Code" : @(error.code)}];
                        @throw exception;
                    }
                    if ([self->_captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
                        [self->_captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                    if ([self->_captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
                        [self->_captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                } @catch (NSException *exception) {
                    NSLog(@"Error configuring camera:\n\t%@\n\t%@\n\t%lu",
                          exception.name,
                          exception.reason,
                          ((NSNumber *)[exception.userInfo valueForKey:@"Error Code"]).unsignedIntegerValue);
                } @finally {
                    [self->_captureDevice unlockForConfiguration];
                }
                
                NSError * error;
                self->_captureInput = [AVCaptureDeviceInput deviceInputWithDevice:self->_captureDevice error:&error];
                if ([self->_captureSession canAddInput:self->_captureInput])
                    [self->_captureSession addInput:self->_captureInput];
                
                self->_captureOutput = [[AVCaptureVideoDataOutput alloc] init];
                [self->_captureOutput setAlwaysDiscardsLateVideoFrames:NO];
                [self->_captureOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
                __strong typeof(w_sampleBufferQueue) s_sampleBufferQueue = w_sampleBufferQueue;
                [self->_captureOutput setSampleBufferDelegate:self->_videoOutputDelegate queue:s_sampleBufferQueue];
                
                if ([self->_captureSession canAddOutput:self->_captureOutput])
                    [self->_captureSession addOutput:self->_captureOutput];
                
                AVCaptureConnection *videoDataCaptureConnection = [[AVCaptureConnection alloc] initWithInputPorts:self->_captureInput.ports output:self->_captureOutput]; //[self->_captureOutput connectionWithMediaType:AVMediaTypeVideo];
                if ([videoDataCaptureConnection isVideoOrientationSupported])
                {
                    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
                    [videoDataCaptureConnection setVideoOrientation:orientation];
                }
                
                if ([self->_captureSession canAddConnection:videoDataCaptureConnection])
                    [self->_captureSession addConnection:videoDataCaptureConnection];
                
                [self->_captureSession commitConfiguration];
            });
            
            dispatch_sync(sessionQueue, ^{
                [self->_captureSession startRunning];
            });
            
        } @catch (NSException *exception) {
            NSLog(@"Camera setup error: %@", exception.description);
        } @finally {
            NSLog(@"%s", __PRETTY_FUNCTION__);
        }
    }
}

@end

