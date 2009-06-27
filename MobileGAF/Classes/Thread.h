//
//  Thread.h
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

//#import <CoreData/CoreData.h>

@class Forum;

@interface Thread : NSObject //NSManagedObject  
{
	
	NSString * title;
	NSString * url;
	NSString * threadId;
	Forum * forum;
	
	NSUInteger currentPage;
	NSUInteger pageCount;
	NSString *replyCount;

	NSString *authorName;
	NSString *replierName;
	
	BOOL sticky;
}

@property (nonatomic, retain) NSString *replyCount;
@property (nonatomic, retain) NSString *replierName;
@property (nonatomic, retain) NSString *authorName;
@property NSUInteger currentPage;
@property NSUInteger pageCount;
@property BOOL sticky;
@property (nonatomic, retain) NSString *threadId;
@property (retain) NSString * title;
@property (retain) NSString * url;
@property (retain) Forum * forum;

+ (NSArray *)findAllForForumWithId:(NSString *)forumId;

@end













