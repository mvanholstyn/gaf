//
//  PostCell.h
//  MobileGAF
//
//  Created by Juice on 3/22/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#define kMargin 30.0
#define kHeaderHeight 30.0

#import <UIKit/UIKit.h>

@class Post, PostCellHeader;

@protocol PostCellDelegate <NSObject>

- (void)postCellDidFinishContentInjectionWithPost:(Post*)aPost;
- (void)handleReplyWithPost:(Post*)aPost;

@end


@interface PostCell : UITableViewCell <UIWebViewDelegate> {
	
	UIViewController *headerController;
	
	UIWebView *webView;
	
	Post *post;
	PostCellHeader *header;
	id<PostCellDelegate> delegate;
	
	BOOL loaded;
}

@property (nonatomic, retain) UIViewController *headerController;
@property (nonatomic, retain) PostCellHeader *header;
@property (nonatomic, retain) id<PostCellDelegate> delegate;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) Post *post;

/** 
 * Designated initializer.
 ***/
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier withPost:(Post*)aPost withIndex:(NSUInteger)index delegate:(id<PostCellDelegate>)aDelegate;


- (void) refreshWebViewWithPost:(Post*)post;

@end








