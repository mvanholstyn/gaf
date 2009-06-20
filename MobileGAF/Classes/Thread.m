// 
//  Thread.m
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "Thread.h"

#import "Forum.h"

@implementation Thread 

@synthesize replyCount;
@synthesize authorName;
@synthesize replierName;
@synthesize pageCount;
@synthesize currentPage;
@synthesize sticky;
@synthesize title;
@synthesize url;
@synthesize forum;
@synthesize uid;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[authorName release];
	[replierName release];
	[replyCount release];
	[title release];
	[url release];
	[forum release];
	[uid release];
	[super dealloc];
}

@end
