// 
//  User.m
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "User.h"


@implementation User 

@synthesize tag,name,uid,avatarUrl,isModerator,isOnIgnoreList;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[tag release];
	[name release];
	[uid release];
	[avatarUrl release];
	[super dealloc];
}

@end
