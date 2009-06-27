//
//  ForumHtmlParser.m
//  MobileGAF
//
//  Created by Juice on 3/20/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "ForumHtmlParser.h"
#import "HtmlParser.h"
#import "Forum.h"
#import "Account.h"
#import "MobileGAFAppDelegate.h"
#import "XPathQuery.h"


@implementation ForumHtmlParser

#pragma mark Application methods

- (void)parseModelObjects:(NSData*)someData {
	NSLog(@"Parsing Forums.");

	NSUInteger loginFormCount = [PerformHTMLXPathQuery(someData, @"//table/tr/td[2]/form[@action=\"login.php\"]") count];
	//If the login form is there, they're not logged in.
	[MG_ACCOUNT setIsLoggedIn:!(loginFormCount > 0)];
	
	NSArray *nodes = PerformHTMLXPathQuery(someData, @"//tbody//div/a[starts-with(@href,'forumdisplay')]");
	NSMutableArray *forumArray = [[[NSMutableArray alloc] initWithCapacity:[nodes count]] autorelease];
	
	//Bootstrap all of the forums.
	for (NSDictionary *node in nodes) {
		Forum *forum = [[[Forum alloc] init] autorelease];

		//URL is the first attribute on the anchor tag.
		[forum setUrl:[(NSDictionary*)[(NSArray*)[node objectForKey:@"nodeAttributeArray"] objectAtIndex:0] objectForKey:@"nodeContent"]];
		
		NSRange fRange = [forum.url rangeOfString:@"f="];
		[forum setForumId:[forum.url substringFromIndex:(fRange.location+fRange.length)]];
		
		[forum setName:[(NSDictionary*)[(NSArray*)[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"]];
		
		[forumArray addObject:forum];
	}

	//Thread Count
	@try {
		nodes = PerformHTMLXPathQuery(someData, @"//tbody/tr/td[last()-1]");
		for (int i = 0; i < [nodes count]; i++) {
			[[forumArray objectAtIndex:i] setThreadCount:[(NSDictionary*)[nodes objectAtIndex:i] objectForKey:@"nodeContent"]];
		}
		
		//Post Count
		nodes = PerformHTMLXPathQuery(someData, @"//tbody/tr/td[last()]");
		for (int i = 0; i < [nodes count]; i++) {
			[[forumArray objectAtIndex:i] setPostCount:[(NSDictionary*)[nodes objectAtIndex:i] objectForKey:@"nodeContent"]];
		}	
	}
	@catch (NSException * e) {
		NSLog(@"An error occurred while parsing thread counts: ",[e description]);
	}
	
	/*
	for (Forum *forum in forumArray) {
		NSLog(@"Parsed Forum: ");
		NSLog(forum.name);	
		NSLog(forum.url);
		NSLog(forum.threadCount);
		NSLog(forum.postCount);		
	}*/
	
	if([delegate respondsToSelector:@selector(handleParseResults:)]) {
		[delegate handleParseResults:forumArray];
	}
}

-(void) dealloc {
	[super dealloc];	
}

@end





