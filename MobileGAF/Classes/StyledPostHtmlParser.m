//
//  StyledPostHtmlParser.m
//  MobileGAF
//
//  Created by Juice on 4/25/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "HtmlParser.h"
#import "Post.h"
#import "User.h"
#import "Tag.h"
#import "Account.h"
#import "Thread.h"
#import "UIAlertViewAdditions.h"
#import "StyledPostHtmlParser.h"
#import "MobileGAFAppDelegate.h"
#import "MGStyleSheet.h"
#import "NSStringAdditions.h"
#import "XPathQuery.h"
#import "PostCell.h"

@interface StyledPostHtmlParser()

- (void)determineWhetherTagsWillBeStyled:(NSArray*)tags;
//- (Tag*)tagForNode:(NSDictionary*)node;
- (NSString*)printTags:(NSArray*)tags;
- (void)updatePageCountIfNecessary:(NSData*)someData;

@end

@implementation StyledPostHtmlParser

@synthesize thread;
@synthesize postArray;

#pragma mark -
#pragma mark Application Methods

- (id)initWithUrl:(NSString*)aUrl delegate:(id<HtmlParserDelegate>) aDelegate isCaching:(BOOL)isCaching {
	return [self initWithUrl:aUrl delegate:aDelegate isCaching:isCaching expiresAfter:(60)];
}

- (void)updatePageCountIfNecessary:(NSData*)someData {
	if(thread) {
		NSArray *postTd = PerformHTMLXPathQuery(someData, @"//table/tr/td[2]/div/table/tr/td[1][@class=\"vbmenu_control\"]");
		if([postTd lastObject]) {
			NSString *pageDesc = [[postTd lastObject] objectForKey:@"nodeContent"];
			NSRange lastPageRange = [pageDesc rangeOfString:@" of "];
			[self.thread setPageCount:[[pageDesc substringFromIndex:(lastPageRange.location+lastPageRange.length)] integerValue]];
		}		
	}
}

