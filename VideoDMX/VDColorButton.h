//
//  VDColorButton.h
//  VideoDMX
//
//  Created by Phil Christensen on 2/3/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VDColorButton : NSView

@property NSColor* currentColor;
@property BOOL selected;

-(void)detectColorAt:(CGPoint)point inImage:(NSImage*)image;

@end
