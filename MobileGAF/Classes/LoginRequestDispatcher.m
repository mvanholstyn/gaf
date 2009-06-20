//
//  LoginRequestDispatcher.m
//  MobileGAF
//
//  Created by Juice on 3/31/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "LoginRequestDispatcher.h"
#import <CommonCrypto/CommonDigest.h>
#import "Account.h"
#import "UIAlertViewAdditions.h"
#import "MGWelcomeScreen.h"
#import "MobileGAFAppDelegate.h"

@interface LoginRequestDispatcher ()

- (void)sendRequest;
- (BOOL)validateAccount;

- (BOOL)wasLoginSuccessful:(TTURLDataResponse*)response;

@end

@implementation LoginRequestDispatcher

@synthesize loginFailureAlertViewDelegate = _loginFailureAlertViewDelegate;
@synthesize delegate = _delegate;
@synthesize shouldTriggerAlertViewOnSuccess;
@synthesize shouldTriggerAlertViewOnFail;
@synthesize request;
@synthesize account;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[_delegate release];
	[account release];
	[super dealloc];	
}

#pragma mark -
#pragma mark LoginRequestDispatcher

- (id)initWithAccount:(Account*)anAccount {
	if(self = [super init]) {
		[self setAccount:anAccount];
		self.shouldTriggerAlertViewOnFail = YES;
	}
	return self;
}


//Ripped off apple forums
NSString* md5( NSString *str )
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
} 

- (void)attemptLogin {
	//We want to retain ourselves. It's asynchronous and the caller will probably toss us
	[self retain];
	
	if(![self validateAccount]) {
		NSString *title = @"Account info needed";
		NSString *message = @"If you have an account, add it in the Settings screen";
		if(_loginFailureAlertViewDelegate) {
			[UIAlertView choiceAlertWithTitle:title message:message buttonName:kSettingsCommandName delegate:_loginFailureAlertViewDelegate];
		} else {
			[UIAlertView simpleAlertWithTitle:title message:message];	
		}		
	} else {
		[self sendRequest];		
	}
}

- (BOOL)validateAccount {
	if(!self.account ||
		!self.account.name ||
		[self.account.name length] == 0 ||
	   !self.account.password ||
		[self.account.password length] == 0) {
		return NO;
	} else {
		return YES;
	}
		
}

- (void)sendRequest {
	NSString *url = [kNeoGafBaseUrl stringByAppendingString:kLoginUrlSuffix];
	
	NSString *md5Password = [md5(self.account.password) lowercaseString];
	
	self.request = [[[TTURLRequest alloc] initWithURL:url delegate:self] autorelease];
	request.response = [[[TTURLDataResponse alloc] init] autorelease];
	request.shouldHandleCookies = YES;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;
	request.httpMethod = @"POST";
	
	[request.parameters setObject:self.account.name forKey:@"vb_login_username"];
	[request.parameters setObject:@"1" forKey:@"cookieuser"];	
	[request.parameters setObject:@"" forKey:@"vb_login_password"];
	[request.parameters setObject:@"" forKey:@"s"];	
	[request.parameters setObject:@"login" forKey:@"do"];
	[request.parameters setObject:md5Password forKey:@"vb_login_md5password"];
	[request.parameters setObject:md5Password forKey:@"vb_login_md5password_utf"];	
	
	[request send];
}

- (BOOL)wasLoginSuccessful:(TTURLDataResponse*)response {
	NSString *responsePageAsString = [[[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding] autorelease];
	//NSLog(responsePageAsString);
	
	//Success criteria is seeing this: `http-equiv="Refresh"`
	if([responsePageAsString rangeOfString:@"http-equiv=\"Refresh\""].location == NSNotFound) {
		//Fail
		return NO;
	} else {
		//Success
		return YES;
	}
}

#pragma mark -
#pragma mark TTURLRequestDelegate methods

- (void)requestDidFinishLoad:(TTURLRequest*)aRequest {
	account.isLoggedIn = [self wasLoginSuccessful:aRequest.response];
	if(account.isLoggedIn) {
		NSLog(@"Login request succeeeded");
		if(shouldTriggerAlertViewOnSuccess) {
			[UIAlertView simpleAlertWithTitle:@"Login Succeeded" 
									  message:[NSString stringWithFormat:@"Welcome %@, you are now logged in.",self.account.name]];
		}
	} else {
		if(self.shouldTriggerAlertViewOnFail) {
			NSLog(@"Login request failed");
			NSString *title = @"Login failed!";
			NSString *message = @"• Verify your credentials in the Settings screen.\n"\
								@"• You might be banned \n"\
								@"• Your account may be temporarily locked by attempting too many logins.";
			if(_loginFailureAlertViewDelegate) {
				[UIAlertView choiceAlertWithTitle:title message:message buttonName:kSettingsCommandName delegate:_loginFailureAlertViewDelegate];
			} else {
				[UIAlertView simpleAlertWithTitle:title message:message];	
			}			
		}
	}
	
	if([_delegate respondsToSelector:@selector(loginAttemptSucceeded:)]) {
		[_delegate loginAttemptSucceeded:account.isLoggedIn];
	}
	
	[self release];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	NSLog(@"Login request failed. Description: %@",[error description]);
	
	if(self.shouldTriggerAlertViewOnFail) {
		[UIAlertView simpleAlertWithTitle:@"Login Error!" 
								  message:[NSString stringWithFormat:@"An error while attempting to login! \n Message: ",
										   [error localizedDescription]]];		
	}

	[self release];
}

- (void)requestDidCancelLoad:(TTURLRequest*)aRequest {
	NSLog(@"Request cancelled");
	
	[self release];
}

@end







