//
//  EditorController.h
//  MobileGAF
//
//  Created by Juice on 5/30/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "LoginRequestDispatcher.h"
#import "MGWelcomeScreen.h"

#define kMaxTitleCharacterLength 85

typedef enum {
	EditorControllerTypeThread,
	EditorControllerTypeReply,
	EditorControllerTypeReplyWithQuote,
	EditorControllerTypeEdit,
} EditorControllerType;

@class MGMessageController, EditorController,TextEditorParser;
@protocol HtmlParserDelegate;

@protocol EditorControllerDelegate <NSObject>

- (NSDictionary*)submissionParamsForEditor:(EditorController*)editor;

@optional
- (void)editorDidSubmit:(EditorController*)editor;
- (void)editorDidCancel:(EditorController*)editor;
@end

/* EditorController - should manage the lifecycle of
 *	a MGMessageController when it's being used to 
 *	- Create a Thread
 *  - Create a reply
 *  - Quote-reply a post
 *  - Edit a post (of your own)
 */
@interface EditorController : NSObject <HtmlParserDelegate, MGWelcomeScreenDelegate,TTMessageControllerDelegate,UIAlertViewDelegate,TTURLRequestDelegate,LoginRequestDispatcherDelegate> {
	MGMessageController *_messageController;
	NSString *_submitUrl;
	NSString *_contentUrl;
	EditorControllerType _type;
	id<EditorControllerDelegate> _delegate;
	
	TextEditorParser *_textEditorParser;
}

@property (nonatomic, retain) TextEditorParser *textEditorParser;
@property (nonatomic, retain) id<EditorControllerDelegate> delegate;
@property EditorControllerType type;
@property (nonatomic, retain) NSString *submitUrl;
@property (nonatomic, retain) NSString *contentUrl;
@property (nonatomic, retain) MGMessageController *messageController;

- (id)initWithType:(EditorControllerType)type delegate:(id<EditorControllerDelegate>)delegate submitUrl:(NSString*)submitUrl;
- (id)initWithType:(EditorControllerType)type delegate:(id<EditorControllerDelegate>)delegate submitUrl:(NSString*)submitUrl contentUrl:(NSString*)contentUrl;

- (MGMessageController*)openEditorWithRequiredTitle:(BOOL)requiredTitle;

@end




