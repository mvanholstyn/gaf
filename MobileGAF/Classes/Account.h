//
//  Account.h
//  MobileGAF
//
//  Created by Juice on 5/10/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Account : NSObject {
	NSString *name;
	NSString *password;
	
	BOOL isLoggedIn;
}

@property BOOL isLoggedIn;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *password;

- (BOOL)needsLogin;

@end

