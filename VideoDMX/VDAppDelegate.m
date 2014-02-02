//
//  VDAppDelegate.m
//  VideoDMX
//
//  Created by Phil Christensen on 2/2/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import "VDAppDelegate.h"

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
    
    [self.captureSession startRunning];
}

@end
