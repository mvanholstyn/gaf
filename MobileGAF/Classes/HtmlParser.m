//
//  HtmlParser.m
//  MobileGAF
//
//  Created by Juice on 3/24/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "Three20/TTURLResponse.h"
#import "HtmlParser.h"
#import "XPathQuery.h"

@implementation HtmlParser

@synthesize url = _url;
@synthesize shouldCache = _shouldCache;
@synthesize cacheExpiryWhenConnectedToANetwork = _cacheExpiryWhenConnectedToANetwork;
@synthesize cacheExpiryWhenOffline = _cacheExpiryWhenOffline;
@synthesize request;
@synthesize loading;
@synthesize delegate;

#pragma mark -
#pragma mark HtmlParser

- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>) aDelegate isCaching:(BOOL)isCaching expiresAfter:(NSTimeInterval)expirySeconds {
	if(self = [super init]) {
		[self setDelegate:aDelegate];
		[self setShouldCache:isCaching];
		[self setCacheExpiryWhenConnectedToANetwork:expirySeconds];
		[self setUrl:aUrl];
	}
	return self;	
}

/* Will be overridden, because each parser needs its own interval for the cache expiry.
 *  Should also be what gets called by refresh buttons.
 */
- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>) aDelegate isCaching:(BOOL)isCaching {
	return [self initWithUrl:aUrl delegate:aDelegate isCaching:isCaching expiresAfter:TT_DEFAULT_CACHE_EXPIRATION_AGE];
}

- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>) aDelegate {
	return [self initWithUrl:aUrl delegate:aDelegate isCaching:YES];
}

- (void) parseModelObjects:(NSData*)someData {
	[self doesNotRecognizeSelector:_cmd];
	[delegate handleParseResults:nil];
}

- (void)beginLoadingAndParsing {
	//NSLog(@"Initiating the TTURLRequest...");	
	loading = YES;
	
	request = [TTURLRequest requestWithURL:_url delegate:self];
	request.response = [[[TTURLDataResponse alloc] init] autorelease];
	if(!_shouldCache)
		request.cachePolicy = TTURLRequestCachePolicyNetwork;
	request.cacheExpirationAge = _cacheExpiryWhenConnectedToANetwork;
	
	if([request send]) {
		NSLog(@"Cache hit!");
		loading = NO;
	} else {
		//Will load via web
	}
}

#pragma mark -
#pragma mark TTURLRequestDelegate Methods

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	NSLog(@"Error occurred during TTURLRequest.");

	//We are no longer loading. Request is cancelled.
	self.loading = NO;
	
	[delegate parsingFailed:error];
}

- (void)requestDidFinishLoad:(TTURLRequest*)aRequest {
	//NSLog(@"Loading Response..");
	TTURLDataResponse* response = aRequest.response;	
	self.loading = NO;
	[self parseModelObjects:response.data];
}

- (void)requestDidStartLoad:(TTURLRequest*)request {
	//NSLog(@"Request did start!");
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
	//NSLog(@"Request was cancelled!");
	self.loading = NO;
}




#pragma mark Memory
- (void)dealloc {
	[delegate release];
    [super dealloc];
}

@end











