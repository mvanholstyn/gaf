//
//  StyledPostHtmlParser.h
//  MobileGAF
//
//  Created by Juice on 4/25/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HtmlParser.h"

@class Post,Tag,Thread;

@interface StyledPostHtmlParser : HtmlParser {	
	NSMutableArray *postArray;
	Thread *thread;
}


- (NSString*)attributeValueForNode:(NSDictionary*)node atIndex:(NSUInteger)index;
- (NSString*)attributeValueForNode:(NSDictionary*)node withName:(NSString*)attributeName;

@property (nonatomic, retain) Thread *thread;
@property (nonatomic, retain) NSMutableArray *postArray;

@end


