//
//  TestView.m
//  FuckScreenSaver
//
//  Created by Yu Lo on 4/1/15.
//  Copyright (c) 2015 Horns & Hoofs. All rights reserved.
//

#import "TestView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TestView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	CGContextRef cx = [context graphicsPort];
	
	[[NSColor greenColor] set];
	CGContextFillRect(cx, CGRectMake(20, 20, 100, 100));
	
	[context restoreGraphicsState];
}

- (void)updateTime:(NSTimeInterval)dt {
	
}

@end