- (void)parseModelObjects:(NSData*)someData {
	NSLog(@"Parsing Posts w/ STYLE");	

	//NSString *html = [[[NSString alloc] initWithData:someData encoding:NSISOLatin1StringEncoding] autorelease]; 
	//NSLog(@"HTML of page %@",html);
	
	[self updatePageCountIfNecessary:someData];
	
	NSUInteger loginFormCount = [PerformHTMLXPathQuery(someData, @"//table/tr/td[2]/form[@action=\"login.php\"]") count];
	//If the login form is there, they're not logged in.
	[MG_ACCOUNT setIsLoggedIn:!(loginFormCount > 0)];
	
	NSArray *postTables = PerformHTMLXPathQueryForTags(someData, @"//table[starts-with(@id,\"post\")]");
	
	NSMutableArray *aPostArray = [[[NSMutableArray alloc] initWithCapacity:[postTables count]] autorelease];
	for(Tag *postTable in postTables) {
		//One table per post.
		Post *post = [[[Post alloc] init] autorelease];
		//Setting the user on the post
		User *u = [[[User alloc] init] autorelease];
		[post setAuthor:u];
				
		//The "Ignore row" is the first row of the table, it's always blank if it's not an ignored user.
		Tag *ignoreRow = [[postTable childrenWithoutText] objectAtIndex:0];		
		if([ignoreRow valueForAttribute:@"title"]) {
			u.isOnIgnoreList = YES;
			
			//Get the post UID
			NSString *title = [ignoreRow valueForAttribute:@"title"];
			post.uid = [title substringFromIndex:[title rangeOfString:@"Post "].length];
			
			//Get
			Tag* userLink = (Tag*)[[(Tag*)[[(Tag*)[[postTable childrenWithoutText] objectAtIndex:1] //Second row
					childrenWithoutText] objectAtIndex:0] //First cell
					childrenWithoutText] objectAtIndex:1]; //Second child is <a>
			NSString *userUrl = [userLink valueForAttribute:@"href"];
			[u setUid:[userUrl substringFromIndex:[userUrl rangeOfString:@"member.php?u="].length]];
			[u setName:[(Tag*)[[userLink children] objectAtIndex:0] text]];
			
			post.content = [NSString stringWithFormat:
							@"<div class=\"ignorePostArea\">Post hidden - <a href=\"%@%@\">%@</a> is on your ignore list. \
							<br/>•<a href=\"%@showpost.php?p=%@\">View post</a> \
							<br/>•<a href=\"%@profile.php?userlist=ignore&amp;do=removelist&amp;u=%@\">Stop ignoring</a> \
							</div>",
							kNeoGafBaseUrl,userUrl,u.name,
							kNeoGafBaseUrl,post.uid,
							kNeoGafBaseUrl,u.uid];			
		} else {
			Tag *postRow = [postTable.children lastObject];
			
			Tag *userCell = [postRow.children objectAtIndex:0];
			//Set up user name, avatar URL, time
			
			//User's name
			Tag *userLink = [[userCell firstChildWithTagName:@"span"] //2nd child of cell is a span
							  firstChildWithTagName:@"a"]; //1st child of span is a link
			
			NSString *userName = [[userLink.children objectAtIndex:0] text];
			if(userName == nil) {
				userName = [[[[userLink.children objectAtIndex:0] children] objectAtIndex:0] text];
				[u setIsModerator:YES];
			} else {
				[u setIsModerator:NO];
			}
			[u setName:userName];
			
			//User's UID
			NSString *userUrl = [userLink valueForAttribute:@"href"];
			[u setUid:[userUrl substringFromIndex:[userUrl rangeOfString:@"member.php?u="].length]];
			
			//User's avatar image url
			Tag *avatarImage = [[[userCell lastChildWithTagName:@"div"] //last child of cell is a div
										 lastChildWithTagName:@"a"] //last child of div is a link
								  firstChildWithTagName:@"img"];
			[u setAvatarUrl:[avatarImage valueForAttribute:@"src"]];
			
			if(u.avatarUrl && ![u.avatarUrl hasPrefix:@"http://"]) {
				[u setAvatarUrl:[kNeoGafBaseUrl stringByAppendingString:u.avatarUrl]];
			}
			
			Tag *postCell = [[postRow childrenWithoutText] lastObject];
			NSArray *postCellWithoutChildren = [postCell childrenWithoutText];
			Tag *postDiv;
			for (Tag *child in postCellWithoutChildren) {
				if([[child valueForAttribute:@"id"] hasPrefix:@"post_message_"]) {
					postDiv = child;
				}
			}
			
			/* Set user tag, post date */
			NSArray *userCellDivs = [[postRow firstChildWithTagName:@"td"] childrenWithTagName:@"div"];
			
			//Print user's tag as styled XHTML.
			Tag *tagDiv = (Tag*)[userCellDivs objectAtIndex:0];
			//We need to set a custom class on all of the links
			[tagDiv setAttributeWithName:@"class" value:@"authorTextLink:" onChildrenWithTagName:@"a"];
			[self determineWhetherTagsWillBeStyled:[[[NSArray alloc] initWithObjects:tagDiv,nil] autorelease]];			
			[u setTag:[self printTags:[[[NSArray alloc] initWithObjects:tagDiv,nil] autorelease]]];			
			
			
			/* What does this stupid nested cluster of methods do?
			 * Glad you asked!
			 * First, it grabs the text inside of second dive in the user content area
			 * Then it uses a category method I created to rip out all the newlines and parenthese throughout the middle of the string
			 * Finally, it converts that to a mutable string and adds a space after the dumb comma in the middle
			 * The performance of this makes me cry.
			 */
			if(userCellDivs.count > 1) {
				NSMutableString *dateTimeDesc = [NSMutableString stringWithString:[[(Tag*)[userCellDivs objectAtIndex:1] retrieveTextUpToDepth:1]
																				   stringByRemovingCharactersInString:@"()" removeWhitespace:YES]];
				[dateTimeDesc replaceOccurrencesOfString:@"," withString:@", " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [post.dateTime length])];			
				[post setDateTime:dateTimeDesc];				
			} else {
				NSLog(@"Post had no post time...: \n%@",[[userCellDivs objectAtIndex:0] retrieveTextUpToDepth:10]);
			}

			/* Set post title, number */
			NSArray *postDivSpans = [[[postRow lastChildWithTagName:@"td"] firstChildWithTagName:@"div"] childrenWithTagName:@"span"];
			[post setTitle:[(Tag*)[postDivSpans objectAtIndex:0] retrieveTextUpToDepth:2]];
			[post setNumber:[[[(Tag*)[postDivSpans objectAtIndex:1] 
			   firstChildWithTagName:@"a"] 
				firstChildWithTagName:@"strong"] 
					retrieveTextUpToDepth:1]];
			
			//Set up post content (printed tags)
			//Set post ID
			NSString *postUidFull = [postDiv valueForAttribute:@"id"];
			[post setUid:[postUidFull substringFromIndex:[@"post_message_" length]]];
						
			//Print tags as appropriate
			[self determineWhetherTagsWillBeStyled:[[[NSArray alloc] initWithObjects:postDiv,nil] autorelease]];			
			[post setContent:[self printTags:[[[NSArray alloc] initWithObjects:postDiv,nil] autorelease]]];			
		}
		
		
		[aPostArray addObject:post];
	}
	
	if([delegate respondsToSelector:@selector(handleParseResults:)]) {
		[delegate handleParseResults:aPostArray];	
	}
}



