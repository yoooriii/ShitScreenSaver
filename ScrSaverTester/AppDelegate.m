//
//  AppDelegate.m
//  ScrSaverTester
//
//  Created by Yu Lo on 3/22/15.
//  Copyright (c) 2015 Horns & Hoofs. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSString *pathToQuotations = [[NSBundle mainBundle] pathForResource:@"quotations" ofType:@"txt"];
	NSString *allText = [NSString stringWithContentsOfFile:pathToQuotations encoding:NSUTF8StringEncoding error:NULL];
	NSArray *allQuotations = [allText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
