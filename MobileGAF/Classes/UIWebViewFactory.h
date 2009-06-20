//
//  UIWebViewFactory.h
//  MobileGAF
//
//  Created by Juice on 3/30/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kWebViewCount 50
#define kDefaultWidth 320.0
#define kDefaultHeight 45.0

@interface UIWebViewFactory : NSObject <UIWebViewDelegate> {	
	NSMutableArray *webViews;
}

@property (nonatomic, retain) NSMutableArray *webViews;

+ (UIWebViewFactory*)getInstance;

- (UIWebView*)webViewAtIndex:(NSUInteger)index;

@end


