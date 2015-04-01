//
//  MangaScreenSaver
//  FuckScreenSaver
//
//  Created by Yu Lo on 3/22/15.
//  Copyright (c) 2015 Horns & Hoofs. All rights reserved.
//

#import "MangaScreenSaver.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>


@interface MangaScreenSaver ()
@property (nonatomic, retain) NSImage *prevImage;
@property (nonatomic, retain) NSImage *nextImage;
@property (nonatomic, retain) NSString *prevImageName;
@property (nonatomic, retain) NSString *nextImageName;
@property (nonatomic, retain) NSArray *allPictureNames;
@property (nonatomic, retain) NSString *dirPictures;
@property (nonatomic, assign) int picIndex;


@property (nonatomic, retain) NSAttributedString	*titleText;
@property (nonatomic, assign) NSRect screenRect;
@property (nonatomic, retain) NSError	*error;
@property (nonatomic, assign) NSTimeInterval	tiStart;
@property (nonatomic, assign) NSTimeInterval	tiWaitUntilTime;
//
@property (nonatomic, retain) IBOutlet NSPanel	*settingsPanel;
@end


@implementation MangaScreenSaver {
	//kCICategoryTransition
	CIContext	*ciContext;
	CIFilter	*ciFilter;
	NSTimeInterval	tiStartFilter;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
		
		self.dirPictures = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"comix"];
		
		
		
		
		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:self.dirPictures];
		NSMutableArray *arrFiles = [NSMutableArray arrayWithCapacity:128];
		NSString *file;
		while ((file = [dirEnum nextObject])) {
			NSString *ext = [[file pathExtension] lowercaseString];
			if ([ext isEqualToString: @"jpg"]) {
				// process the document
				[arrFiles addObject:file];
			}
		}
		self.allPictureNames = arrFiles;

		
		
		
		
		NSError *error = nil;
		
		int picCount = (int)self.allPictureNames.count;
		self.titleText = [self attributedStringWithPlainString:[NSString stringWithFormat:@"got %X files", picCount]];
    }
    return self;
}

- (NSAttributedString *)attributedStringWithPlainString:(NSString *)plainString {
	NSDictionary *attributes = @{ NSFontAttributeName : [NSFont boldSystemFontOfSize:50],
								  NSForegroundColorAttributeName : [NSColor colorWithCalibratedRed:0 green:0 blue:0.4 alpha:1],
								  NSBackgroundColorAttributeName : [NSColor blackColor]};
	return [[NSAttributedString alloc] initWithString:plainString attributes:attributes];
}

- (void)startAnimation
{
    [super startAnimation];
	self.picIndex = 0;
	self.tiStart = [NSDate timeIntervalSinceReferenceDate];
	self.tiWaitUntilTime = 0;
	self.screenRect = [NSScreen mainScreen].frame;
	[self loadNextPicture];
}

CORE_IMAGE_EXPORT NSString *kCIOutputImageKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputBackgroundImageKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputImageKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputTimeKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputTransformKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputScaleKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputAspectRatioKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputCenterKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputRadiusKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputAngleKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputRefractionKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputWidthKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputSharpnessKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputIntensityKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputEVKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputSaturationKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputColorKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputBrightnessKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputContrastKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputGradientImageKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputMaskImageKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputShadingImageKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputTargetImageKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;
CORE_IMAGE_EXPORT NSString *kCIInputExtentKey AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER;

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect inContext:(CGContextRef)cx {
	
	CGImageRef cgImg = [self createNextCGImage];
	NSString *imgInfo = nil;
	if (cgImg) {
		const CGSize imgSize = CGSizeMake(CGImageGetWidth(cgImg), CGImageGetHeight(cgImg));
		const CGFloat imgRatio = imgSize.width/imgSize.height;

		CGRect imgRect = {0};
		imgRect.size.height = rect.size.height;
		imgRect.size.width = rect.size.height * imgRatio;
		imgRect.origin.x = rect.origin.x + 0.5*(rect.size.width - imgRect.size.width);
		imgRect.origin.y = rect.origin.y + 0.5*(rect.size.height - imgRect.size.height);

		CGContextDrawImage(cx, imgRect, cgImg);
		CGImageRelease(cgImg), cgImg = NULL;
	}
	
	if ((0)) {
		//	draw picture
		NSImage *image = self.nextImage;
		if (image) {
			const NSSize imgSize = image.size;
			const CGFloat imgRatio = imgSize.width/imgSize.height;
			NSRect imgRect = {0};
			imgRect.size.height = rect.size.height;
			imgRect.size.width = rect.size.height * imgRatio;
			imgRect.origin.x = rect.origin.x + 0.5*(rect.size.width - imgRect.size.width);
			imgRect.origin.y = rect.origin.y + 0.5*(rect.size.height - imgRect.size.height);
			[image drawInRect:imgRect];
		}
	}
	
	if (self.titleText) {
		CGFloat posY = rect.size.height + rect.origin.y - 300;
		const NSTimeInterval dt = [NSDate timeIntervalSinceReferenceDate] - self.tiStart;
		CGFloat offY = cosf(dt) * 25.0f;
		[self.titleText drawAtPoint:NSMakePoint(20, posY+offY)];
	}
	
	[[NSColor colorWithCalibratedRed:0 green:0.1 blue:0 alpha:1] set];
	CGRect ellipse = CGRectMake(10, 10, 100, 100);
	CGContextFillEllipseInRect(cx, ellipse);
	
	if ((1)) {
		static int frameIndex = 0;
		NSAttributedString *info = [self attributedStringWithPlainString:[NSString stringWithFormat:@"frame #%04d %@", frameIndex++, imgInfo?imgInfo:@""]];
		NSPoint infoPoint = NSMakePoint(100, 100);
		[info drawAtPoint:infoPoint];
	}
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	if (fabsf(rect.size.width - self.screenRect.size.width) > 5) {
		//	one more check
		_screenRect.size.width = rect.size.width;
	}
	
	[self lockFocus];

	NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
	[currentContext saveGraphicsState];
	
	CGContextRef cx = [currentContext graphicsPort];
	if (!ciContext) {
		ciContext = [currentContext CIContext];
	}
	[self drawRect:rect inContext:cx];

	[currentContext restoreGraphicsState];

	[self unlockFocus];
}

