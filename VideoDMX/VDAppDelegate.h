//
//  VDAppDelegate.h
//  VideoDMX
//
//  Created by Phil Christensen on 2/2/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VDColorButton.h"
#import "VDCameraView.h"

@interface VDAppDelegate : NSObject <NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (assign) IBOutlet NSWindow *window;

@property IBOutlet VDCameraView* cameraView;

@end
