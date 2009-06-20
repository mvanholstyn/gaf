//
//  NSStringAdditions.m
//  MobileGAF
//
//  Created by Juice on 5/15/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "NSStringAdditions.h"


@implementation NSString (MGString)

- (NSString*)stringAsPostVariable {
	NSMutableString *escaped = [NSMutableString stringWithString:[self stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

	//Change %20 to ' '
	[escaped replaceOccurrencesOfString:@"%20" withString:@"+" options:NSLiteralSearch  range:NSMakeRange(0, [escaped length])];
//	[escaped replaceOccurrencesOfString:@"%0A" withString:@"\n" options:NSLiteralSearch  range:NSMakeRange(0, [escaped length])];	
	
	return escaped;
}

- (NSString*)stringByReplacingXMLElementEntities {
	//This looks incredibly efficient.
	return [[[self stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]
			   stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
			stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
}

- (NSString*)stringByUnescapingXMLElementEntities {
	return [[[[self stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
			 stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"]
			stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]
			stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
}

- (NSString*)stringByRemovingCharactersInString:(NSString*)chars removeWhitespace:(BOOL)whitespace {
	
	
	NSMutableCharacterSet *charSet =  whitespace ? 
		[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]	
		: 
		[[[NSMutableCharacterSet alloc] init] autorelease];
	
	[charSet addCharactersInString:chars];
	return [self stringByRemovingCharactersInSet:charSet options:0];
}

- (NSString*) stringByRemovingCharactersInSet:(NSCharacterSet*)charSet options:(unsigned) mask {
	NSRange range;
	NSMutableString *newString = [NSMutableString string];
	unsigned len = [self length];
	
	mask &= ~NSBackwardsSearch;
	range = NSMakeRange(0, len);
	while(range.length) {
		NSRange substringRange;
		unsigned pos = range.location;
		
		range = [self rangeOfCharacterFromSet:charSet options:mask range:range];
		if(range.location == NSNotFound) {
			range = NSMakeRange(len, 0);
		}
		
		substringRange = NSMakeRange(pos, range.location - pos);
		[newString appendString:[self substringWithRange:substringRange]];
		range.location += range.length;
		range.length = len - range.location;
	}
	
	return newString;
}

- (NSString*)stringByReplacingEachStringWithTheNext:(NSString *)token, ... {
    NSMutableString *sb = [self mutableCopy];

	NSString *target;
	NSString *replacement; 
	
    va_list args;
    va_start(args, token);
    for (NSString *arg = token; arg != nil; arg = va_arg(args, NSString*)) {
		//TODO: unescape with regex
		if(!target) {
			target = arg;			
		} else {
			replacement = arg;
			[sb replaceOccurrencesOfString:target withString:replacement options:NSCaseInsensitiveSearch range:NSMakeRange(0, sb.length)];
			
			target = nil;
		}
    }
    va_end(args);
    
	return sb;
}


@end



