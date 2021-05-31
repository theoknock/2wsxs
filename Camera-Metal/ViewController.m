//
//  ViewController.m
//  Camera-Metal
//
//  Created by Xcode Developer on 5/29/21.
//

#import "ViewController.h"
#import "Camera.h"
#import "Metal/Metal.h"
#import "MetalKit/MetalKit.h"
#import "UIImage+MBETextureUtilities.h"

#import "TextureSourceQueueEvent.h"

@interface ViewController ()

@end

@implementation ViewController
{
    CVMetalTextureCacheRef _textureCache;
    id <MTLTexture> texture;
}

- (void)viewDidLoad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [super viewDidLoad];
    
//    self.cameraView.frame = self.view.frame;
//
//    _view = (MTKView *)self.view;
//
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    self.mtkView.backgroundColor = UIColor.blackColor;
    self.commandQueue = [self.mtkView.device newCommandQueue];
    
    _filter = [CIFilter filterWithName:@"CIGaussianBlur"];
           _colorSpace = CGColorSpaceCreateDeviceRGB();
    self.context = [CIContext contextWithMTLCommandQueue:self.commandQueue]; //[CIContext contextWithMTLDevice:self.mtkView.device];
    
//    CVMetalTextureCacheCreate(NULL, NULL, m_Device, NULL, &_textureCache);
    
    //    _renderer = [[Renderer alloc] initWithMetalKitView:_view];
    //
    //    [_renderer mtkView:_view drawableSizeWillChange:_view.bounds.size];
    //
    //    _view.delegate = _renderer;
    self->_textureHandler = [TextureSourceQueueEvent textureSourceQueueEvent];
    [[Camera sharedCamera] sharedCaptureDeviceWithVideoOutputDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)self];
}

//- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//
//    size_t width = CVPixelBufferGetWidth(pixelBuffer);
//    size_t height = CVPixelBufferGetHeight(pixelBuffer);
//
//    CVMetalTextureRef textureRef = NULL;
//    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &textureRef);
//
//    if(status == kCVReturnSuccess)
//    {
//        dispatch_async(self->_textureHandler.textureDispatchQueue, ^{
//            __block id<MTLTexture> txtr = CVMetalTextureGetTexture(textureRef);
//            NSLog(@"%s", __PRETTY_FUNCTION__);
//
//            self->_textureHandler.textureDispatchSource = nil;
//            self->_textureHandler.event_index++;
//            const char *label_c = [[NSString stringWithFormat:@"cv%ld", self->_textureHandler.event_index] cStringUsingEncoding:NSUTF8StringEncoding];
//            [self->_textureHandler textureDispatchSource];
//            dispatch_queue_set_specific(self->_textureHandler.textureDispatchQueue, label_c, (void *)CFBridgingRetain(txtr), NULL);
//            dispatch_source_merge_data(self->_textureHandler.textureDispatchSource, self->_textureHandler.event_index);
//
//            CFRelease(textureRef);
//            CVMetalTextureCacheFlush(self->_textureCache, 0);
//        });
//    }
//}



static void MBEReleaseDataCallback(void *info, const void *data, size_t size)
{
    free((void *)data);
}

// Optional: create textures using Metal protocols...
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CVMetalTextureRef textureRef = NULL;
    if (_textureCache == nil) CVMetalTextureCacheCreate(NULL, (__bridge CFDictionaryRef _Nullable)(@{(id)kCVMetalTextureCacheMaximumTextureAgeKey : @(1.0)}), MTLCreateSystemDefaultDevice(), NULL, &_textureCache);
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm_sRGB, width, height, 0, &textureRef);
    
    if(status == kCVReturnSuccess)
    {
        id <MTLTexture>texture = CVMetalTextureGetTexture(textureRef);
        
//        Texture *context = (Texture *)malloc(sizeof(Texture));
//        if (context != NULL)
//        {
//            context->texture = (void *)CFBridgingRetain(texture);
//
//            const char *label = [[NSString stringWithFormat:@"%ld", self->_textureHandler.event_index] cStringUsingEncoding:NSUTF8StringEncoding];
//            dispatch_queue_set_specific([[TextureRenderer sharedContext] textureQueue], label, context, NULL);
//            dispatch_source_merge_data(textureView_.textureQueueEvent, self->_textureHandler.event_index);
//        }
        
        id<MTLCommandBuffer> commandBuffer = self.commandQueue.commandBuffer;
        CIImage *image = [[[CIImage alloc] initWithMTLTexture:texture options:@{kCIImageColorSpace : CFBridgingRelease(CGColorSpaceCreateDeviceRGB())}] imageByApplyingOrientation:4];
//            [image imageByApplyingOrientation:4];
//                [self.filter setValue:inputImage forKey:kCIInputImageKey];
//                [self.filter setValue:@(100) forKey:kCIInputRadiusKey];
//        [self.filter setValue:outputImage forKey:kCIOutputImageKey];
                
                
        UIImage *uiimage = [UIImage imageWithCIImage:image];
        NSLog(@"width\t%f\t\theight\t%f", uiimage.size.width, uiimage.size.height);
        [(UIImageView *)self.imageView setImage:uiimage];
        
        CFRelease(textureRef);
        CVMetalTextureCacheFlush(_textureCache, 0);
    }
    
    //    CVPixelBufferRef pixel_buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CVPixelBufferLockBaseAddress(pixel_buffer, kCVPixelBufferLock_ReadOnly);
//    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
//    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
//    textureDescriptor.width = CVPixelBufferGetWidthOfPlane(pixel_buffer, 0);
//    textureDescriptor.height = CVPixelBufferGetHeightOfPlane(pixel_buffer, 0);
//    textureDescriptor.usage = MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead;
//    NSUInteger bytesPerRow = 4 * textureDescriptor.width;
//
//    texture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor];
//
//    MTLRegion region = {
//        { 0, 0, 0 },
//        {textureDescriptor.width, textureDescriptor.height, 1}};
//
//    [texture replaceRegion:region
//               mipmapLevel:0
//                 withBytes:pixel_buffer
//               bytesPerRow:bytesPerRow];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        id<MTLCommandBuffer> commandBuffer = self.commandQueue.commandBuffer;
//        CIImage *image = [[[CIImage alloc] initWithMTLTexture:texture options:@{kCIImageColorSpace : CFBridgingRelease(CGColorSpaceCreateDeviceRGB())}] imageByApplyingOrientation:4];
////            [image imageByApplyingOrientation:4];
////                [self.filter setValue:inputImage forKey:kCIInputImageKey];
////                [self.filter setValue:@(100) forKey:kCIInputRadiusKey];
////        [self.filter setValue:outputImage forKey:kCIOutputImageKey];
//                
//                
//        UIImage *uiimage = [UIImage imageWithCIImage:image];
//        NSLog(@"width\t%f\t\theight\t%f", uiimage.size.width, uiimage.size.height);
//        [(UIImageView *)self.imageView setImage:uiimage];
//    });
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end
