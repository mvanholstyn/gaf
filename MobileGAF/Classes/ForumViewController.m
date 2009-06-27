//
//  ForumViewController.m
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "ThreadHtmlParser.h"
#import "ForumViewController.h"
#import "StyledThreadViewController.h"
#import "MobileGAFAppDelegate.h"
#import "UIAlertViewAdditions.h"
#import "NSStringAdditions.h"
#import "Forum.h"
#import "Thread.h"
#import <Three20/Three20.h>
#import "UINavigationBarTouchable.h"
#import "ConnectionManager.h"

@interface ForumViewController()

-(void) loadItems;

@end


@implementation ForumViewController

@synthesize pageCountInView;
@synthesize threadHtmlParser;
@synthesize threadViewController;
@synthesize forum;
@synthesize threadsArray;


#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[threadHtmlParser release];
	[threadsArray release];
	[forum release];
	
	[threadViewController release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark MGTableViewController

- (void)setUpToolbar:(MGToolbar*)toolbar {
	[[toolbar itemWithTag:kRefreshTag] setEnabled:YES];
	[[toolbar itemWithTag:kSearchTag] setEnabled:YES];
	[[toolbar itemWithTag:kReplyTag] setEnabled:YES];
	
	//Replace the reply icon with the compose/author one
	[toolbar replaceItemWithTag:kReplyTag withItem:toolbar.authorButton];
}

- (void)resetContent {
	NSLog(@"Doing a content reset on the forum view.");
	pageCountInView = 1;
	[self.threadsArray removeAllObjects];
	[self updateView];
}

-(void)refresh {
	[self resetContent];
	[self invalidateViewState:TTViewLoading];	
	
	[self downloadThreadsWithForum:self.forum withCache:NO];
}


- (void)refreshAfterSubmitAsNecessary {
	//Trigger a refresh for to see the new listing.
	[self refresh];
	
	//TODO: scroll up after (necessary?)
}

- (NSDictionary*)submissionParamsForEdit {
	return nil;
}
- (NSDictionary*)submissionParamsForCreateOrReply {
	return [NSDictionary dictionaryWithObject:forum.forumId forKey:@"f"];	
}

//Designated method for downloading threads.
-(void)downloadThreadsWithForum:(Forum*)aForum withCache:(BOOL)useCache {
	/*
	if(threadHtmlParser != nil && threadHtmlParser.loading == YES) {
		NSLog(@"We're already loading. Cancelling the request to download threads");
		return;		
	}
	
	NSLog(@"Downloading Threads!");
	NSMutableString* url = [aForum.url mutableCopy];
	[url appendString:[NSString stringWithFormat:@"&page=%d&order=desc",pageCountInView]];			
	
	threadHtmlParser = [[ThreadHtmlParser alloc] initWithUrl:url delegate:self isCaching:useCache];
	[threadHtmlParser beginLoadingAndParsing];
	*/
	
	//Set forum
	[self setForum:aForum];		
	[self setAdjustingFontOnNavigationItemWithTitle:forum.name];

	//Disable button, show loading... screen.
	[[MG_TOOLBAR itemWithTag:kRefreshTag] setEnabled:NO];	
	[self invalidateViewState:TTViewLoading];	
	
	//Kick off an asynchronous load
	[[ConnectionManager sharedInstance] runJob:@selector(loadItems) onTarget:self];
}

//Meanwhile, in a network thread.
-(void) loadItems {	
	//Synchronously retrieve threads
	NSArray *threads = [Thread findAllForForumWithId:forum.forumId];
	
	//Re-enable button, hide loading... screen
	[self invalidateViewState:TTViewDataLoaded];
	[[MG_TOOLBAR itemWithTag:kRefreshTag] setEnabled:YES];
	
	//Handle results
	[self handleParseResults:[threads mutableCopy]];
}

#pragma mark -
#pragma mark HtmlParserDelegate Methods

- (void)handleParseResults:(NSMutableArray*)results {
	//NSLog(@"Handling parse results, size %d.",results.count);	
	BOOL hideStickies = ![[NSUserDefaults standardUserDefaults] boolForKey:@"show_sticky_threads"];
	
	//Gotta prevent dupes. this is O(n^2) tho :-/
	for (Thread *thread in results) {
		if(hideStickies && thread.sticky) {
			continue;
		}
		
		BOOL threadAlreadyExists = NO;
		
		//Only bother to check if we're past the first page.
		if(pageCountInView > 1) {
			for(Thread *existingThread in threadsArray) {
				if([thread.threadId isEqualToString:existingThread.threadId]) {
					//NSLog(@"Duplicate thread found, skipping it. Title: %@",thread.title);
					threadAlreadyExists = YES;
					
					//Update some of the useful metadata about the thread.
					[existingThread setReplierName:thread.replierName];
					[existingThread setPageCount:thread.pageCount];
					[existingThread setReplyCount:thread.replyCount];
					[existingThread setAuthorName:thread.authorName];
					break;
				}
			}
		}
		
		if(!threadAlreadyExists) {
			[self.threadsArray addObject:thread];			
		}
	}
	
	//Release the parser
	[threadHtmlParser release];
	threadHtmlParser = nil;
	
	//NSLog(@"Array of threads is length: %d",[threadsArray count]);
	[self updateView];
	
	//If we're just looking at the first page, animate to the top.
	if(pageCountInView < 2 && threadsArray.count > 0) {
		[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
	}		
	
	pageCountInView++;
	[super handleParseResults:results];
}

#pragma mark -
#pragma mark TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {	
	NSMutableArray *fields = [[[NSMutableArray alloc] initWithCapacity:threadsArray.count+1] autorelease];

	for(int i=0;i<threadsArray.count;i++) {
		Thread *thread = [threadsArray objectAtIndex:i];
		
		BOOL isLastSticky = thread.sticky && threadsArray.count > i+1 && ![[threadsArray objectAtIndex:i+1] sticky];
		
		TTStyledText *styledText = [TTStyledText textFromXHTML:[[NSMutableString stringWithFormat:
																@"<div class=\"threadTitle\">%@%@</div>"\
																 @"<div class=\"threadSubtext\">"\
																 @"<img src=\"bundle://smallAuthorIcon.png\" width=\"15\" height=\"15\" /><span class=\"threadSubtextFont\">%@</span>"\
																 @"<img src=\"bundle://smallReplierIcon.png\" width=\"15\" height=\"15\" /><span class=\"threadSubtextFont\">%@</span>"\
																 @"<img src=\"bundle://smallPageIcon.png\" width=\"15\" height=\"15\" /><span class=\"threadSubtextFont\">%d</span>"\
																 @"<img src=\"bundle://smallReplyIcon.png\" width=\"15\" height=\"15\" /><span class=\"threadSubtextFont\">%@</span>"\
																 @"</div>%@",
																thread.sticky ? @"Sticky: " : @"",
																thread.title,
																thread.authorName,
																thread.replierName,
																thread.pageCount,
																thread.replyCount,
																 isLastSticky ? @"<div class=\"horizontalRule\"> </div>" : @""
																] retain]];
		TTStyledTextTableField *field = [[[TTStyledTextTableField alloc] initWithStyledText:styledText] autorelease];
		
		[fields addObject:field];		
	}
	
	if(threadsArray.count > 0) {	
		//Add a show more cell...
		[fields addObject:
		 [[[TTMoreButtonTableField alloc] initWithText:@"Show more threads"
											  subtitle:[NSString stringWithFormat:@"Load page %d",pageCountInView+1]
		 ] autorelease]
		];
	}
	
	//MGTableViewController will return a list data source. We're intentionally adding to the end.
	[fields addObjectsFromArray:[(TTListDataSource*)[super createDataSource] items]];

	TTListDataSource *ds = [[[TTListDataSource alloc] initWithItems:fields] autorelease];
	
	return ds;
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	if([self viewState] == TTViewDataLoadedError) {
		NSLog(@"View is currently in an error state, ignoring drill-down attempt");
		return;
	}
	
	if(threadsArray.count > indexPath.row) {
		//NSLog(@"Drilling down from threads to forums.");
		
		//Reset if necessary
		Thread *selThread = (Thread*)[threadsArray objectAtIndex:indexPath.row];
		if(![selThread.threadId isEqualToString:self.threadViewController.thread.threadId]) {
			//User switched threads. Let's clear out the gunk.
			[self.threadViewController setThread:selThread];
			[self.threadViewController resetContent];
		}
		
		[self.navigationController pushViewController:threadViewController animated:YES];					
	} else {
		//NSLog(@"More button may have been pushed?");
		[self downloadThreadsWithForum:self.forum withCache:YES];
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	//NSLog(@"Loading Forum View");
	[super loadView];
	
	pageCountInView = 1;
	
	//Init our array with cap 40, since most thread pages have that many.
	[self setThreadsArray:[[[NSMutableArray alloc] initWithCapacity:40] autorelease]];
	
	//Set up our thread view controller
	[self setThreadViewController:[[[StyledThreadViewController alloc] init] autorelease]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self setUpToolbar:MG_TOOLBAR];
	
	if(threadsArray.count == 0 && (threadHtmlParser == nil || threadHtmlParser.loading == NO)) {
		NSLog(@"Loading threads, as view may have been unloaded and then redrawn.");
		[self invalidateViewState:TTViewLoading];	
		[self downloadThreadsWithForum:self.forum withCache:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated {	
	
	if(threadHtmlParser.loading) {
		[threadHtmlParser.request cancel];
	}
}

@end











