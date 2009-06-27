// 
//  Thread.m
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "Thread.h"

#import "Forum.h"
#import "Response.h"
#import "Connection.h"
#import "NSObject+ObjectiveResource.h"
#import "ObjectiveResourceConfig.h"
#import "JSONSerializableSupport.h"

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
@synthesize threadId;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[authorName release];
	[replierName release];
	[replyCount release];
	[title release];
	[url release];
	[forum release];
	[threadId release];
	[super dealloc];
}


+ (NSArray *)findAllForForumWithId:(NSString *)forumId {
	
    NSString *forumPath = [NSString stringWithFormat:@"%@%@/%@/%@%@",
							   [self getRemoteSite],
							   [Forum getRemoteCollectionName],
							   forumId,
							   [self getRemoteCollectionName],
							   [self getRemoteProtocolExtension]];
	
	
    Response *res = [Connection get:forumPath withUser:[ObjectiveResourceConfig getUser] 
						andPassword:[ObjectiveResourceConfig getPassword]];

	return [self fromJSONData:res.body];
}

#pragma mark -
#pragma mark NSObject+ObjectiveResource

-(NSString *) nestedPath {
	NSString *path = [NSString stringWithFormat:@"%@/threads",forum.forumId,nil];
	if(threadId) {
		path = [path stringByAppendingFormat:@"/%@",threadId,nil];
	}
	return path;
}


@end
