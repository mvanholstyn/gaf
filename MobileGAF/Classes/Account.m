//
//  Account.m
//  MobileGAF
//
//  Created by Juice on 5/10/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "Account.h"


@implementation Account 

@synthesize isLoggedIn;
@synthesize name;
@synthesize password;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[name release];
	[password release];
	[super dealloc];
}

#pragma mark -
#pragma mark Account

- (BOOL)needsLogin {
	if(isLoggedIn)
		return NO;
	else if([name length] > 0 && [password length] > 0) 
		return YES;
	else
		return NO;	
}

@end


