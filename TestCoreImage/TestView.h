//
//  TestView.h
//  FuckScreenSaver
//
//  Created by Yu Lo on 4/1/15.
//  Copyright (c) 2015 Horns & Hoofs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TestView : NSView

- (void)updateTime:(float)dt;
- (void)setSrcImage:(NSString *)srcImgPath dstImage:(NSString *)dstImgPath;

@end
