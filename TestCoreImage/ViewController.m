//
//  ViewController.m
//  TestCoreImage
//
//  Created by Yu Lo on 4/1/15.
//  Copyright (c) 2015 Horns & Hoofs. All rights reserved.
//

#import "ViewController.h"
#import "TestView.h"

@interface ViewController ()
@property (nonatomic, retain) IBOutlet TestView *testView;
@property (nonatomic, assign) NSTimeInterval baseTime;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.baseTime = [NSDate timeIntervalSinceReferenceDate];
	[NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(tickTimer:) userInfo:nil repeats:YES];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

- (void)tickTimer:(NSTimer *)timer {
	const NSTimeInterval dt = [NSDate timeIntervalSinceReferenceDate] - self.baseTime;
	[self.testView updateTime:dt];
	[self.view setNeedsDisplay:YES];
}

@end
