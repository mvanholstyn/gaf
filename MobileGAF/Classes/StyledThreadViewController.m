//
//  StyledThreadViewController.m
//  MobileGAF
//
//  Created by Juice on 4/14/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//
#import "StyledThreadViewController.h"
#import "MobileGAFAppDelegate.h"
#import "Thread.h"
#import "MGStyleSheet.h"
#import "MGWebViewController.h"
#import "StyledPostHtmlParser.h"
#import "NSStringAdditions.h"
#import "Post.h"
#import "User.h"
#import "UIAlertViewAdditions.h"
#import "TTStyledTextAdditions.h"
#import "Account.h"
#import "LoginRequestDispatcher.h"

@interface StyledThreadViewController ()

- (NSUInteger)resolvePageNumberForTabIndex:(NSUInteger)index;
- (void)setUpTabBar;

/** Constructs an XHTML string for a post. Mainly the header, as the post contains the content **/
- (NSString*)styledXhtmlForPostAtIndex:(NSUInteger)index;

@end


@implementation StyledThreadViewController

@synthesize scrollToBottomOnNextLoad;
@synthesize replyBody;
@synthesize replyTitle;
@synthesize pageNumberBeingLoaded;
@synthesize pageTabBar;
@synthesize postHtmlParser;
@synthesize postsArray;
@synthesize thread;

#pragma mark -
#pragma mark NSObject Methods

