//
//  VDAppDelegate.m
//  VideoDMX
//
//  Created by Phil Christensen on 2/2/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import "VDAppDelegate.h"
#import "VDColorButton.h"

NSImage *imageFromSampleBuffer(CMSampleBufferRef sampleBuffer) {
    
    // This example assumes the sample buffer came from an AVCaptureOutput,
    // so its image buffer is known to be a pixel buffer.
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL) {
            // Handle the error appropriately.
            return nil;
        }
    }
    
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider =
    CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage =
    CGImageCreate(width, height, 8, 32, bytesPerRow,
                  colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    // Create and return an image object to represent the Quartz image.
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:(NSSize){ width, height }];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

@implementation VDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice* lastDevice = nil;
    for(AVCaptureDevice *device in devices){
        if([device hasMediaType:AVMediaTypeVideo]){
            NSLog(@"Device name: %@", [device localizedName]);
            lastDevice = device;
        }
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:lastDevice
                                                                        error:&error];
    if(!input){
        NSLog(@"Error in capture config: %@", error);
    }
    [self.captureSession addInput:input];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    
    self.previewLayer.frame = self.cameraView.layer.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.masksToBounds = YES;
    
    [self.cameraView.layer addSublayer:self.previewLayer];
    
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [self.captureSession addOutput:output];
    output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    dispatch_queue_t queue = dispatch_queue_create("MyQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    [self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    NSImage *image = imageFromSampleBuffer(sampleBuffer);
    
    for(id view in [self.window.contentView subviews]){
        if([view isKindOfClass:[VDColorButton class]]){
            VDColorButton* button = (VDColorButton*)view;
            CGPoint buttonOrigin = button.frame.origin;
            CGPoint point = [self.window.contentView convertPoint:buttonOrigin toView:self.cameraView];
            CGFloat x = (image.size.width * point.x) / self.cameraView.frame.size.width;
            CGFloat y = (image.size.height * point.y) / self.cameraView.frame.size.height;
            [button detectColorAt:CGPointMake(x,y) inImage:image];
        }
    }
    
}

@end
