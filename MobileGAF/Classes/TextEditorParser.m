//
//  TextEditorParser.m
//  MobileGAF
//
//  Created by Juice on 5/30/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "TextEditorParser.h"
#import "XPathQuery.h"
#import "Tag.h"

@implementation TextEditorParser

#pragma mark -
#pragma mark HtmlParser

/** Sends delegate nil on failure. Delegate needs to re-request if it doesn't work **/
- (void)parseModelObjects:(NSData*)someData {
	NSLog(@"Parsing Text Editor");
	
	NSArray *textAreas = PerformHTMLXPathQueryForTags(someData, @"//textarea");
	NSMutableArray *resultStrings = nil;
	
	if(textAreas.count > 0) {
		resultStrings = [NSArray arrayWithObjects:[(Tag*)[textAreas objectAtIndex:0] retrieveTextUpToDepth:1 escapeHtmlEntities:NO],nil];
	} //else {
		//resultStrings = [NSArray arrayWithObjects:@"Error loading text.",nil];		
	//}

	if([delegate respondsToSelector:@selector(handleParseResults:)]) {
		[delegate handleParseResults:resultStrings];
	}
}

@end
