//
//  VDCameraView.h
//  VideoDMX
//
//  Created by Phil Christensen on 3/16/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VDColorButton.h"

@interface VDCameraView : NSView <AVCaptureVideoDataOutputSampleBufferDelegate, NSTableViewDataSource>

@property AVCaptureSession* captureSession;
@property AVCaptureVideoPreviewLayer* previewLayer;

@property NSMutableArray* controlPoints;
@property NSArray* selectedPointInfo;

-(void)handleSelection:(VDColorButton*)button;

@end
