//
//  MGToolbar.h
//  MobileGAF
//
//  Created by Juice on 5/13/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRefreshTag 0
#define kSearchTag 1
#define kReplyTag 2

@protocol MGButtonActionResponder <NSObject>

@optional
- (void)refreshAction;
- (void)bookmarkAction;
- (void)searchAction;
- (void)createThreadAction;
- (void)replyAction;
- (void)configureAction;

- (void)quoteReplyActionForURL:(NSString*)url;
- (void)editReplyActionForURL:(NSString*)url;

@end


@interface MGToolbar : UIToolbar {
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *stopButton;
	
	UIBarButtonItem *searchButton;
	
	UIBarButtonItem *replyButton;
	UIBarButtonItem *authorButton;	
	
	UIBarButtonItem *configureButton;
	
	UIBarItem *space;
	
	UIView *_view;
}

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UIBarItem *space;

//Designated initializer
- (id)initWithView:(UIView*)view;

- (void)setToolbarItemsResponder:(id<MGButtonActionResponder>) responder;
- (void)setItemsEnabled:(BOOL)enabled;


@property (nonatomic, retain) UIBarButtonItem *configureButton;
@property (nonatomic, retain) UIBarButtonItem *stopButton;
@property (nonatomic, retain) UIBarButtonItem *searchButton;
@property (nonatomic, retain) UIBarButtonItem *replyButton;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) UIBarButtonItem *authorButton;

@end