- (void)determineWhetherTagsWillBeStyled:(NSArray*)tags {
	for (Tag *tag in tags) {
		//1.Determine if styled
		if([tag.name isEqualToString:@"br"]
			|| [tag.name isEqualToString:@"i"]
			|| [tag.name isEqualToString:@"b"]
			|| [tag.name isEqualToString:@"a"]) {
			tag.willBeStyled = YES;
		} else if([tag.name isEqualToString:@"strong"]) {
			//Rename to b.
			tag.willBeStyled = YES;
			tag.name = @"b";
		} else if([tag.name isEqualToString:@"em"]) {
			//Rename to i.
			tag.willBeStyled = YES;
			tag.name = @"i";
		} else if([tag.name isEqualToString:@"img"]) {
			tag.willBeStyled = YES;

			//We only want the src attribute on img. Others seem to bug out 320.
			NSString *src = [tag valueForAttribute:@"src"];
			[tag.attributeDict removeAllObjects];
			
			//Set the src back on it
			if(src && ![src hasPrefix:@"http://"] && ![src hasPrefix:@"bundle://"]) {
				//Many images will be local to the server, so if it's a 
				//relative img src link, then let's just concatenate that onto it
				[tag.attributeDict setValue:
				 [kNeoGafBaseUrl stringByAppendingString:src] forKey:@"src"];				
			} else {
				[tag.attributeDict setValue:src forKey:@"ogSource"];
				if(![MG_DELEGATE shouldLoadPostImages]) {
					//Replace all images w/ a default
					src = @"bundle://Three20.bundle/images/photoDefault.png";
				} else if([MG_DELEGATE shouldDelegateImagesToExternalService]) {					
					//Redirect all images to a web service to scale them down.
					
					//1. URLEncode the original sauce.
					NSString *escapedSrc = (NSString*) 
						CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																(CFStringRef)src, 
																NULL, 
																CFSTR(":/?&="), 
																kCFStringEncodingUTF8);

					//NSLog(@"escaped test %@",escapedSrc);
					src = [NSString stringWithFormat:@"%@?img=%@&amp;maxWidth=%d",
						kImageProcessUrl, escapedSrc, (NSUInteger)SHORTEST_WINDOW_EDGE_LENGTH];

				} else {
					//Default behavior scales everything up or down to 300x300 cap
					//Obvious sucks for narrow images or tiny ones.
					[tag.attributeDict setValue:@"300" forKey:@"width"];
					[tag.attributeDict setValue:@"300" forKey:@"height"];
				}

				[tag.attributeDict setValue:src forKey:@"src"];
			}
			
		}else if([tag.name isEqualToString:@"span"]) {
			NSString *class = [tag valueForAttribute:@"class"];
			
			//Highlights and spoilers
			if([class isEqualToString:@"highlight"]) {
				//NSLog(@"Found a spoiler or highlight");
				tag.willBeStyled = YES;
			} else if([class isEqualToString:@"spoiler"]) {
				tag.willBeStyled = YES;				
				
				//Three20 will look for styles with a colon to act highlightable.
				[tag.attributeDict setValue:@"spoiler:" forKey:@"class"];
			}
		} else if([tag.name isEqualToString:@"div"]) {
			//Check for quote
			NSString *style = [tag valueForAttribute:@"style"];
			if([style isEqualToString:@"font-style:italic"]) {
				//NSLog(@"Found a quotearea");
				tag.willBeStyled = YES;
				[tag.attributeDict setValue:@"quotearea" forKey:@"class"];
			} else if([style isEqualToString:@"margin-bottom:2px"]) {
				//Might be a quote area header
				NSString *class = [tag valueForAttribute:@"class"];
				if([class isEqualToString:@"smallfont"]) {
					NSString *text = [(Tag*)[tag.children objectAtIndex:0] text];
					//NSLog(@"Text is `%@`",text);
					if([text hasPrefix:@"Originally Posted by"] || [text hasPrefix:@"Quote:"]) {
						//NSLog(@"found a quoteheader.");
						tag.willBeStyled = YES;
						[tag.attributeDict setValue:@"quoteheader" forKey:@"class"];						
					}
				}
			} else if([[tag.attributeDict valueForKey:@"id"] hasPrefix:@"post_message"]) {
				//Is hopefully the outermost div. We're going to use this for the most basic padding class
				tag.willBeStyled = YES;
				[tag.attributeDict setValue:@"postarea" forKey:@"class"];				
			}
		}
		
		//2. Send children to be set up too
		if(tag.children) {
			[self determineWhetherTagsWillBeStyled:tag.children];
		}
	}
} 

