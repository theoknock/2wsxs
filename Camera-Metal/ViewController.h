//
//  ViewController.h
//  Camera-Metal
//
//  Created by Xcode Developer on 5/29/21.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MetalKit/MetalKit.h>

#import "TextureSourceQueueEvent.h"

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet MTKView *mtkView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) __block TextureSourceQueueEvent * textureHandler;

@property (strong, nonatomic) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic) CIContext *context;

@property (strong, nonatomic, readonly) CIFilter *filter;

@property (assign, nonatomic, readonly) CGColorSpaceRef colorSpace;

@end

