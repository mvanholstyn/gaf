//
//  RootViewController.h
//  MobileGAF
//
//  Created by Juice on 3/20/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileGAFAppDelegate.h"
#import "HtmlParser.h"
#import "UINavigationBarTouchable.h"
#import "MGTableViewController.h"

#define kForumPage @"forumdisplay.php?f=1"

@class ForumViewController, ForumHtmlParser;

@interface RootViewController : MGTableViewController {
	NSMutableArray *forumsArray;
	
	ForumViewController *forumViewController;
	ForumHtmlParser *forumHtmlParser;
	
	BOOL hasOpenedOneForumSinceLaunch;
	
//	UIBarButtonItem *refreshButton;
}

-(void) downloadForumsWithCache:(BOOL)useCache;

@property BOOL hasOpenedOneForumSinceLaunch;
@property (nonatomic, retain) ForumViewController *forumViewController;
@property (nonatomic, retain) NSMutableArray *forumsArray;
@property (nonatomic, retain) ForumHtmlParser *forumHtmlParser;
//@property (nonatomic, retain) UIBarButtonItem *refreshButton;

@end