//- (Tag*)tagForNode:(NSDictionary*)node {	
//	NSString *name = [node objectForKey:@"nodeName"];
//	NSString *text = [node objectForKey:@"nodeContent"];
//	NSMutableDictionary *attrs = nil;
//	BOOL willBeStyled;
//	
//	//Cherry-pick the elements we want to let impact our style.
//	if([name isEqualToString:@"br"] || [name isEqualToString:@"i"] || [name isEqualToString:@"b"]) {
//		willBeStyled = YES;
//	} else if([name isEqualToString:@"strong"]) {
//		//Rename to b.
//		willBeStyled = YES;
//		name = @"b";
//	} else if([name isEqualToString:@"em"]) {
//		//Rename to i
//		willBeStyled = YES;		
//		name = @"i";
//	} else if([name isEqualToString:@"span"]) {
//		NSString *class = [self attributeValueForNode:node withName:@"class"];
//		
//		//Highlights and spoilers
//		if([class isEqualToString:@"highlight"] || [class isEqualToString:@"spoiler"]) {
//			//NSLog(@"Found a spoiler or highlight");
//			willBeStyled = YES;			
//			attrs = [[[NSMutableDictionary alloc] init] autorelease];
//			[attrs setValue:class forKey:@"class"];
//		}
//	} else if([name isEqualToString:@"div"]) {
//		//Check for quote
//		NSString *style = [self attributeValueForNode:node withName:@"style"];
//		if([style isEqualToString:@"font-style:italic"]) {
//			//NSLog(@"Found a quotearea");
//			willBeStyled = YES;
//			attrs = [[[NSMutableDictionary alloc] init] autorelease];
//			[attrs setValue:@"quotearea" forKey:@"class"];
//		} else if([style isEqualToString:@"margin-bottom:2px"]) {
//			//Might be a quote area header
//			NSString *class = [self attributeValueForNode:node withName:@"class"];
//			if([class isEqualToString:@"smallfont"] && [text hasPrefix:@"Originally Posted by "]) {
//				//NSLog(@"found a quoteheader.");
//				willBeStyled = YES;
//				attrs = [[[NSMutableDictionary alloc] init] autorelease];
//				[attrs setValue:@"quoteheader" forKey:@"class"];
//			}
//		}
//	}
//	
//	//NSLog(@"Tag: %@",name);
//	return [[[Tag alloc] initWithName:name text:text attributes:attrs willBeStyled:willBeStyled] autorelease];
//}

