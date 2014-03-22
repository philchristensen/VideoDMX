//
//  VDColorButton.m
//  VideoDMX
//
//  Created by Phil Christensen on 2/3/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import "VDColorButton.h"

@implementation VDColorButton

-(void)detectColorAt:(CGPoint)point inImage:(NSImage*)image {
    NSBitmapImageRep* raw_img = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    self.currentColor = [raw_img colorAtX:point.x y:point.y];
    [self setWantsLayer:YES];
    [self performSelectorOnMainThread:@selector(updateDisplay)
                           withObject:nil
                        waitUntilDone:YES];
}

-(void)updateDisplay {
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect {
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(0.5, 0.5, 15, 15)];
    [self.currentColor setFill];
    [ovalPath fill];
    [[NSColor blackColor] setStroke];
    [ovalPath setLineWidth: 1];
    [ovalPath stroke];
}

-(BOOL)acceptsFirstMouse:(NSEvent *)e {
    return YES;
}

- (void)mouseDown:(NSEvent *) e {
    self.lastDragLocation = [e locationInWindow];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    NSPoint newDragLocation = [theEvent locationInWindow];
    NSPoint thisOrigin = [self frame].origin;
    thisOrigin.x += (-self.lastDragLocation.x + newDragLocation.x);
    thisOrigin.y += (-self.lastDragLocation.y + newDragLocation.y);
    [self setFrameOrigin:thisOrigin];
    self.lastDragLocation = newDragLocation;
}
@end
