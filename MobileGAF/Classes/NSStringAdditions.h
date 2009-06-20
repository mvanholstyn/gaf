//
//  NSStringAdditions.h
//  MobileGAF
//
//  Created by Juice on 5/15/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (MGString)

- (NSString*)stringAsPostVariable;

//Replaces < with &lt; and > with &gt;
- (NSString*)stringByReplacingXMLElementEntities; //TODO: fix this name.
- (NSString*)stringByUnescapingXMLElementEntities;
- (NSString*)stringByRemovingCharactersInString:(NSString*)chars removeWhitespace:(BOOL)whitespace;
- (NSString*)stringByRemovingCharactersInSet:(NSCharacterSet*)charSet options:(unsigned) mask;

/**
 * here's the use case. You have a bunch of characters/tokens within a big string that need to be swapped
 * out for different characters/tokens in a pairwise fashion. (say, specific html entities). So you just
 * pass them in here, like so: @"firstToken", @"firstToken's Replacement",@"secondToken", etc.
 *
 */
- (NSString*)stringByReplacingEachStringWithTheNext:(NSString *)token, ... NS_REQUIRES_NIL_TERMINATION;

@end
