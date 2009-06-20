//
//  ForumViewController.h
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationBarTouchable.h"
#import "MGTableViewController.h"

@protocol HtmlParserDelegate;

@class Forum, StyledThreadViewController, ThreadHtmlParser;

@interface ForumViewController : MGTableViewController <TTMessageControllerDelegate, TTURLRequestDelegate> {	
	NSMutableArray *threadsArray;
	
	StyledThreadViewController *threadViewController;
	Forum *forum;
	ThreadHtmlParser *threadHtmlParser;
	
	NSUInteger pageCountInView;
}

-(void)downloadThreadsWithForum:(Forum*)aForum withCache:(BOOL)useCache;
-(void)resetContent;

@property NSUInteger pageCountInView;
@property (nonatomic, retain) ThreadHtmlParser *threadHtmlParser;
@property (nonatomic, retain) StyledThreadViewController *threadViewController;
@property (nonatomic, retain) Forum *forum;
@property (nonatomic, retain) NSMutableArray *threadsArray;

@end










