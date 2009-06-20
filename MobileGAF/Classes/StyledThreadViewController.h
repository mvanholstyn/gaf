//
//  StyledThreadViewController.h
//  MobileGAF
//
//  Created by Juice on 4/14/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "PostHtmlParser.h"
#import "UINavigationBarTouchable.h"
#import "MGTableViewController.h"

#define kPageTabBarHeight 40
#define kReplyQuoteImgUrl @"bundle://replyQuote.png"
#define kEditQuoteImgUrl @"bundle://editQuote.png"
#define kDefaultAvatarImgUrl @"bundle://defaultAuthorIcon.png"

@protocol HtmlParserDelegate,TTStyledTextTouchDelegate;

@class StyledPostHtmlParser, Thread;

@interface StyledThreadViewController : MGTableViewController <UIAlertViewDelegate,TTTabDelegate,TTMessageControllerDelegate,TTURLRequestDelegate,TTStyledTextTouchDelegate> {	
	
	TTTabStrip *pageTabBar;
	
	StyledPostHtmlParser *postHtmlParser;	
	
	NSUInteger pageNumberBeingLoaded;
	
	NSMutableArray *postsArray;
	Thread *thread;
	
	//In progress reply
	NSString *replyTitle;
	NSString *replyBody;
	
	BOOL scrollToBottomOnNextLoad;
}

@property BOOL scrollToBottomOnNextLoad;



- (void)downloadPostsWithThread:(Thread*)aThread withCache:(BOOL)useCache;
- (void)resetContent;

@property NSUInteger pageNumberBeingLoaded;
@property (nonatomic, retain) TTTabStrip *pageTabBar;
@property (nonatomic, retain) StyledPostHtmlParser *postHtmlParser;
@property (nonatomic, retain) NSMutableArray *postsArray;
@property (nonatomic, retain) Thread *thread;
@property (nonatomic, retain) NSString *replyBody;
@property (nonatomic, retain) NSString *replyTitle;

@end











