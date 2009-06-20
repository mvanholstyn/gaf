//
//  EditorController.m
//  MobileGAF
//
//  Created by Juice on 5/30/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "HtmlParser.h"
#import "MGMessageController.h"
#import "EditorController.h"
#import "MobileGAFAppDelegate.h"
#import "NSStringAdditions.h"
#import "Account.h"
#import "UIAlertViewAdditions.h"
#import "LoginRequestDispatcher.h"
#import "TextEditorParser.h"
#import "MGWelcomeScreen.h"

@interface EditorController()

- (void)triggerLoginRetryAlert;
- (void)sendRequestWithTitle:(NSString*)title message:(NSString*)message;
- (void)loadContentIntoEditor;

@end


@implementation EditorController

@synthesize textEditorParser =_textEditorParser, delegate = _delegate, type = _type, submitUrl = _submitUrl, 
			contentUrl = _contentUrl, messageController = _messageController;

#pragma mark -
#pragma mark NSObject

- (id)init {
	return [self initWithType:EditorControllerTypeReply delegate:nil submitUrl:nil contentUrl:nil];
}

- (id)initWithType:(EditorControllerType)type delegate:(id<EditorControllerDelegate>)delegate submitUrl:(NSString*)submitUrl {
	return [self initWithType:EditorControllerTypeReply delegate:delegate submitUrl:submitUrl contentUrl:nil];
}

- (id)initWithType:(EditorControllerType)type delegate:(id<EditorControllerDelegate>)delegate submitUrl:(NSString*)submitUrl contentUrl:(NSString*)contentUrl {
	if(self = [super init]) {
		self.type = type;
		self.submitUrl = submitUrl;
		self.contentUrl = contentUrl;
		self.delegate = delegate;
	}
	return self;	
}

- (void)dealloc {
	[_submitUrl release];
	[_contentUrl release];
	[_delegate release];
	[_textEditorParser release];
	[_messageController release];
	[super dealloc];
}

#pragma mark -
#pragma mark EditorController

- (void)loadContentIntoEditor {
	//Start parsing that content to add it.
	_textEditorParser = [[TextEditorParser alloc] initWithUrl:_contentUrl delegate:self isCaching:NO];
	[_textEditorParser beginLoadingAndParsing];
	
	[_messageController updateLoadingStatusView:YES];
}

- (MGMessageController*)openEditorWithRequiredTitle:(BOOL)requiredTitle {
	_messageController = [[MGMessageController alloc] initWithRequiredTitle:requiredTitle];
	_messageController.delegate = self;	
	
	Account *account = MG_ACCOUNT;
	if(!account.isLoggedIn) {
		[_messageController attemptLoginWithDelegate:self];
	} else if(_contentUrl) {
		//Load content If we're not logged in, we'll load content into editor after login.
		[self loadContentIntoEditor];
	}
	
	return _messageController;
}

- (void)triggerLoginRetryAlert {
	[UIAlertView choiceAlertWithTitle:@"Not Logged In" 
							  message:@"You are not logged in. Your post was not submitted."
						   buttonName:kRetryCommandName 
					   nextButtonName:kSettingsCommandName
							 delegate:self];	
}

