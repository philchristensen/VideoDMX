//
//  VDColorButton.h
//  VideoDMX
//
//  Created by Phil Christensen on 2/3/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VDCameraView;

@interface VDColorButton : NSView

@property VDCameraView* cameraView;
@property NSColor* currentColor;
@property BOOL selected;

-(void)detectColorAt:(CGPoint)point inImage:(NSImage*)image;

@end