- (NSString*)printTags:(NSArray*)tags {
	NSMutableString *sb = [[[NSMutableString alloc] init] autorelease];
	for (Tag *tag in tags) {
		if(tag.willBeStyled && !tag.text && (tag.children == nil || tag.children.count ==0)) {
			//Tag is independent, no children and should self-terminate
			
			//Wrap any default-forced images in links.
			if([tag.name isEqualToString:@"img"]) {
				NSString *src = [tag valueForAttribute:@"ogSource"];
				if(src) {
					[sb appendFormat:@" <a href=\"%@\">",src];
				}					
			}
			
			[sb appendFormat:@" <%@",tag.name];
			for (NSString *key in [tag.attributeDict allKeys]) {
				[sb appendFormat:@" %@=\"%@\"",key,[tag valueForAttribute:key]];
			}
			[sb appendString:@" /> "];
			
			//Wrap any images in links.
			if([tag.name isEqualToString:@"img"]) {
				if([tag valueForAttribute:@"ogSource"]) {
					[sb appendString:@" </a>"];
				}					
			}
			
		} else {
			//Write the tag and terminate it separately.
			
			if(tag.willBeStyled) {				
				[sb appendFormat:@" <%@",tag.name];
				for (NSString *key in [tag.attributeDict allKeys]) {
					[sb appendFormat:@" %@=\"%@\"",key,[tag valueForAttribute:key]];
				}
				[sb appendString:@">"];			
			}
			
			//Append the text of the tag
			if(tag.text) {
				//Ugly, but ran into issues with not escaping < and > in posts
				[sb appendString:[tag.text stringByReplacingXMLElementEntities]];
			}
			

			
			//Draw children
			if(tag.children != nil && tag.children.count > 0) {
				[sb appendString:[self printTags:tag.children]];
			}
			
			//Close tag if it's to be styled
			if(tag.willBeStyled) {
				[sb appendFormat:@"</%@> ",tag.name];								
			}			
		}		
	}
	return sb;
}

- (NSString*)attributeValueForNode:(NSDictionary*)node atIndex:(NSUInteger)index {
	return [(NSDictionary*)[(NSArray*)[node objectForKey:@"nodeAttributeArray"] objectAtIndex:index] objectForKey:@"nodeContent"];
}

- (NSString*)attributeValueForNode:(NSDictionary*)node withName:(NSString*)attributeName {
	NSArray *attrs = (NSArray*)[node objectForKey:@"nodeAttributeArray"];
	for (NSDictionary* attr in attrs) {
		if([(NSString*)[attr objectForKey:@"attributeName"] isEqualToString:attributeName]) {
			return [attr objectForKey:@"nodeContent"];
		}
	}
	return nil;
}
 
#pragma mark -
#pragma mark NSObject
-(void) dealloc {
	[postArray release];
	[thread release];
	[super dealloc];
}



@end