- (void)sendRequestWithTitle:(NSString*)title message:(NSString*)message {
	
	TTURLRequest *request = [[[TTURLRequest alloc] initWithURL:_submitUrl delegate:self] autorelease];
	[request setResponse:[[[TTURLDataResponse alloc] init] autorelease]];
	request.shouldHandleCookies = YES;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;
	request.httpMethod = @"POST";

	//Params that are standard
	[request.parameters setObject:@"" forKey:@"s"];
	[request.parameters setObject:@"0" forKey:@"wysiwyg"];
	[request.parameters setObject:@"" forKey:@"posthash"];
	[request.parameters setObject:@"" forKey:@"poststarttime"];
	[request.parameters setObject:@"1" forKey:@"parseurl"];
	[request.parameters setObject:@"9999" forKey:@"emailupdate"];
	
	[request.parameters setObject:message forKey:@"message"];			
	
	
	//Params that variable application data must satiate
	NSDictionary *userParams = [_delegate submissionParamsForEditor:self];
	if(userParams) {
		NSEnumerator *enumerator = [userParams keyEnumerator];
		id key;	
		while ((key = [enumerator nextObject])) {
			[request.parameters setObject:[userParams objectForKey:key] forKey:key];
		}			
	}
	
	NSRange pRange;
		
	//Params that vary by type - these ones get final say to avoid silly application override bugs
	switch (_type) {
		case EditorControllerTypeReplyWithQuote: 
			pRange = [_contentUrl rangeOfString:@"p="];
			[request.parameters setObject:[_contentUrl substringFromIndex:(pRange.location+pRange.length)] 
			 forKey:@"p"];
			//Intentional fall-through behavior.
		case EditorControllerTypeReply:
			[request.parameters setObject:@"postreply" forKey:@"do"];
			[request.parameters setObject:@"Submit+Reply" forKey:@"sbutton"];	
			
			[request.parameters setObject:title forKey:@"title"];
			break;
		case EditorControllerTypeThread:
			[request.parameters setObject:@"postthread" forKey:@"do"];
			[request.parameters setObject:@"Submit+New+Thread" forKey:@"sbutton"];
			
			[request.parameters setObject:title forKey:@"subject"];
			break;
		case EditorControllerTypeEdit:
			
			pRange = [_contentUrl rangeOfString:@"p="];
			[request.parameters setObject:[_contentUrl substringFromIndex:(pRange.location+pRange.length)] 
								   forKey:@"p"];
			
						
			[request.parameters setObject:@"updatepost" forKey:@"do"];
			[request.parameters setObject:@"Save+Changes" forKey:@"sbutton"];	
			[request.parameters setObject:@"" forKey:@"reason"];
			
			[request.parameters setObject:title forKey:@"title"];
		default:
			break;
	}

	
	[request send];	
}

#pragma mark -
#pragma mark HtmlParserDelegate

- (void)handleParseResults:(NSMutableArray*)results  {
	//NSLog(@"parsing text editor results");
	
	if(results) {
		//Only one result and a string.
		NSString *textAreaContent = [[results objectAtIndex:0] stringByUnescapingXMLElementEntities];
		[_messageController setBody:textAreaContent];
	} else {
		[UIAlertView simpleAlertWithTitle:@"Failed to Load Post" 
								  message:@"Attempted to load an existing post for"\
										  @"a reply or edit, but something went wrong."];
	}

	[_messageController updateLoadingStatusView:NO];
	[_messageController updateView];

}

- (void)parsingFailed:(NSError*)error{
	//Alert the user that loading the quote or existing post failed...
	[_messageController updateLoadingStatusView:NO];
}

#pragma mark -
#pragma mark LoginRequestDispatcherDelegate

- (void)loginAttemptSucceeded:(BOOL)requestWasSuccessful {
	[_messageController updateLoadingStatusView:NO];
	if(requestWasSuccessful && _contentUrl) {
		[self loadContentIntoEditor];	
	}
}

#pragma mark -
#pragma mark TTMessageControllerDelegate


- (void)composeController:(TTMessageController*)controller didSendFields:(NSArray*)fields {
	if(![MG_ACCOUNT isLoggedIn]) {
		[self triggerLoginRetryAlert];
	} else {
		NSString *title;
		NSString *body;
		
		//Cycle through the fields  to pull out there values.
		for (TTMessageField *field in fields) {
			if([field isKindOfClass:[TTMessageSubjectField class]]) {
				title = [(TTMessageSubjectField*)field text];
				
				//Validate the title length - not the best place for this.
				if(kMaxTitleCharacterLength < [title length]) {
					[UIAlertView simpleAlertWithTitle:@"Title too long" 
											  message:
					 [NSString stringWithFormat:@"Your title is too long, shorten it by %d characters.",
					  (title.length - kMaxTitleCharacterLength)]];
					
					[(MGMessageController*)controller undoSendCommand];					
					return;
				}
				
			} else if([field isKindOfClass:[TTMessageTextField class]]) {
				body = [(TTMessageTextField*)field text];
			}
		}
		
		//We're going to send it
		[self sendRequestWithTitle:title message:body];			
	}		
}