- (void)dealloc {	
	[postHtmlParser release];
	[postsArray release];
	[thread release];
	[pageTabBar release];
	
	[replyTitle release];
	[replyBody release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark MGTableViewController

- (void)setUpToolbar:(MGToolbar*)toolbar {
	[[toolbar itemWithTag:kRefreshTag] setEnabled:YES];
	[[toolbar itemWithTag:kSearchTag] setEnabled:YES];
	[[toolbar itemWithTag:kReplyTag] setEnabled:YES];
	
	//Replace the reply icon with the compose/author one
	[toolbar replaceItemWithTag:kReplyTag withItem:toolbar.replyButton];
}

#pragma mark -
#pragma mark StyledThreadViewController Methods

-(void)refresh {
	[self resetContent];		
	[self downloadPostsWithThread:self.thread withCache:NO];
}

- (void)refreshAfterSubmitAsNecessary {
	//Reply succeeded
	//If page == last...
	if(thread.currentPage == (thread.pageCount-1)) {
		//Scroll to bottom on next load
		if((postsArray.count > 50 && postsArray.count == 100)
			||
			(postsArray.count == 50)) {
			//We're certain the reply will have triggered a new page's creation.
			thread.currentPage = thread.pageCount; 
		}
		
		self.scrollToBottomOnNextLoad = YES;
		
		[self refresh]; 
	}
}

- (NSDictionary*)submissionParamsForEdit {
	//Changed course; handling this with code in EditorController... 
	return nil;
}
- (NSDictionary*)submissionParamsForCreateOrReply {	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			thread.threadId,@"t",
			[(Post*)[postsArray lastObject] uid],@"p",
			nil];
}

#pragma mark Tab bar stuff

- (NSUInteger)resolvePageNumberForTabIndex:(NSUInteger)index {
	NSUInteger pageNumber;
	if(thread.pageCount == 1 || index == 0) {
		//First spot is always first apge
		pageNumber = 1;
	} else if(index == 4) {
		//Last spot is always last page
		pageNumber = thread.pageCount;
	} else if(thread.pageCount < 5) {
		pageNumber = index+1;
	} else {
		if(thread.currentPage < 3) {
			pageNumber = index+1;
		} else if(thread.currentPage >= (thread.pageCount-2)) {
			if(index ==1) {
				pageNumber = thread.pageCount - 3;				
			} else if(index==2) {
				pageNumber = thread.pageCount - 2;
			} else if(index == 3) {
				pageNumber = thread.pageCount - 1;
			} 
		} else {
			pageNumber = thread.currentPage+index - 1;		
		}
	}
	
	return pageNumber;
}

- (void)setUpTabBar{	
	
	if(thread.pageCount > 1) {		
		NSMutableArray *tabItems = [[[NSMutableArray alloc] initWithCapacity:thread.pageCount] autorelease];
		
		TTTabItem *selectedTabItem = nil;
		NSUInteger selectedTabIndex = -1;

		NSString *pageWord;
		for(int i=0;i<5;i++) {
			if(i >= thread.pageCount) {
				break;
			} 
			
			NSUInteger pageNum = [self resolvePageNumberForTabIndex:i];
			
			NSString *title;
			switch (i) {
				case 0:
					title = @"first";
					break;
				case 4:
					title = @"last";
					break;
				default:
					pageWord = @"page ";
					if(pageNum >= 10 && pageNum < 100) {
						pageWord = @"pg. ";					
					} else if(pageNum >= 100 && pageNum < 1000) {
						pageWord = @"p. ";
					} else if(pageNum >= 1000) {
						pageWord = @"p ";
					}
					title = [NSString stringWithFormat:@"%@%d",pageWord,pageNum];
					break;
			}
			
			TTTabItem *tabItem = [[[TTTabItem alloc] initWithTitle:title] autorelease];
			
			if(pageNum == thread.currentPage+1) {					
				selectedTabItem = tabItem;
				selectedTabIndex = i;
			}
			
			[tabItems addObject:tabItem];		
		}
		
		pageTabBar.tabItems	= tabItems;		
		
		if(selectedTabItem != nil) {			
			//NSLog(@"Setting selected tab at position %@",selectedTabItem.title);			
			[self.pageTabBar setSelectedTabItem:selectedTabItem];			
		}
		if(selectedTabIndex != -1) {
			//NSLog(@"Setting selected tab at position %d",selectedTabIndex);
			[self.pageTabBar setSelectedTabIndex:selectedTabIndex];			
		}
				
		if([pageTabBar superview] == nil) {
			[self.view addSubview:pageTabBar];
		}
		self.pageTabBar.backgroundColor = self.navigationBarTintColor;
		
		//Shrink the table view down a bit.
		[self.tableView setFrame:CGRectMake(0, 
											kPageTabBarHeight, 
											self.view.bounds.size.width, 
											self.view.bounds.size.height - kPageTabBarHeight)];		
		
	} else if([pageTabBar superview] != nil) {
		//NSLog(@"Removing page tab bar.");
		[self.pageTabBar removeFromSuperview];
		[self.tableView setFrame:self.view.bounds];
	}	
	
}

- (void)resetContent {
	[self.postsArray removeAllObjects];
//	[self setUpTabBar];
	[self updateView];
}

-(void)downloadPostsWithThread:(Thread*)aThread withCache:(BOOL)useCache{
	if(postHtmlParser != nil && postHtmlParser.loading == YES) {
		if(pageNumberBeingLoaded == aThread.currentPage) {
			NSLog(@"We're already loading. Cancelling the request to download posts");
			return;			
		} else {
			//Cancel the download and start over.
			NSLog(@"We were downloading, but the user changed pages, so we want to cancel.");
			[self.postHtmlParser setDelegate:nil];
			[self.postHtmlParser.request cancel];
			self.postHtmlParser = nil;
		}
	}

	[self invalidateViewState:TTViewLoading];		


	[self setPageNumberBeingLoaded:aThread.currentPage];
	
	UIBarButtonItem *refreshButton = [MG_TOOLBAR itemWithTag:kRefreshTag];
	[refreshButton setEnabled:NO];
	
	[self setThread:aThread];		
	[self setAdjustingFontOnNavigationItemWithTitle:thread.title];
	
	
	NSLog(@"Downloading Posts!");
	NSMutableString* url = [[[NSMutableString alloc] initWithString:kNeoGafBaseUrl] autorelease];
	[url appendString:thread.url];
	[url appendString:@"&page="];
	[url appendString:[NSString stringWithFormat:@"%d",thread.currentPage+1]];
	
	[self setPostHtmlParser:[[StyledPostHtmlParser alloc] initWithUrl:url delegate:self isCaching:useCache]];
	[postHtmlParser setThread:self.thread];
	[postHtmlParser beginLoadingAndParsing];
}

- (NSString*) styledXhtmlForAvatarWithUrl:(NSString*)url forAuthor:(User*)author {
	BOOL shouldLoadImages = [MG_DELEGATE shouldLoadAvatarImages];
	NSString *imageUrl = author.avatarUrl;
	if(!shouldLoadImages || !imageUrl) {
		imageUrl = kDefaultAvatarImgUrl;
	} 
	
	CGSize avatarSize = [TTSTYLESHEET avatarImageSize];
	
	return [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"%@\" width=\"%f\" height=\"%f\"></img></a>"
			,url,imageUrl,avatarSize.width,avatarSize.height];
}

- (NSString*)styledXhtmlForPostAtIndex:(NSUInteger)index {
	Post *post = [postsArray objectAtIndex:index];
	
	if([post.author isOnIgnoreList]) {
		return post.content;
	}
	
	//Header info
	NSString *classForUserTitle = [post.author isModerator] ? @"moderatortext" : @"authortext";			
	NSString *authorPageUrl = [kNeoGafBaseUrl stringByAppendingFormat:@"member.php?u=%@",post.author.uid];	
	
	NSString *avatarImageHtml = [self styledXhtmlForAvatarWithUrl:authorPageUrl forAuthor:post.author];
	
	NSString *replyToImageHtml = [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"%@\" width=\"%f\" height=\"%f\" /></a>"
								  ,[kNeoGafBaseUrl stringByAppendingFormat:@"newreply.php?do=newreply&amp;p=%@",post.uid],
								  kReplyQuoteImgUrl,
								  [TTSTYLESHEET quoteImageSize].width,
								  [TTSTYLESHEET quoteImageSize].height];
	
	Account *account = MG_ACCOUNT;
	
	NSString *editImageHtml = @"";
	if([post.author.name caseInsensitiveCompare:account.name] == NSOrderedSame) {
		editImageHtml = [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"%@\" width=\"%f\" height=\"%f\" /></a> "
		 ,[kNeoGafBaseUrl stringByAppendingFormat:@"editpost.php?do=editpost&amp;p=%@",post.uid]
		 ,kEditQuoteImgUrl,
		 [TTSTYLESHEET quoteImageSize].width,
		 [TTSTYLESHEET quoteImageSize].height];		
	} else {
		editImageHtml = [NSString stringWithFormat:@"<img width=\"%f\" height=\"1\" />",
		 [TTSTYLESHEET quoteImageSize].width];
	}

	
	NSString *tagHtml;
	if([post.author.tag length] > 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"show_user_tags"]) {
		tagHtml = [NSString stringWithFormat:@"<span class=\"authorTagText\">%@</span>",post.author.tag];
	} else {
		tagHtml = @"";
	}
	
	NSMutableString *header = [NSMutableString stringWithFormat:
						@"<div class=\"authorarea\">"\
							@"%@<span class=\"%@\">%@</span>%@%@"\
							@"<div class=\"authorSubArea\">#%@ - %@<br/>%@</div></div>"\
						,avatarImageHtml,classForUserTitle,[post.author name],
							   editImageHtml,replyToImageHtml,
						post.number,post.dateTime,tagHtml];
	if([post.title length] > 0) {
		[header appendFormat:@"<div class=\"postTitleArea\">%@</div>",post.title];
	}
	
	NSLog(@"Post: %@",post.content);
	//NSLog(@"Tag: %@",post.author.tag);
	
	//Header + content (which was already well-formed by the parser itself.)
	return [header stringByAppendingString:post.content];
}

