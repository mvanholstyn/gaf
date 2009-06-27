//
//  RootViewController.m
//  MobileGAF
//
//  Created by Juice on 3/20/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ForumHtmlParser.h"
#import "RootViewController.h"
#import "ForumViewController.h"
#import "Forum.h"
#import "Account.h"
#import "UINavigationBarTouchable.h"
#import "LoginRequestDispatcher.h"
#import "NSObject+ObjectiveResource.h"

@interface RootViewController() 

-(void) resetContent;

@end


@implementation RootViewController

@synthesize hasOpenedOneForumSinceLaunch;
@synthesize forumHtmlParser;
@synthesize forumViewController;
@synthesize forumsArray;
//@synthesize refreshButton;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[forumsArray release];
	[forumHtmlParser release];
	[forumViewController release];
//	[refreshButton release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark MGTableViewController

- (void)setUpToolbar:(MGToolbar*)toolbar {
	[[toolbar itemWithTag:kRefreshTag] setEnabled:YES];
	[[toolbar itemWithTag:kSearchTag] setEnabled:YES];
	[[toolbar itemWithTag:kReplyTag] setEnabled:NO];
}

- (void)resetContent {
	NSLog(@"Doing a content reset on the root view.");
	[self.forumsArray removeAllObjects];
	[self updateView];
}

//Designated method for downloading threads
-(void) downloadForumsWithCache:(BOOL)useCache {
	//NSLog(@"Downloading Forums!");
/*	ObjectiveResource POC //
	if(forumHtmlParser != nil && forumHtmlParser.loading == YES) {
		NSLog(@"We're already loading. Cancelling the request to download forums");
		return;		
	} 
 */
	[[MG_TOOLBAR itemWithTag:kRefreshTag] setEnabled:NO];
	if([forumsArray count] == 0) {
		[self invalidateViewState:TTViewLoading];	
	}
		
//	NSMutableString* url = [[[NSMutableString alloc] initWithString:kNeoGafBaseUrl] autorelease];
//	[url appendString:kForumPage];
	
	NSArray *forums = [Forum findAllRemote];
	
	[self handleParseResults:[forums mutableCopy]];
	
	//ObjResource test 
	//forumHtmlParser = [[ForumHtmlParser alloc] initWithUrl:url delegate:self isCaching:useCache];
	//[forumHtmlParser beginLoadingAndParsing];
}

-(void) refresh {
	[self downloadForumsWithCache:NO];
}

#pragma mark -
#pragma mark HtmlParserDelegate Methods

- (void)handleParseResults:(NSMutableArray*)results {	
	//NSLog(@"Handling parse results.");
	[self invalidateViewState:TTViewLoading];
	
	[self setForumsArray:results];
	
	//Release the parser
	[forumHtmlParser release];
	forumHtmlParser = nil;
	
	//NSLog(@"Array of forums is length: %d",[forumsArray count]);
	
	[self updateView];
	
	if([forumsArray count] > 0) 
		[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];		
	
	[[MG_TOOLBAR itemWithTag:kRefreshTag] setEnabled:YES];
	[super handleParseResults:results];
}

- (void)parsingFailed:(NSError*)error {
	[super parsingFailed:error];
	[[MG_TOOLBAR itemWithTag:kRefreshTag] setEnabled:YES];
}

#pragma mark -
#pragma mark TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
	NSMutableArray *fields = [[[NSMutableArray alloc] initWithCapacity:forumsArray.count] autorelease];
	
	for(int i=0;i<forumsArray.count;i++) {
		Forum *forum = [forumsArray objectAtIndex:i];
		
		[fields addObject: 
		 [[[TTSubtextTableField alloc] 
		   initWithText:forum.name
		   subtext:[NSString stringWithFormat:@"%@ threads, %@ posts",forum.threadCount,forum.postCount]] autorelease]];
	}
	
	//MGTableViewController will return a list data source. We're intentionally adding to the end.
	[fields addObjectsFromArray:[(TTListDataSource*)[super createDataSource] items]];
	
	TTListDataSource *ds = [[[TTListDataSource alloc] initWithItems:fields] autorelease];
	
	return ds;
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	//NSLog(@"Drilling down from forums to threads.");
	if([self viewState] == TTViewDataLoadedError) {
		NSLog(@"View is currently in an error state, ignoring drill-down attempt");
		return;
	}
	
	if([forumsArray count] > indexPath.row) {
		Forum *selForum = (Forum*)[forumsArray objectAtIndex:indexPath.row];
		if(self.hasOpenedOneForumSinceLaunch && ![selForum.name isEqualToString:self.forumViewController.forum.name]) {
			//User switched forums. Let's clear out the gunk.
			[self.forumViewController setForum:selForum];
			[self.forumViewController resetContent];
		}	
		
		[self.forumViewController setForum:selForum];
		[self.navigationController pushViewController:forumViewController animated:YES];
		self.hasOpenedOneForumSinceLaunch = YES;		
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	//NSLog(@"Loading Forum View");
	[super loadView];
	
	self.hasOpenedOneForumSinceLaunch = NO;

	[self setAdjustingFontOnNavigationItemWithTitle:@"MobileGAF"];
	
	[self setForumsArray:[[[NSMutableArray alloc] initWithCapacity:2] autorelease]];
	[self setForumViewController:[[[ForumViewController alloc] init] autorelease]];		
	
	[self downloadForumsWithCache:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setUpToolbar:MG_TOOLBAR];
	
	//NSLog(@"View will appear called on root view controller");
	if(forumsArray.count == 0 && (forumHtmlParser == nil || forumHtmlParser.loading == NO)) {
		NSLog(@"Loading forums, as view may have been unloaded and then redrawn.");
		[self downloadForumsWithCache:YES];
	}
	
}

@end
