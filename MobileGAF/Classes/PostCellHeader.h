//
//  PostCellHeader.h
//  MobileGAF
//
//  Created by Juice on 3/29/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>

@class Post,PostCell;

@protocol PostCellDelegate;


@interface PostCellHeader : UIView {

	id<PostCellDelegate> delegate;
	Post *post;
	
	IBOutlet TTImageView *avatarImage;
	IBOutlet UILabel *userNameLabel;
	IBOutlet UIButton *replyButton;
}

@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) id<PostCellDelegate> delegate;
@property (nonatomic, retain) UIButton *replyButton;
@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) TTImageView *avatarImage;

- (IBAction) replyButtonPressed;

@end






