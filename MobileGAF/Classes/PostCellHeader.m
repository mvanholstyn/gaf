//
//  PostCellHeader.m
//  MobileGAF
//
//  Created by Juice on 3/29/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "PostCellHeader.h"
#import "Post.h"
#import "PostCell.h"

@implementation PostCellHeader

@synthesize post;
@synthesize delegate;
@synthesize replyButton;
@synthesize userNameLabel;
@synthesize avatarImage;

#pragma mark -
#pragma mark Application Methods

- (IBAction) replyButtonPressed {
	NSLog(@"Reply button pressed.");
	[delegate handleReplyWithPost:post];
}

#pragma mark -
#pragma mark UIView methods

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[post release];
	[delegate release];
	[replyButton release];
	[userNameLabel release];
	[avatarImage release];
    [super dealloc];
}


@end






