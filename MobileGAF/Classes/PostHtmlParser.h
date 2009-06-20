//
//  PostHtmlParser.h
//  MobileGAF
//
//  Created by Juice on 3/22/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#define kPostContentTextNodeDepth 1
#define	kPostIdAttrPrefix @"post_message_"

#import <Foundation/Foundation.h>
#import "HtmlParser.h"

@class Post;

@interface PostHtmlParser : HtmlParser {	
	NSMutableArray *postArray;
}

@property (nonatomic, retain) NSMutableArray *postArray;

@end








