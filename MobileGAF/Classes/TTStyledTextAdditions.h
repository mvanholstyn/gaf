//
//  TTStyledTextAdditions.h
//  MobileGAF
//
//  Created by Juice on 4/30/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface TTStyledText (MGStyledTextAdditions)

- (NSArray*)allNodesOfClass:(Class)class;
- (NSArray*)allNodesForFrame:(TTStyledFrame*)frame;

@end
