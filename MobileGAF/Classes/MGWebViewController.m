//
//  MGWebViewController.m
//  MobileGAF
//
//  Created by Juice on 5/3/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "MGWebViewController.h"


@implementation MGWebViewController

@synthesize urlAsString;

- (id)initWithUrl:(NSString*)aUrl {
	if(self = [super init]) {
		self.urlAsString = aUrl;
	}
	return self;
}

- (void)dealloc {
	[urlAsString release];
	[super dealloc];
}
#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[self openURL:[NSURL URLWithString:self.urlAsString]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end


