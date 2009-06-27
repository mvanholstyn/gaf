//
//  Forum.h
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

//#import <CoreData/CoreData.h>


@interface Forum :  NSObject //NSManagedObject  
{
	NSString * forumId;
	NSString * url;
//	NSString * uid;
	NSString * name;
	NSString * threadCount;
	NSString * postCount;	
}

@property (nonatomic, retain) NSString *forumId;
//@property (nonatomic, retain) NSString *uid;
@property (retain) NSString * postCount;
@property (retain) NSString * url;
@property (retain) NSString * name;
@property (retain) NSString * threadCount;

@end




