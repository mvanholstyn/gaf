//
//  PostHtmlParser.m
//  MobileGAF
//
//  Created by Juice on 3/22/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "HtmlParser.h"
#import "Post.h"
#import "User.h"
#import "PostHtmlParser.h"
#import "MobileGAFAppDelegate.h"
#import "XPathQuery.h"
#import "PostCell.h"

@interface PostHtmlParser()

/** 
 * Scours the children recursively for text in the nodes.
 **/  
//- (NSMutableString*)findTextInNode:(NSDictionary*)node;

//- (NSArray*)findHtmlOfAllPosts:(NSString*)html;

@end



@implementation PostHtmlParser

@synthesize postArray;

#pragma mark -
#pragma mark Application Methods

- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>) aDelegate isCaching:(BOOL)isCaching {
	return [self initWithUrl:aUrl delegate:aDelegate isCaching:isCaching expiresAfter:(30)];
}

- (void)parseModelObjects:(NSData*)someData {
	NSLog(@"Parsing Posts");
	
	NSArray *postContentNodes = PerformHTMLXPathQuery(someData, @"//div[starts-with(@id,\"post_message_\")]");
	NSArray *userNameNodes = PerformHTMLXPathQuery(someData, @"//a[@class=\"bigusername\"]");
	NSArray *avatarNodes = PerformHTMLXPathQuery(someData, @"//img[contains(@alt,\"'s Avatar\")]");
	//NSArray *pageCountNode = PerformHTMLXPathQuery(someData, @"//table/tr/td[2]/div/table/tr/td[@style=\"font-weight:normal\"]");	
	
	NSMutableArray *aPostArray = [[[NSMutableArray alloc] initWithCapacity:[postContentNodes count]] autorelease];
	
	NSString *fullPage = [[[NSString alloc] initWithData:someData encoding:NSISOLatin1StringEncoding] autorelease];
	
	NSRange currentRange;
	currentRange.location=0;
	currentRange.length = [fullPage length];
	for (int i = 0; i < [postContentNodes count]; i++) {		
		
		//Init Post
		NSDictionary *postNode = [postContentNodes objectAtIndex:i];		
		Post *post = [[[Post alloc] init] autorelease];		
		NSString *postUidFull = [(NSDictionary*)[(NSArray*)[postNode objectForKey:@"nodeAttributeArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
		[post setUid:[postUidFull substringFromIndex:[@"post_message_" length]]];
		
		//Init user
		NSDictionary *userNode = [userNameNodes objectAtIndex:i];
		User *user = [[[User alloc] init] autorelease];
		NSString *userUidFull = [(NSDictionary*)[(NSArray*)[userNode objectForKey:@"nodeAttributeArray"] objectAtIndex:1] objectForKey:@"nodeContent"];
		[user setUid:[userUidFull substringFromIndex:[@"member.php?u=" length]]];
		[user setName:(NSString*)[userNode objectForKey:@"nodeContent"]];

		//Now find an avatar url for the user in our list of avatar nodes should one exist.
		if(user.name != nil && [user.name length] > 0) {
			for (NSDictionary *avatarNode in avatarNodes) {
				if([(NSString*)[[[avatarNode objectForKey:@"nodeAttributeArray"] objectAtIndex:1] objectForKey:@"nodeContent"] hasPrefix:user.name]) {
					//This guy has an avatar.
					[user setAvatarUrl:[[[avatarNode objectForKey:@"nodeAttributeArray"] objectAtIndex:0] objectForKey:@"nodeContent"]];
					break;
				}
			}			
		}

 		[post setAuthor:user];
		
		//Going to scan through the full source string and chop off this post for use in a small UIWebView.
		
		//NSLog([[[NSString alloc] initWithFormat:@"%d: Curr range loc %d len %d",i,currentRange.location,currentRange.length] autorelease]);
		
		NSUInteger startOfPostLoc = [fullPage rangeOfString:@"<!-- message" options:NSCaseInsensitiveSearch range:currentRange].location;
		NSRange endOfPost = [fullPage rangeOfString:@"<!-- / message" options:NSCaseInsensitiveSearch range:currentRange];

		//NSLog([[[NSString alloc] initWithFormat:@"%d: Start %d End %d",i,startOfPostLoc,endOfPost.location] autorelease]);
		
		NSRange postRange;
		postRange.location = startOfPostLoc;
		postRange.length = endOfPost.location - startOfPostLoc;
		
		//NSLog([[[NSString alloc] initWithFormat:@"%d: postRange loc %d len %d",i,postRange.location,postRange.length] autorelease]);
		
		[post setContent:[fullPage substringWithRange:postRange]];
		
		//push back the current range
		currentRange.location = endOfPost.location + endOfPost.length;
		currentRange.length = [fullPage length] - currentRange.location;
		
		//NSLog(@"Just set the following as the content for a post:");
		//NSLog(post.content);
		
		[aPostArray addObject:post];
	}

	if([delegate respondsToSelector:@selector(handleParseResults:)]) {
		[delegate handleParseResults:aPostArray];	
	}
}

/*
- (NSArray*)findHtmlOfAllPosts:(NSString*)html {
	NSMutableArray *split = [[NSMutableArray alloc] initWithArray:[[html componentsSeparatedByString:@"<!-- message --"] autorelease]];

	if([split count] > 0) {
			//First entry is junk. lost it.
		[split removeObjectAtIndex:0];
		for (NSString *post in split) {
			NSLog(@"Here's a post's plain text:");
			NSLog(post);
		}		
	} else {		
		NSLog(@"No posts found in thread...");
	}
	

	
	
	//first and last should 
	return split;
	
}
*/
/*
-(NSMutableString*) findTextInNode:(NSDictionary*)node {
	NSMutableString *text = [[[NSMutableString alloc] init] autorelease];
	
	NSString *nodeText = [node objectForKey:@"nodeContent"];
	if(nodeText != nil && [nodeText length] > 0) {
		[text appendString:nodeText];
	}
	
	NSArray *postNodeChildren = [node objectForKey:@"nodeChildArray"];
	for(NSDictionary *childNode in postNodeChildren) {
		[text appendString:[self findTextInNode:childNode]];
	}	
	
	return text;
}
 */

#pragma mark memory
-(void) dealloc {
	[postArray release];
	[super dealloc];
}



@end








