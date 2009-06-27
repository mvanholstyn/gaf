// 
//  Forum.m
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "Forum.h"


@implementation Forum 

@synthesize forumId;
//@synthesize uid;
@synthesize postCount;
@synthesize url;
@synthesize name;
@synthesize threadCount;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[name release];
	[url release];	
	[forumId release];
	[super dealloc];
}

@end
