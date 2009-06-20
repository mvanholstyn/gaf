//
//  Tag.m
//  MobileGAF
//
//  Created by Juice on 4/25/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "Tag.h"
#import "NSStringAdditions.h"

@implementation Tag

@synthesize children;
@synthesize willBeStyled;
@synthesize text;
@synthesize name;
@synthesize attributeDict;

#pragma mark -
#pragma mark NSObject

- (id)initWithName:(NSString*)aName {
	return [self initWithName:aName text:nil attributes:nil willBeStyled:NO];
}

- (id)initWithName:(NSString*)aName text:(NSString*)someText {
	return [self initWithName:aName text:someText attributes:nil willBeStyled:NO];
}

- (id)initWithName:(NSString*)aName text:(NSString*)someText attributes:(NSMutableDictionary*)attributes {
	return [self initWithName:aName text:someText attributes:nil willBeStyled:NO];
}

- (id)initWithName:(NSString*)aName text:(NSString*)someText attributes:(NSMutableDictionary*)attributes willBeStyled:(BOOL)isStyled {
	if (self = [super init]) {
		self.name = aName;
		self.text = someText;
		self.attributeDict = attributes;
		self.willBeStyled = isStyled;
	}
	return self;
}

- (void)addChildTag:(Tag*)tag {
	if(self.children == nil) {
		self.children = [[[NSMutableArray alloc] init] autorelease];
	}
	[self.children addObject:tag];
}

- (void)addText:(NSString*)someText {
	if(self.text == nil) {
		self.text = someText;
	} else {
		self.text = [self.text stringByAppendingString:someText];
	}
}

- (void)addAttributeWithName:(NSString*)attrName value:(NSString*)attrValue {
	if(self.attributeDict == nil) {
		self.attributeDict = [[[NSMutableDictionary alloc] init] autorelease];
	}
	[self.attributeDict setValue:attrValue forKey:attrName];	
}

- (void)setAttributeWithName:(NSString*)attrName value:(NSString*)attrValue onChildrenWithTagName:(NSString*)tagName {
	if([name isEqualToString:tagName]) {
		[self addAttributeWithName:attrName value:attrValue];
	}
	
	for (Tag *child in children) {
		[child setAttributeWithName:attrName value:attrValue onChildrenWithTagName:tagName];
	}
}

#pragma mark -
#pragma mark Chidren

- (NSArray*)childrenWithoutText {
	NSMutableArray *childrenWithoutText = [[[NSMutableArray alloc] init] autorelease];;

	for (int i=0; i<[self.children count]; i++) {
		Tag *tag = [self.children objectAtIndex:i];
		if(![tag.name isEqualToString:@"comment"]
		   && ![tag.name isEqualToString:@"text"]) {
			[childrenWithoutText addObject:tag];
		}
	}
	return childrenWithoutText;
}

- (NSArray*)childrenWithTagName:(NSString*)aName {
	NSMutableArray *childrenWithTagName = [[[NSMutableArray alloc] init] autorelease];;
	
	for (int i=0; i<[self.children count]; i++) {
		Tag *tag = [self.children objectAtIndex:i];
		if([tag.name isEqualToString:aName]) {
			[childrenWithTagName addObject:tag];
		}
	}
	return childrenWithTagName;
}

- (Tag*)childWithTagName:(NSString*)aName atIndex:(NSUInteger)index {
	NSArray *tags = [self childrenWithTagName:aName];
	if(tags.count > index) {
		return [tags objectAtIndex:index];
	} else {
		/*
		@throw [NSException exceptionWithName:@"TagDoesNotExist" 
									   reason:[NSString stringWithFormat:@"Child Tag named %@ at index %d didn't exist",aName,index] 
		 userInfo:nil];*/
		return nil;
	}
}

- (Tag*)firstChildWithTagName:(NSString*)aName {
	for (int i=0; i<[self.children count]; i++) {
		Tag *tag = [self.children objectAtIndex:i];
		if([tag.name isEqualToString:aName]) {
			return tag;
		}
	}
	/*@throw [NSException exceptionWithName:@"TagDoesNotExist" 
								   reason:[NSString stringWithFormat:@"Child Tag named %@ didn't exist",aName] 
								 userInfo:nil];*/
	return nil;
	 
}

- (Tag*)lastChildWithTagName:(NSString*)aName {
	Tag *lastChild = nil;
	for (int i=0; i<[self.children count]; i++) {
		Tag *tag = [self.children objectAtIndex:i];
		if([tag.name isEqualToString:aName]) {
			lastChild = tag;
		}
	}
	
	if(!lastChild) {
		/*@throw [NSException exceptionWithName:@"TagDoesNotExist" 
									   reason:[NSString stringWithFormat:@"Child Tag named %@ didn't exist",aName] 
		 userInfo:nil];		*/
		return nil;
	} else {		
		return lastChild;
	}
}

#pragma mark -
#pragma mark Attrs
- (NSString*) valueForAttribute:(NSString*)aName escapeHtmlEntities:(BOOL)shouldEscape {
	if(shouldEscape) {
		return [[self.attributeDict valueForKey:aName] stringByReplacingXMLElementEntities];		
	} else {
		return [self.attributeDict valueForKey:aName];
	}
}

- (NSString*) valueForAttribute:(NSString*)aName {
	return [self valueForAttribute:aName escapeHtmlEntities:YES];
}

#pragma mark -
#pragma mark Text
- (NSString*)retrieveTextUpToDepth:(NSUInteger)depth escapeHtmlEntities:(BOOL)shouldEscape { 
	if([self.name isEqualToString:@"comment"]) {
		return @"";
	}
	
	NSMutableString *sb = [NSMutableString string];
	if(self.text) {
		[sb appendString:self.text];	
	}
	if(depth > 0 || depth == -1) {
		for (Tag* child in self.children) {
			[sb appendString:[child retrieveTextUpToDepth:depth-1]];
		}
	}
	
	if(shouldEscape) {
		return [sb stringByReplacingXMLElementEntities];	
	} else {
		return sb;
	}
}

- (NSString*)retrieveTextUpToDepth:(NSUInteger)depth {
	return [self retrieveTextUpToDepth:depth escapeHtmlEntities:YES];
}

- (void)dealloc {
	[name release];
	[text release];
	[attributeDict release];
	[children release];
	[super dealloc];
}

@end





