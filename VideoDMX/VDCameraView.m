//
//  VDCameraView.m
//  VideoDMX
//
//  Created by Phil Christensen on 3/16/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import "VDCameraView.h"
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

@implementation VDCameraView

-(void)awakeFromNib {
    self.controlPoints = [NSMutableArray arrayWithArray:@[]];
    [self.controlPoints addObject:[[VDColorButton alloc] initWithFrame:NSMakeRect(86,250,32,32)]];
    [self.controlPoints addObject:[[VDColorButton alloc] initWithFrame:NSMakeRect(53,146,32,32)]];
    [self.controlPoints addObject:[[VDColorButton alloc] initWithFrame:NSMakeRect(243,171,32,32)]];
    [self.controlPoints addObject:[[VDColorButton alloc] initWithFrame:NSMakeRect(236,62,32,32)]];
    [self.controlPoints addObject:[[VDColorButton alloc] initWithFrame:NSMakeRect(357,217,32,32)]];
    [self.controlPoints addObject:[[VDColorButton alloc] initWithFrame:NSMakeRect(403,103,32,32)]];
    
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
    
    self.previewLayer.frame = self.layer.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.masksToBounds = YES;
    
    [self.layer addSublayer:self.previewLayer];
    [self setWantsLayer:YES];
    
    for(VDColorButton* button in self.controlPoints){
        [button setWantsLayer:YES];
        [button setCameraView:self];
        [self addSubview:button];
    }

    
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
    @autoreleasepool {
        NSImage* image = imageFromSampleBuffer(sampleBuffer);
        for(id view in [self subviews]){
            if([view isKindOfClass:[VDColorButton class]]){
                VDColorButton* button = (VDColorButton*)view;
                CGPoint buttonOrigin = button.frame.origin;
                CGPoint point = [self convertPoint:buttonOrigin toView:self];
                CGFloat x = (image.size.width * point.x) / self.frame.size.width;
                CGFloat y = (image.size.height * point.y) / self.frame.size.height;
                [button detectColorAt:CGPointMake(x,y) inImage:image];
            }
        }
    }
}

-(BOOL)isFlipped {
    return YES;
}

-(void)handleSelection:(VDColorButton *)selectedButton {
    for(VDColorButton* button in self.controlPoints){
        if(button.selected){
            button.selected = NO;
            [button setNeedsDisplay:YES];
        }
    }
    selectedButton.selected = YES;
    [selectedButton setNeedsDisplay:YES];
}

@end
