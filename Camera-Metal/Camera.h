//
//  Camera.h
//  Camera-Metal
//
//  Created by Xcode Developer on 5/29/21.
//

@import Foundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface Camera : NSObject
{
    dispatch_queue_t sampleBufferQueue, sessionQueue;
}

+ (nonnull Camera *)sharedCamera;

- (void)sharedCaptureDeviceWithVideoOutputDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)videoOutputDelegate;

@property (weak, nonatomic, setter=videoOutputDelegate:) id<AVCaptureVideoDataOutputSampleBufferDelegate>videoOutputDelegate;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureOutput;
@property (nonatomic, strong) AVCaptureConnection *captureConnection;
@property (nonatomic, strong) dispatch_queue_t captureSessionQueue;
@property (nonatomic, strong) dispatch_queue_t captureOutputQueue;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;

@end

NS_ASSUME_NONNULL_END