#pragma mark -
#pragma mark TTTabDelegate

- (void)tabBar:(TTTabBar*)tabBar tabSelected:(NSInteger)selectedIndex {
	NSUInteger pageNum = [self resolvePageNumberForTabIndex:selectedIndex];

	if(pageNum != thread.currentPage+1) {
		//NSLog(@"User selected page %d",pageNum);
		
		[self.thread setCurrentPage:pageNum-1];
		[self setUpTabBar];
		
		[self refresh];		
	}
}


#pragma mark -
#pragma mark HtmlParserDelegate Methods

- (void)handleParseResults:(NSMutableArray*)results {
//	NSLog(@"Handling post parse results, size %d.",results.count);
	[self setPostsArray:results];
	
	//Release the parser
	[postHtmlParser release];
	postHtmlParser = nil;
	
	[self updateView];
	[self setUpTabBar];
	[super handleParseResults:results];
}

#pragma mark -
#pragma mark TTTableViewController
- (id<TTTableViewDataSource>)createDataSource {	
	NSMutableArray *fields = [[[NSMutableArray alloc] initWithCapacity:postsArray.count] autorelease];
	
	for(int i=0;i<postsArray.count;i++) {		
		TTStyledText *styledText = [TTStyledText textFromXHTML:[self styledXhtmlForPostAtIndex:i]];
		TTStyledTextTableField *field = [[[TTStyledTextTableField alloc] initWithStyledText:styledText] autorelease];
		styledText.touchDelegate = self;		
		[fields addObject:field];
	}
	
	//MGTableViewController will return a list data source. We're intentionally adding to the end.
	[fields addObjectsFromArray:[(TTListDataSource*)[super createDataSource] items]];
	
	TTListDataSource *ds = [[[TTListDataSource alloc] initWithItems:fields] autorelease];
	return ds;
}

