//
//  ThreadHtmlParser.m
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "ThreadHtmlParser.h"
#import "Thread.h"
#import "Account.h"
#import "MobileGAFAppDelegate.h"
#import "XPathQuery.h"
#import "Tag.h"
#import "NSStringAdditions.h"


@implementation ThreadHtmlParser

#pragma mark -
#pragma mark Application methods

- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>) aDelegate isCaching:(BOOL)isCaching {
	return [self initWithUrl:aUrl delegate:aDelegate isCaching:isCaching expiresAfter:(120)];
}

- (void)parseModelObjects:(NSData*)someData {
	NSLog(@"Parsing Threads");
	
	/*Update user's login status*/
	NSUInteger loginFormCount = [PerformHTMLXPathQuery(someData, @"//table/tr/td[2]/form[@action=\"login.php\"]") count];
	[MG_ACCOUNT setIsLoggedIn:!(loginFormCount > 0)];
	
	/* Parse rows of nodes.*/
	NSArray *tableRows = PerformHTMLXPathQueryForTags(someData, @"//table/tr/td[2]/div/a[starts-with(@href,\"showthread\")]/../../..");
	
	NSMutableArray *aThreadArray = [[[NSMutableArray alloc] initWithCapacity:[tableRows count]] autorelease];	
	for (int i = 0; i < [tableRows count]; i++) {	
		Thread *thread = [[[Thread alloc] init] autorelease];
		
		Tag *tr = (Tag*)[tableRows objectAtIndex:i];
		NSArray *tableCells = [tr childrenWithTagName:@"td"];
		
		//Thread title /td[2]/div[1]/a[1] text
		Tag *threadTitleDiv = [(Tag*)[tableCells objectAtIndex:1] firstChildWithTagName:@"div"];
		Tag *threadLink = [threadTitleDiv firstChildWithTagName:@"a"];		
		[thread setTitle: [[threadLink retrieveTextUpToDepth:1] stringByReplacingXMLElementEntities]];
		
		//Set thread URL and then extract the thread UID from it
		[thread setUrl:[threadLink valueForAttribute:@"href"]];
		
		//Everything after the '=' sign is the ID.
		NSRange idRange = [thread.url rangeOfString:@"="];
		[thread setThreadId:[thread.url substringFromIndex:(idRange.length+idRange.location)]];

		//Set stickiness
		if([[threadTitleDiv retrieveTextUpToDepth:1] rangeOfString:@"Sticky"].location != NSNotFound) {
			[thread setSticky:YES];
		}
		
		//Determine page count
		if([[threadTitleDiv childrenWithoutText] count] < 3) {
			[thread setPageCount:1];
		} else {
			Tag *lastPageLink = [(Tag*)[threadTitleDiv lastChildWithTagName:@"span"] lastChildWithTagName:@"a"];
			NSString *urlOfLastPage = [lastPageLink valueForAttribute:@"href"];
			NSRange pageNumberRange = [urlOfLastPage rangeOfString:@"page="];
			NSString *pageCount = [urlOfLastPage substringFromIndex:(pageNumberRange.location+pageNumberRange.length)];
			[thread setPageCount:[pageCount integerValue]]; 			
		}
		
		//OP / Author name
		Tag *authorLinkTag = [(Tag*)[tableCells objectAtIndex:2] firstChildWithTagName:@"a"];
		[thread setAuthorName:[authorLinkTag retrieveTextUpToDepth:1]];
		
		//Replier
		Tag *replierLinkTag = [(Tag*)[(Tag*)[tableCells objectAtIndex:3] firstChildWithTagName:@"div"] firstChildWithTagName:@"a"];
		[thread setReplierName:(replierLinkTag ? [replierLinkTag retrieveTextUpToDepth:1] : @"Unknown")];
		
		//Reply count
		Tag *replyCountCellTag = [(Tag*)[tableCells objectAtIndex:4] firstChildWithTagName:@"a"];
		[thread setReplyCount:(replyCountCellTag ? [replyCountCellTag retrieveTextUpToDepth:1] : @"Unknown")];
		
		[aThreadArray addObject:thread];

		if([delegate respondsToSelector:@selector(handlePartialParseResults:)]) {
			[delegate handlePartialParseResults:aThreadArray];			
		}
	}
	
	[delegate handleParseResults:aThreadArray];
}

-(void) dealloc {
	[super dealloc];
}

@end





