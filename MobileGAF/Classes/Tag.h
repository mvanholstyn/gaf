//
//  Tag.h
//  MobileGAF
//
//  Created by Juice on 4/25/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tag : NSObject {
	NSString *name;
	NSMutableDictionary *attributeDict;
	NSString *text;
	
	BOOL willBeStyled;
	
	NSMutableArray *children;
}

@property (nonatomic, retain) NSMutableArray *children;
@property BOOL willBeStyled;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableDictionary *attributeDict;

- (id)initWithName:(NSString*)aName;
- (id)initWithName:(NSString*)aName text:(NSString*)someText;
- (id)initWithName:(NSString*)aName text:(NSString*)someText attributes:(NSMutableDictionary*)attributes;
/** Designated initializer **/
- (id)initWithName:(NSString*)aName text:(NSString*)someText attributes:(NSMutableDictionary*)attributes willBeStyled:(BOOL)isStyled;

/** Mutators **/
- (void)addChildTag:(Tag*)tag;
- (void)addText:(NSString*)someText;
- (void)addAttributeWithName:(NSString*)attrName value:(NSString*)attrValue;
- (void)setAttributeWithName:(NSString*)attrName value:(NSString*)attrValue onChildrenWithTagName:(NSString*)tagName;

/** Child retrievers **/
//Returns the child array but cuts text, comment elements
- (NSArray*)childrenWithoutText;
- (NSArray*)childrenWithTagName:(NSString*)name;
- (Tag*)childWithTagName:(NSString*)name atIndex:(NSUInteger)index;
- (Tag*)firstChildWithTagName:(NSString*)name;
- (Tag*)lastChildWithTagName:(NSString*)name;

/** Attr retrievers **/
- (NSString*) valueForAttribute:(NSString*)aName; //default escapes.
- (NSString*) valueForAttribute:(NSString*)aName escapeHtmlEntities:(BOOL)shouldEscape;

/** Text retrievers **/
- (NSString*)retrieveTextUpToDepth:(NSUInteger)maxDepth; //default escapes.
- (NSString*)retrieveTextUpToDepth:(NSUInteger)maxDepth escapeHtmlEntities:(BOOL)shouldEscape;

@end





