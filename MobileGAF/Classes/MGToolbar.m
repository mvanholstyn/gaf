//
//  MGToolbar.m
//  MobileGAF
//
//  Created by Juice on 5/13/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "MGToolbar.h"
#import <Three20/Three20.h>
#import "Three20/UIToolbarAdditions.h"
#import "MGStyleSheet.h"

@interface MGToolbar()

@end


@implementation MGToolbar

@synthesize view=_view;
@synthesize space;
@synthesize configureButton;
@synthesize stopButton;
@synthesize searchButton;
@synthesize replyButton;
@synthesize refreshButton;
@synthesize authorButton;

#pragma mark -
#pragma mark NSObject

- (void)dealloc{
	[_view release];
	[space release];
	[configureButton release];
	[stopButton release];
	[searchButton release];
	[replyButton release];
	[refreshButton release];
	[authorButton release];
	[super dealloc];
}

- (id)initWithView:(UIView*)view {
	if(self = [super initWithFrame:CGRectMake(view.bounds.origin.x, 
											  view.bounds.size.height-([TTSTYLESHEET uiToolbarHeight]), 
											  view.bounds.size.width, 
											  [TTSTYLESHEET uiToolbarHeight])]) {
		self.view = view;
		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;	
		self.tintColor = [TTSTYLESHEET navigationBarTintColor];
		self.alpha = [TTSTYLESHEET uiToolbarAlpha];
		
		//Set up buttons

		//Left position
		refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
										  UIBarButtonSystemItemRefresh target:nil action:@selector(refreshAction)];
		refreshButton.tag = kRefreshTag;
		stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
										UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
		stopButton.tag = kRefreshTag;	
		
		//Middle position
		searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
										 UIBarButtonSystemItemSearch target:nil action:@selector(searchAction)];
		searchButton.tag = kSearchTag;
		
		
		configureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cogIcon.png"]
														   style:UIBarButtonItemStylePlain
														  target:nil action:@selector(configureAction)];
		configureButton.imageInsets = UIEdgeInsetsMake(3, 0, -3, 0); //iPhone loves sucking at laying these out.
		
		configureButton.tag = kSearchTag;
		
		replyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
										UIBarButtonSystemItemReply target:nil action:@selector(replyAction)];
		replyButton.tag = kReplyTag;

		//Right position
		authorButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
					   UIBarButtonSystemItemCompose target:nil action:@selector(createThreadAction)];
		authorButton.tag = kReplyTag;		

		//TEMPORARY: TO make clear to beta testers that these aren't ready.
		searchButton.enabled =NO;
		
		space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
							 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		self.items = [NSArray arrayWithObjects:refreshButton,space,configureButton,space,replyButton,nil];
	}
	
	return self;
}

#pragma mark -
#pragma mark MGToolbar

- (void)setToolbarItemsResponder:(id<MGButtonActionResponder>) responder {
	configureButton.target = responder;
	replyButton.target = responder;
	searchButton.target = responder;
	authorButton.target = responder;
	refreshButton.target = responder;
	stopButton.target = responder;
}

- (void)setItemsEnabled:(BOOL)enabled {
	for (UIBarItem *item in self.items) {
		[item setEnabled:enabled];
	}
}

#pragma mark -
#pragma mark UIView

@end







