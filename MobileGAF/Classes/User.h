//
//  User.h
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

//#import <CoreData/CoreData.h>


@interface User :  NSObject //NSManagedObject  
{
	NSString *name;
	NSString *uid;
	NSString *avatarUrl;
	NSString *tag;
	
	
	BOOL isModerator;
	BOOL isOnIgnoreList;
}

@property (nonatomic, retain) NSString *tag;
@property BOOL isOnIgnoreList;
@property BOOL isModerator;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *avatarUrl;
@property (retain) NSString *name;

@end







