//
//  MGMessageController.m
//  MobileGAF
//
//  Created by Juice on 5/14/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "MGMessageController.h"
#import "TextEditorParser.h"
#import "LoginRequestDispatcher.h"

@implementation MGMessageController

@synthesize waitingToDisplayStatusMessage = _waitingToDisplayStatusMessage,
			viewHasAppeared = _viewHasAppeared;

#pragma mark -
#pragma mark NSObject

-(void) dealloc {
	[_waitingToDisplayStatusMessage release];
	[super dealloc];
}

#pragma mark -
#pragma mark MGMessageController

- (id)init {
	return [self initWithRequiredTitle:NO];
}

- (id)initWithRequiredTitle:(BOOL)required {
	if(self = [super init]) {
		
		NSMutableArray *subsetOfFields = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
		
		//We're going for a subset of the parent class's fields, since it's not mutable.. eww
		for (int i = 0; i < _fields.count; ++i) {
			TTMessageField* field = [_fields objectAtIndex:i];			
			
			//We don't want the recipient field at all.
			if (![field isKindOfClass:[TTMessageRecipientField class]]) {
				//field.required = NO;
				
				//And we want to rename the subject field to Title.				
				if ([field isKindOfClass:[TTMessageSubjectField class]]) {
					field.required = required;					
					field.title = @"Title";
				}
				[subsetOfFields addObject:field];
			}
		}
		
		self.fields = subsetOfFields;
	}
	return self;	
}


- (void)undoSendCommand{
	if(self.viewState == TTViewLoading) {
		[self invalidateViewState:TTViewDataLoaded];
		[self updateSendCommand]; //Hope Joe never renames this.		
	}
}

- (void)updateLoadingStatusView:(BOOL)makeVisible message:(NSString*)message {	
	if (makeVisible) {
		if(_viewHasAppeared) {
			CGRect frame = CGRectMake(0, _navigationBar.bottom, self.view.width, _scrollView.height);
			TTActivityLabel* label = [[[TTActivityLabel alloc] initWithFrame:frame
																	   style:TTActivityLabelStyleWhiteBox] autorelease];
			label.text = TTLocalizedString(message, @"");
			label.centeredToScreen = NO;
			[self.view addSubview:label];
			
			[_statusView release];
			_statusView = [label retain];
		} else {
			//Defer until viewWillLoad
			_waitingToDisplayStatusMessage = message;
		}
		
	} else {
		[_statusView removeFromSuperview];
		[_statusView release];
		_statusView = nil;
	}
	
}

- (void)updateLoadingStatusView:(BOOL)makeVisible {
	[self updateLoadingStatusView:makeVisible message:@"Loading Post..."];
}

- (void)attemptLoginWithDelegate:(id<LoginRequestDispatcherDelegate,UIAlertViewDelegate>)delegate {
	//If a person actually has access and is set up, this works awesomely. :/
	
	[self updateLoadingStatusView:YES message:@"Logging in..."];
	LoginRequestDispatcher *dispatcher = [[[LoginRequestDispatcher alloc] initWithAccount:MG_ACCOUNT] autorelease];
	dispatcher.loginFailureAlertViewDelegate = delegate;
	[dispatcher setDelegate:delegate];
	[dispatcher attemptLogin];	
}

#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	_viewHasAppeared = YES;	//Yeah yeah, bad name.
	if(_waitingToDisplayStatusMessage) {
		[self updateLoadingStatusView:YES message:_waitingToDisplayStatusMessage];
		_waitingToDisplayStatusMessage = nil;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end