#pragma mark -
#pragma mark TTStyledTextTouchDelegate

- (void)styledLinkNodeWasTouched:(TTStyledLinkNode*)link {
	if(link.url) {
		
		//TODO: Handle YouTube links special here.
		
		//if-else chain for special URL patterns.
		if([link.url hasPrefix:[kNeoGafBaseUrl stringByAppendingString:@"editpost.php"]]) {
			[self editReplyActionForURL:link.url];			
		} else if([link.url hasPrefix:[kNeoGafBaseUrl stringByAppendingString:@"newreply.php"]]) {
			[self quoteReplyActionForURL:link.url];
		} else {
			NSLog(@"followed link: %@", link.url);
			UIViewController *webController = [[[MGWebViewController alloc] initWithUrl:link.url] autorelease];			
			[self.navigationController pushViewController:webController animated:YES];			
		}
	}
}


- (void)styledNodeWasTouched:(TTStyledNode*)node {
	//NSLog(@"Node touched. Type:%@",[node className]);
	
	/*if([node isKindOfClass:[TTStyledImageNode class]]) {
		TTStyledImageNode *img = (TTStyledImageNode*) node;
		if([img.url isEqualToString:kReplyQuoteImgUrl]) {
			if([img.parentNode isKindOfClass:[TTStyledLinkNode class]]) {
				[self styledLinkNodeWasTouched:(TTStyledLinkNode*)img.parentNode];
			}
		}
	}*/
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	//NSLog(@"Loading Post View");	
	[super loadView];
	
	//Init our array 
	[self setPostsArray:[[[NSMutableArray alloc] initWithCapacity:50] autorelease]];
	
	//Create pageTabBar
	self.pageTabBar = [[TTTabBar alloc] initWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, kPageTabBarHeight)];
	self.pageTabBar.delegate = self;		
}

- (void)viewWillAppear:(BOOL)animated {	
	[super viewWillAppear:animated];

	[self setUpToolbar:MG_TOOLBAR];
	
	//Set up pagination
	[self setUpTabBar];	
	
	if(postsArray.count == 0 && (postHtmlParser == nil || !postHtmlParser.loading)) {
		//NSLog(@"Loading posts, as view may have been unloaded and then redrawn.");
		[self downloadPostsWithThread:self.thread withCache:YES];
	}	
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];	
	[self.pageTabBar setNeedsLayout];	
}


- (void)viewWillDisappear:(BOOL)animated {
	
	if(postHtmlParser.loading) {
		[postHtmlParser.request cancel];		
	} 
	
	
	//Hide the application's toolbar.
	[MG_TOOLBAR setHidden:YES];
}

@end



