//
//  LoginRequestDispatcher.h
//  MobileGAF
//
//  Created by Juice on 3/31/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "MobileGAFAppDelegate.h"

#define kLoginUrlSuffix @"login.php"

@protocol LoginRequestDispatcherDelegate <NSObject>

- (void)loginAttemptSucceeded:(BOOL)requestWasSuccessful;

@end

@interface LoginRequestDispatcher : NSObject <TTURLRequestDelegate> {
	Account *account;
	TTURLRequest *request;
	
	BOOL shouldTriggerAlertViewOnFail;

	//May act silently most of the time.
	BOOL shouldTriggerAlertViewOnSuccess;
	
	id<LoginRequestDispatcherDelegate> _delegate;
	
	id<UIAlertViewDelegate> _loginFailureAlertViewDelegate;
}

@property (nonatomic, retain) id<UIAlertViewDelegate> loginFailureAlertViewDelegate;
@property (nonatomic, retain) id<LoginRequestDispatcherDelegate> delegate;
@property BOOL shouldTriggerAlertViewOnSuccess;
@property BOOL shouldTriggerAlertViewOnFail;
@property (nonatomic, retain) TTURLRequest *request;
@property (nonatomic, retain) Account *account;

- (id)initWithAccount:(Account*)account;
- (void)attemptLogin;

@end







