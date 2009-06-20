//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "XPathQuery.h"
#import "Tag.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>


//Tag for node. --- Added for MobileGaf
Tag *tagForNode(xmlNodePtr currentNode, Tag *parentTag) { 
	
	//Create a tag for this xmlNodePtr
	Tag *tag = [[[Tag alloc] init] autorelease]; 
	
	//Set the Name of the tag.
	if (currentNode->name) {
		[tag setName:[NSString stringWithCString:(const char *)currentNode->name encoding:XPATH_STRING_ENCODING]];
	}
	
	//If the Tag has content, we'll set it.
	if (currentNode->content && currentNode->content != (xmlChar *)-1) {
		NSString *currentNodeContent = [NSString stringWithCString:(const char *)currentNode->content encoding:XPATH_STRING_ENCODING];
		
		//We don't want to create a new Tag for text elements, we'll just append the text to our parent tag, return nil.
		if ([tag.name isEqual:@"text"]) {			
			currentNodeContent = [currentNodeContent
								  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];			
		}
		
		[tag setText:currentNodeContent];		
	}
	
	//We'll also add each attribute to our tag.
	xmlAttr *attribute = currentNode->properties;
	while(attribute) {
		NSString *attributeName = [NSString stringWithCString:(const char *)attribute->name encoding:XPATH_STRING_ENCODING];
		if (attributeName && attribute->children) {
			NSString *attributeValue = [NSString stringWithCString:(const char*) attribute->children->content encoding:XPATH_STRING_ENCODING];				
			[tag addAttributeWithName:attributeName value:attributeValue];
		}
		attribute = attribute->next;
	}
	
	xmlNodePtr childNode = currentNode->children;
	while (childNode) {
		Tag *childTag = tagForNode(childNode, tag);
		if (childTag) {
			[tag addChildTag:childTag];
		}
		childNode = childNode->next;
	}
	
	return tag;
}


NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult)
{
	NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
	
	if (currentNode->name)
	{
		NSString *currentNodeContent =
			[NSString stringWithCString:(const char *)currentNode->name encoding:XPATH_STRING_ENCODING];
		[resultForNode setObject:currentNodeContent forKey:@"nodeName"];
	}
	
	if (currentNode->content && currentNode->content != (xmlChar *)-1)
	{
		NSString *currentNodeContent =
			[NSString stringWithCString:(const char *)currentNode->content encoding:XPATH_STRING_ENCODING];
		
		if ([[resultForNode objectForKey:@"nodeName"] isEqual:@"text"] && parentResult)
		{
			currentNodeContent = [currentNodeContent
				stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			NSString *existingContent = [parentResult objectForKey:@"nodeContent"];
			NSString *newContent;
			if (existingContent)
			{
				newContent = [existingContent stringByAppendingString:currentNodeContent];
			}
			else
			{
				newContent = currentNodeContent;
			}

			[parentResult setObject:newContent forKey:@"nodeContent"];
			return nil;
		}
		
		[resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
	}
	
	xmlAttr *attribute = currentNode->properties;
	if (attribute)
	{
		NSMutableArray *attributeArray = [NSMutableArray array];
		while (attribute)
		{
			NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
			NSString *attributeName =
				[NSString stringWithCString:(const char *)attribute->name encoding:XPATH_STRING_ENCODING];
			if (attributeName)
			{
				[attributeDictionary setObject:attributeName forKey:@"attributeName"];
			}
			
			if (attribute->children)
			{
				NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary);
				if (childDictionary)
				{
					[attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
				}
			}
			
			if ([attributeDictionary count] > 0)
			{
				[attributeArray addObject:attributeDictionary];
			}
			attribute = attribute->next;
		}
		
		if ([attributeArray count] > 0)
		{
			[resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
		}
	}

	xmlNodePtr childNode = currentNode->children;
	if (childNode)
	{
		NSMutableArray *childContentArray = [NSMutableArray array];
		while (childNode)
		{
			NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode);
			if (childDictionary)
			{
				[childContentArray addObject:childDictionary];
			}
			childNode = childNode->next;
		}
		if ([childContentArray count] > 0)
		{
			[resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
		}
	}
	
	return resultForNode;
}

NSArray *PerformXPathQuery(xmlDocPtr doc, NSString *query, BOOL shouldReturnTagArray)
{
    xmlXPathContextPtr xpathCtx; 
    xmlXPathObjectPtr xpathObj; 

    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    if(xpathCtx == NULL)
	{
		NSLog(@"Unable to create XPath context.");
		return nil;
    }
    
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:XPATH_STRING_ENCODING], xpathCtx);
    if(xpathObj == NULL) {
		NSLog(@"Unable to evaluate XPath.");
		return nil;
    }
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if (!nodes)
	{
		NSLog(@"XPath query reports that nodes was nil for:%@",query);
		return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for (NSInteger i = 0; i < nodes->nodeNr; i++) {
		if(shouldReturnTagArray) {
			Tag *tag = tagForNode(nodes->nodeTab[i], nil);
			if(tag) {
				[resultNodes addObject:tag];
			}
		} else {
			NSDictionary *nodeDictionary = DictionaryForNode(nodes->nodeTab[i], nil);
			if (nodeDictionary) {
				[resultNodes addObject:nodeDictionary];
			}			
		}
	}

    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx); 
    
    return resultNodes;
}

NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query)
{
    xmlDocPtr doc;

    /* Load XML document */
	doc = htmlReadMemory([document bytes], [document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query, NO);
    xmlFreeDoc(doc); 
	
	return result;
}

NSArray *PerformXMLXPathQuery(NSData *document, NSString *query)
{
    xmlDocPtr doc;
	
    /* Load XML document */
	doc = xmlReadMemory([document bytes], [document length], "", NULL, XML_PARSE_RECOVER);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query, NO);
    xmlFreeDoc(doc); 
	
	return result;
}

//Will specifically return in the Tag model object for less redundant recursing -- Added for MobileGaf
NSArray *PerformHTMLXPathQueryForTags(NSData *document, NSString *query) {
    xmlDocPtr doc;
	
    /* Load XML document */
	doc = htmlReadMemory([document bytes], [document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query, YES);
    xmlFreeDoc(doc); 
	
	return result;
}

