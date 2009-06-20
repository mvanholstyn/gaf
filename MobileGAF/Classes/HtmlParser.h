//
//  HtmlParser.h
//  MobileGAF
//
//  Created by Juice on 3/24/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@protocol HtmlParserDelegate <NSObject>
/** 
 *Called when parsing is finished
 ****/
- (void)handleParseResults:(NSMutableArray*)results;
- (void)parsingFailed:(NSError*)error;

@optional
/**
 * Called every time the array has a new item appended to it. 
 *	might make the UI more smooth.
 *******/
- (void)handlePartialParseResults:(NSMutableArray*)results;
@end

@interface HtmlParser : NSObject <TTURLRequestDelegate> {
	id<HtmlParserDelegate> delegate;
	BOOL loading;
	
	NSString *_url;
	BOOL _shouldCache;
	
	NSTimeInterval _cacheExpiryWhenConnectedToANetwork;
	NSTimeInterval _cacheExpiryWhenOffline;	
	
	TTURLRequest *request;
}

- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>) aDelegate isCaching:(BOOL)isCaching expiresAfter:(NSTimeInterval)expirySeconds;
- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>) aDelegate isCaching:(BOOL)isCaching;
- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>)aDelegate;


- (void)beginLoadingAndParsing;

/**
 * This method will be called privately and will in turn 
 *	call the delegate's handler handleParseResults: method
 */
- (void)parseModelObjects:(NSData*)someData;

@property (nonatomic, retain) NSString *url;
@property BOOL shouldCache;
@property NSTimeInterval cacheExpiryWhenConnectedToANetwork;
@property NSTimeInterval cacheExpiryWhenOffline;
@property (nonatomic, retain) TTURLRequest *request;
@property (nonatomic, retain) id<HtmlParserDelegate> delegate;
@property BOOL loading;
  
  
@end











