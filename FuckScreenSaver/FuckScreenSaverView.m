//
//  FuckScreenSaverView.m
//  FuckScreenSaver
//
//  Created by Yu Lo on 3/22/15.
//  Copyright (c) 2015 Horns & Hoofs. All rights reserved.
//

#import "FuckScreenSaverView.h"
#import <CoreText/CoreText.h>


@interface FuckScreenSaverView ()
@property (nonatomic, retain) NSAttributedString	*screenText1;
@property (nonatomic, retain) NSAttributedString	*titleText;
@property (nonatomic, retain) NSAffineTransform		*transformText1;
@property (nonatomic, assign) CGSize	screenTextSize1;
@property (nonatomic, assign) NSRect screenRect;
@property (nonatomic, assign) NSInteger	skipFrameCounter;
@property (nonatomic, retain) NSArray	*allQuotations;
@property (nonatomic, retain) NSError	*loadError;
@property (nonatomic, retain) NSDate	*startTime;
//
@property (nonatomic, retain) IBOutlet NSPanel	*settingsPanel;
@end


@implementation FuckScreenSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
		NSString *title = @"Shit happens\nA universal religious concept:";
		NSDictionary *attributes = @{ NSFontAttributeName : [NSFont boldSystemFontOfSize:50],
									  NSForegroundColorAttributeName : [NSColor colorWithCalibratedRed:0 green:0 blue:0.4 alpha:1],
									  NSBackgroundColorAttributeName : [NSColor blackColor]};
		self.titleText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
		
		NSString *pathToQuotations = [[NSBundle bundleForClass:[self class]] pathForResource:@"quotations" ofType:@"txt"];
		NSError *error = nil;
		NSString *allText = [NSString stringWithContentsOfFile:pathToQuotations encoding:NSUTF8StringEncoding error:&error];
		self.loadError = error;
		self.allQuotations = [allText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
	self.startTime = [NSDate date];
	self.screenRect = [NSScreen mainScreen].frame;
	[self takeNextQuotation];
	[self moveTextToStartPosition];
}

- (void)stopAnimation
{
    [super stopAnimation];
	self.screenText1 = nil;
	self.transformText1 = nil;
}

- (void)drawRect:(NSRect)rect inContext:(CGContextRef)cx {
	
	if (self.titleText) {
		CGFloat posY = rect.size.height + rect.origin.y - 300;
		const NSTimeInterval dt = -[self.startTime timeIntervalSinceNow];
		CGFloat offY = cosf(dt) * 25.0f;
		[self.titleText drawAtPoint:NSMakePoint(20, posY+offY)];
	}
	
	if (0 != self.skipFrameCounter) {
		[[NSColor redColor] set];
		CGRect ellipse = CGRectMake(100, 100, 50, 50);
		CGContextFillEllipseInRect(cx, ellipse);
		return;
	}
	
	[[NSColor greenColor] set];
	CGRect ellipse = CGRectMake(10, 10, 100, 100);
	CGContextFillEllipseInRect(cx, ellipse);
	
	if (self.screenText1) {
		[self.transformText1 concat];
		[self.screenText1 drawAtPoint:NSMakePoint(0, 0.3*rect.size.height+rect.origin.y)];
	}
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	if (fabsf(rect.size.width - self.screenRect.size.width) > 5) {
		//	one more check
		_screenRect.size.width = rect.size.width;
		[self moveTextToStartPosition];
	}
	
	[self lockFocus];

	NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
	[currentContext saveGraphicsState];
	
	CGContextRef cx = [currentContext graphicsPort];
	[currentContext restoreGraphicsState];
	[self drawRect:rect inContext:cx];
	
	[self unlockFocus];
}

- (void)animateOneFrame
{
	if (0 != self.skipFrameCounter) {
		self.skipFrameCounter--;
	}
	[self.transformText1 translateXBy:-2 yBy:0];
	NSPoint offsetPoint = [self.transformText1 transformPoint:NSMakePoint(0, 0)];
	if (self.screenTextSize1.width + offsetPoint.x < 0) {
		self.skipFrameCounter = 30;
		//	translate text to the start position
		[self takeNextQuotation];
		[self moveTextToStartPosition];
	}
	
	[self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow *)configureSheet
{
	const BOOL success = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"OptionsWindow" owner:self topLevelObjects:nil];
	if (success) {
		return self.settingsPanel;
	}
	
	const NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
	NSWindow *configureSheet = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 320, 480) styleMask:styleMask backing:[ScreenSaverView backingStoreType] defer:NO];
	configureSheet.backgroundColor = [NSColor blueColor];
    return configureSheet;
}

#pragma mark - Quotation logic

- (void)takeNextQuotation {
	NSString *text = nil;
	if (0 == self.allQuotations.count) {
		if (self.loadError) {
			text = self.loadError.localizedDescription;
		}
		else {
			text = @"Nothing new for today";
		}
	}
	else {
		const NSUInteger indx = rand() % self.allQuotations.count;
		text = self.allQuotations[indx];
	}
	NSRange divRange = [text rangeOfString:@":"];
	NSFont *font = [NSFont boldSystemFontOfSize:36];
	NSDictionary *attributes = @{ NSFontAttributeName : font,
								  NSForegroundColorAttributeName : [NSColor lightGrayColor],
								  NSBackgroundColorAttributeName : [NSColor clearColor]};
	NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
	if (NSNotFound != divRange.location) {
		//	tail
		divRange.length = resultString.length - divRange.location;
		[resultString setAttributes:attributes range:divRange];
		//	head
		divRange.length = divRange.location+1;
		divRange.location = 0;
		NSDictionary *attributes = @{ NSFontAttributeName : font,
									  NSForegroundColorAttributeName : [NSColor whiteColor],
									  NSBackgroundColorAttributeName : [NSColor clearColor]};
		[resultString setAttributes:attributes range:divRange];
	}
	self.screenText1 = resultString;
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.screenText1);
	CFRange stringRange;
	stringRange.location = 0;
	stringRange.length = self.screenText1.length;
	CFDictionaryRef frameAttributes = NULL;
	CFRange fitRange = {0};
	CGSize constraints = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
	self.screenTextSize1 = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, stringRange, frameAttributes, constraints, &fitRange);
}

- (void)moveTextToStartPosition {
	self.transformText1 = [NSAffineTransform new];
	[self.transformText1 translateXBy:self.screenRect.size.width+2 yBy:0];
}

- (IBAction)actCloseSettings:(id)sender {
//	[[self.settingsPanel parentWindow] endSheet:self.settingsPanel];//does not work
	[[NSApplication sharedApplication] endSheet:self.settingsPanel];
	self.settingsPanel = nil;
}

@end
