// 
//  Post.m
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "Post.h"

#import "User.h"
#import "Thread.h"

@implementation Post 

@synthesize title;
@synthesize dateTime;
@synthesize number;
@synthesize content;
@synthesize author;
@synthesize uid;
@synthesize renderedHeight;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[title release];
	[dateTime release];
	[number release];
	[content release];
	[author release];
	[uid release];
	[super dealloc];
}

@end
