//
//  UIWebViewFactory.m
//  MobileGAF
//
//  Created by Juice on 3/30/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "UIWebViewFactory.h"

@interface UIWebViewFactory()

- (id)initWithWebViewCount:(NSUInteger)count;

@end


@implementation UIWebViewFactory

@synthesize webViews;

static UIWebViewFactory *factory;

#pragma mark -
#pragma mark Application methods

+ (UIWebViewFactory*)getInstance {
	if(factory == nil) {
		factory = [[UIWebViewFactory alloc] initWithWebViewCount:kWebViewCount];
	}
	return factory;
}

- (UIWebView*)webViewAtIndex:(NSUInteger)index {
	UIWebView *wv = [webViews objectAtIndex:index];
	if(wv == nil) {
		NSLog(@"Web view #%d requested, but hasn't loaded yet; We should raise an exception",index);
		return nil;
	} else {
		return wv;		
	}
}

- (id)initWithWebViewCount:(NSUInteger)count {
	if(self = [super init]) {
		NSLog(@"Initiating %d web views for factory.",kWebViewCount);
		webViews = [[NSMutableArray alloc] initWithCapacity:count];
		
		for (int i = 0; i < count; i++) {

			CGRect webFrame = CGRectMake(0.0, 0.0, kDefaultWidth,kDefaultHeight);
			UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];  
			[webView setBackgroundColor:[UIColor whiteColor]];
			[webView setDelegate:self];
			
			//Load my standard postCell.html page. (JS will be used to differentiate these with content)
			[webView loadRequest:[NSURLRequest requestWithURL:
								  [NSURL fileURLWithPath:[[NSBundle mainBundle]
														  pathForResource:@"postCell" 
														  ofType:@"html"]
											 isDirectory:NO]]];
			
		}
	}
	return self;
}

- (void)dealloc {
	[super dealloc];

//	[factory release]; //how do i dealloc the class var? do I?
	[webViews release];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

/**
 * Once the web view has loaded the local HTML, we'll run this JS against it to push in a 
 *	post.
 ***********/
- (void)webViewDidFinishLoad:(UIWebView *)wv {
	[webViews addObject:wv];
}

@end


