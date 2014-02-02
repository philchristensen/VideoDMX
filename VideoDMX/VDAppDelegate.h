//
//  VDAppDelegate.h
//  VideoDMX
//
//  Created by Phil Christensen on 2/2/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property IBOutlet NSView *cameraView;

@property AVCaptureSession* captureSession;
@property AVCaptureVideoPreviewLayer* previewLayer;

@end
