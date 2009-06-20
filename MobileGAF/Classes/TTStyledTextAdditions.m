//
//  TTStyledTextAdditions.m
//  MobileGAF
//
//  Created by Juice on 4/30/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "TTStyledTextAdditions.h"

@implementation TTStyledText (MGStyledTextAdditions)

- (NSArray*)allNodesOfClass:(Class)class {
	NSArray *nodes = [self allNodesForFrame:self.rootFrame];
	NSMutableArray *nodesOfClass = [[[NSMutableArray alloc] init] autorelease];
	for (TTStyledNode *node in nodes) {
		if([node isKindOfClass:class]) {
			[nodesOfClass addObject:node];
		}
	}
	
	return nodesOfClass;
}

- (NSArray*)allNodesForFrame:(TTStyledFrame*)frame {
	NSMutableArray *nodes = [[[NSMutableArray alloc] init] autorelease];

	while(frame) {
		[nodes addObject:frame.element];	
		
		TTStyledNode *child = [frame.element firstChild];
		while(child) {
			[nodes addObject:child];
			child = child.nextSibling;
		}
		
		frame = frame.nextFrame;
	}
	
	return nodes;	
}

@end