- (CGImageRef)createNextCGImage {
	if (ciFilter && ciContext) {
		NSTimeInterval dt = [NSDate timeIntervalSinceReferenceDate] - tiStartFilter;
		if (dt > 1) {
			dt = 1;
		}
		[ciFilter setValue:@(dt) forKey:kCIInputTimeKey];
		CIImage *result = [ciFilter valueForKey:@"inputTime"];//kCIOutputImageKey];
		CGRect extent = [result extent];
		CGImageRef cgImage = [ciContext createCGImage:result fromRect:extent];
		return cgImage;
	}
	
	return NULL;
}

- (void)animateOneFrame
{
	[self setNeedsDisplay:YES];

	
	const NSTimeInterval tiNow = [NSDate timeIntervalSinceReferenceDate];
	if (self.tiWaitUntilTime > 1) {
		if (tiNow < self.tiWaitUntilTime) {
			//	skip and wait until the set time
			return;
		}
	}

	self.tiWaitUntilTime = tiNow + 3.0;
	[self loadNextPicture];
	
}

#pragma mark - Quotation logic

- (void)loadNextPicture {
	if (0 == self.allPictureNames.count) {
		return;
	}
	if (self.picIndex >= self.allPictureNames.count) {
		self.picIndex = 0;
	}
	
	NSString *file = self.allPictureNames[self.picIndex++];
	self.prevImageName = self.nextImageName;
	NSString *imgPath = [self.dirPictures stringByAppendingPathComponent:file];
	self.nextImageName = imgPath;
	
	if (self.nextImageName && self.prevImageName) {
		NSURL *url = [NSURL fileURLWithPath:self.nextImageName];
		CIImage *ciImgNext = [CIImage imageWithContentsOfURL:url];
		url = [NSURL fileURLWithPath:self.prevImageName];
		CIImage *ciImgPrev = [CIImage imageWithContentsOfURL:url];
		
		ciFilter = [CIFilter filterWithName:@"CIAccordionFoldTransition"];
		[ciFilter setValue:ciImgPrev forKey:kCIInputImageKey];
		[ciFilter setValue:ciImgNext forKey:kCIInputTargetImageKey];
		[ciFilter setValue:@(0.0) forKey:kCIInputTimeKey];
		[ciFilter setValue:@(3) forKey:@"inputNumberOfFolds"];
		[ciFilter setValue:@(0.5) forKey:@"inputFoldShadowAmount"];
		[ciFilter setValue:@(50) forKey:@"inputBottomHeight"];

		tiStartFilter = [NSDate timeIntervalSinceReferenceDate];
	}
	
	NSImage *img = [[NSImage alloc] initWithContentsOfFile:imgPath];
	self.prevImage = self.nextImage;
	self.nextImage = img;
}

#pragma mark - configure sheet logic

- (BOOL)hasConfigureSheet {
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

- (IBAction)actCloseSettings:(id)sender {
	//	[[self.settingsPanel parentWindow] endSheet:self.settingsPanel];//does not work
	[[NSApplication sharedApplication] endSheet:self.settingsPanel];
	self.settingsPanel = nil;
}

@end
