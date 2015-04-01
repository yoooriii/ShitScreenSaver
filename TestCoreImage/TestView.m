//
//  TestView.m
//  FuckScreenSaver
//
//  Created by Yu Lo on 4/1/15.
//  Copyright (c) 2015 Horns & Hoofs. All rights reserved.
//

#import "TestView.h"
#import <QuartzCore/QuartzCore.h>
#import "CIFilter(extra).h"

@implementation TestView {
	CIImage	*srcImage, *dstImage;
	CIFilter *ciFilter;
	CIContext *ciContext;
	float filterTime;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	CGContextRef cx = [context graphicsPort];
	
	if (!ciContext) {
		ciContext = [CIContext contextWithCGContext:cx options:nil];
	}
	if (ciFilter) {
		CIImage *result = ciFilter.outputImage;
		CGRect extent = [result extent];
		CGImageRef cgImage = [ciContext createCGImage:result fromRect:extent];
		CGRect imgRect = CGRectMake(10, 80, 300, 450);
		CGContextDrawImage(cx, imgRect, cgImage);
		CGImageRelease(cgImage);
	}
	
	[[NSColor greenColor] set];
	CGContextFillRect(cx, CGRectMake(20, 20, 100, 100));
	
	[context restoreGraphicsState];
}

- (void)updateTime:(float)dt {
	ciFilter.zInputTime = dt;
	[self setNeedsDisplay:YES];
}

- (void)setSrcImage:(NSString *)srcImgPath dstImage:(NSString *)dstImgPath
{
	srcImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:srcImgPath]];
	dstImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:dstImgPath]];
	if (srcImage && dstImage) {
		ciFilter = [CIFilter filterWithName:@"CIDissolveTransition"];
		ciFilter.zInputImage = srcImage;
		ciFilter.zInputTargetImage = dstImage;
		ciFilter.zInputTime = 0;
		
//		[ciFilter setValue:@(3) forKey:@"inputNumberOfFolds"];
//		[ciFilter setValue:@(0.5) forKey:@"inputFoldShadowAmount"];
//		[ciFilter setValue:@(50) forKey:@"inputBottomHeight"];
	}
	
	
	[self setNeedsDisplay:YES];
}

@end
