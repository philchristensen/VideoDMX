//
//  VDCameraView.h
//  VideoDMX
//
//  Created by Phil Christensen on 3/16/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VDCameraView : NSView <AVCaptureVideoDataOutputSampleBufferDelegate>

@property AVCaptureSession* captureSession;
@property AVCaptureVideoPreviewLayer* previewLayer;

@property NSMutableArray* controlPoints;

@end