- (void)composeControllerDidCancel:(TTMessageController*)controller {
	[controller dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == [alertView cancelButtonIndex]) {
		//If they cancel, when do we want to force-close the message controller's view?
		//At the very least we want to clear a loader...
		[_messageController updateLoadingStatusView:NO];
		return;
	}
	
	NSString *command = [alertView buttonTitleAtIndex:buttonIndex];
	
	if([command isEqualToString:kRetryCommandName]) {
		LoginRequestDispatcher *loginner = [[[LoginRequestDispatcher alloc] initWithAccount:MG_ACCOUNT] autorelease];
		loginner.loginFailureAlertViewDelegate = self;
		loginner.shouldTriggerAlertViewOnSuccess = YES;
		[loginner attemptLogin];			
	} else if([command isEqualToString:kSettingsCommandName]) {
		UIViewController *modalViewController = [[MG_DELEGATE navigationController] modalViewController];
		if(modalViewController) { 			
			MGWelcomeScreen *welcomeScreen = [MGWelcomeScreen welcomeScreen];
			welcomeScreen.delegate = self;
			[modalViewController presentModalViewController:welcomeScreen animated:YES];		
		} else {
			[[MG_DELEGATE navigationController] presentModalViewController:[MGWelcomeScreen welcomeScreen] animated:YES];
		}
	}
	
	[_messageController undoSendCommand];
}

#pragma mark -
#pragma mark MGWelcomeScreenDelegate

/* If the welcome screen was (1) on top of the message controller and
	(2) was saved, we need to relogin, otherwise bail out */
- (void)welcomeScreen:(MGWelcomeScreen*)welcomeScreen wasSaved:(BOOL)saved {

	//Either way, dismiss the welcome screen on top
	if([_messageController modalViewController] == welcomeScreen) {
		[_messageController dismissModalViewControllerAnimated:YES];	
	}
	
	if(saved) {
		[_messageController attemptLoginWithDelegate:self];
	} else {
		//Kill the message controller too.
		[_messageController.parentViewController dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	NSLog(@"Error occurred during TTURLRequest.");
	
	[UIAlertView simpleAlertWithTitle:@"Error" message:[error localizedDescription]];
	
	//Don't dismiss the screen, just undo the send so they can cancel/retry.
	[_messageController undoSendCommand];
}

- (void)requestDidFinishLoad:(TTURLRequest*)aRequest {
	//NSLog(@"Request finished.");
	
	NSString *response = [[[NSString alloc] initWithData:[(TTURLDataResponse*) aRequest.response data] encoding:NSISOLatin1StringEncoding] autorelease];
	//NSLog(@"Got this response:%@",response);
	
	
	//This is a bad test.. sometimes response is nil...
	if(response) {
		if([response rangeOfString:@"value=\"Log in\""].location != NSNotFound) {
			//Reply failed!
			[self triggerLoginRetryAlert];
		} else {
			Account *account = [(MobileGAFAppDelegate*)[UIApplication sharedApplication].delegate account];
			account.isLoggedIn = YES;
			[_messageController undoSendCommand];
			[_delegate editorDidSubmit:self];					
		}		
	} else {
		NSLog(@"Submission response didn't parse into a string...");
		[_messageController undoSendCommand];
		[_delegate editorDidSubmit:self];		
	}
	
	

}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
	NSLog(@"Reply was cancelled!");
	[_delegate editorDidCancel:self];	
}



@end




