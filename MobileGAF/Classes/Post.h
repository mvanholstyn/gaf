//
//  Post.h
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

//#import <CoreData/CoreData.h>

@class User;

@interface Post :  NSObject //NSManagedObject  
{
	NSString * content;
	User * author;
	NSString *uid;
	CGFloat renderedHeight;
	
	NSString *number;
	NSString *dateTime;
	NSString *title;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *number;
@property (nonatomic, retain) NSString *dateTime;
@property CGFloat renderedHeight;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic,retain) NSString * content;
@property (nonatomic,retain) User * author;

@end







