//
//  VDColorButton.m
//  VideoDMX
//
//  Created by Phil Christensen on 2/3/14.
//  Copyright (c) 2014 bubblehouse. All rights reserved.
//

#import "VDColorButton.h"
#import "VDCameraView.h"

@implementation VDColorButton

-(void)awakeFromNib {
    self.selected = NO;
}

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
    //// Color Declarations
    NSColor* glowColor = [NSColor colorWithCalibratedRed: 0.987 green: 0.987 blue: 0.575 alpha: 1];
    
    //// Shadow Declarations
    NSShadow* glow = [[NSShadow alloc] init];
    [glow setShadowColor: glowColor];
    [glow setShadowOffset: NSMakeSize(0.1, 0.1)];
    [glow setShadowBlurRadius: 8];
    
    //// Oval Drawing
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(5.5, 5.5, 21, 21)];
    [NSGraphicsContext saveGraphicsState];
    if(self.selected){
        [glow set];
    }
    [self.currentColor setFill];
    [ovalPath fill];
    [NSGraphicsContext restoreGraphicsState];
    
    if(self.selected){
        [[NSColor whiteColor] setStroke];
    }
    else{
        [[NSColor grayColor] setStroke];
    }
    [ovalPath setLineWidth: 1];
    [ovalPath stroke];
}

-(BOOL)isFlipped {
    return YES;
}

-(BOOL)acceptsFirstResponder{
    return YES;
}

-(void)mouseDown:(NSEvent *) e {
    [[NSCursor closedHandCursor] push];
    [self.cameraView handleSelection:self];
}

-(void)mouseDragged:(NSEvent *)event {
    NSView* superView = [self superview];
    NSRect currentFrame = [self frame];
    NSPoint currentOrigin = currentFrame.origin;
    NSPoint nextOrigin = NSMakePoint(currentOrigin.x + [event deltaX],
                                     currentOrigin.y + ([event deltaY] *
                                                        ([superView isFlipped] ? 1 : -1))
                                     );
    [self setFrameOrigin:nextOrigin];
    [self autoscroll:event];
    [superView setNeedsDisplayInRect:NSUnionRect(currentFrame, [self frame])];
}

-(void)mouseUp:(NSEvent*)event {
    [NSCursor pop];
    [[self window] invalidateCursorRectsForView:self];
}

@end
