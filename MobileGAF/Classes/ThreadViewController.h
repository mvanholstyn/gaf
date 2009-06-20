//
//  ThreadViewController.h
//  MobileGAF
//
//  Created by Juice on 3/22/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#define kDefaultRowHeight 45.0

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "PostCell.h"

@class Thread, PostHtmlParser;

//FYI: showthread.php?goto=lastpost&t=340575 will quickly get you to the last page.

@interface ThreadViewController : UITableViewController <HtmlParserDelegate, PostCellDelegate, UITableViewDelegate> {
	UIBarButtonItem *refreshButton;	
	UIToolbar *toolbar;
	
	NSMutableArray *postsArray;
	NSMutableDictionary *postCells;
	
	NSUInteger fullyRenderedPostCount;
	UIAlertView *progressAlert;
	UIProgressView *progressView;
	
	PostHtmlParser *postHtmlParser;	
	Thread *thread;
}

- (void)downloadPostsWithThread:(Thread*)aThread withCache:(BOOL)useCache;
- (void)resetContent;

@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSMutableDictionary *postCells;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) NSMutableArray *postsArray;
@property (nonatomic, retain) Thread *thread;
@property (nonatomic, retain) PostHtmlParser *postHtmlParser;
@property (nonatomic, retain) UIAlertView *progressAlert;
@property (nonatomic, retain) UIProgressView *progressView;


@end









