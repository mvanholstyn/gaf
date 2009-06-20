//
//  MGTableViewController.m
//  MobileGAF
//
//  Created by Juice on 4/19/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "MGTableViewController.h"
#import "MobileGAFAppDelegate.h"
#import "Account.h"
#import "LoginRequestDispatcher.h"
#import "MGMessageController.h"
#import "UIAlertViewAdditions.h"
#import "ForumViewController.h"
#import <Three20/Three20.h>
#import "EditorController.h"
#import "MGWelcomeScreen.h"

@interface MGTableViewController() 

- (void)setUpToolbar:(MGToolbar*)toolbar;
- (void)handleFirstRun;
@end


@implementation MGTableViewController

@synthesize editorController = _editorController;

#pragma mark -
#pragma mark MGTableViewController


- (void)refresh {
	//default impl	
}

- (void)refreshAfterSubmitAsNecessary {
	//non-impl
}

- (NSDictionary*)submissionParamsForEdit {
	return nil;
}
- (NSDictionary*)submissionParamsForCreateOrReply {
	return nil;
}

- (void)setUpToolbar:(MGToolbar*)toolbar {
}

- (void)setAdjustingFontOnNavigationItemWithTitle:(NSString*)title {
	self.title = title;
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 30)] autorelease];
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	label.backgroundColor = [UIColor clearColor];
	
	label.text = title;
	label.font = [UIFont boldSystemFontOfSize:25];
	label.minimumFontSize = 12;
	label.textAlignment = UITextAlignmentCenter;
	
	label.textColor = [UIColor whiteColor];		
	label.shadowColor = [UIColor darkGrayColor];
	label.shadowOffset = CGSizeMake(0, -1);
	
	label.adjustsFontSizeToFitWidth = YES;		
	[self.navigationItem setTitleView:label];
}

- (void)handleFirstRun {	
	//If this is the first time the app is launched, we want to show welcome screen.
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"hasBeenRun"]) {
		[self configureAction];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"hasBeenRun"];
	}	
}

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[_editorController release];
	[super dealloc];
}

#pragma mark -
#pragma mark HtmlParserDelegate

- (void)handleParseResults:(NSMutableArray*)results {
	[self invalidateViewState:TTViewDataLoaded];

	MGToolbar *toolbar = MG_TOOLBAR;
	if(toolbar) {
		UIBarButtonItem *refreshButton = [toolbar itemWithTag:kRefreshTag];
		[refreshButton setEnabled:YES];		
	}	
}

- (void)parsingFailed:(NSError*)error {
	[self setContentError:error];
	[self invalidateViewState:TTViewDataLoadedError];
	UIBarButtonItem *refreshButton = [MG_TOOLBAR 
									  itemWithTag:kRefreshTag];
	[refreshButton setEnabled:YES];
}


#pragma mark -
#pragma mark UINavigationBarTouchableDelegate

- (void)navigationBarWasTouched {
	//NSLog(@"Scrolling to bottom");
	
	
	TTListDataSource *ds = self.dataSource;	
	if(ds && [ds items] && [[ds items] count] > 0) {
		NSIndexPath *ip = [NSIndexPath indexPathForRow:[ds items].count-1 inSection:0];
		
		[self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		[self.tableView flashScrollIndicators];		
	}

}

#pragma mark -
#pragma mark TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {	
	NSMutableArray *fields = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];

	/** Set up a final row for the padding row needed to handle scrolling w/ the bottom toolbar on top **/
	TTStyledText *styledText = [TTStyledText textFromXHTML:@"<div class=\"uiToolbarPaddingStyle\"/>"];
	TTStyledTextTableField *field = [[[TTStyledTextTableField alloc] initWithStyledText:styledText] autorelease];
	[fields addObject:field];
	 
	TTListDataSource *ds = [[[TTListDataSource alloc] initWithItems:fields] autorelease];
	return ds;

}

- (UIImage*)imageForError:(NSError*)error {
	return [UIImage imageNamed:@"Three20.bundle/images/error.png"];
}

- (NSString*)subtitleForError:(NSError*)error {
	return TTLocalizedString([error localizedDescription], @"");
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	//NSLog(@"Loading Forum View");
	[super loadView];
	
	//Set up TT features	
	self.navigationBarTintColor = [TTSTYLESHEET navigationBarTintColor];
	
	self.autoresizesForKeyboard = YES;
	self.variableHeightRows = YES;
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds
												   style:UITableViewStylePlain] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.tableView];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	//Set up toolbar delegate
	[MG_TOOLBAR setHidden:NO];	
	[MG_TOOLBAR setToolbarItemsResponder:self];
	
	//We will respond to nav bar touches.
	UINavigationBarTouchable *navBar = (UINavigationBarTouchable*) [MG_DELEGATE navigationController].navigationBar;
	[navBar setTouchDelegate:self];
	
	[self handleFirstRun];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	[TTSTYLESHEET freeMemory]; //Need to recalculate the styles
	[self updateView];
}

#pragma mark -
#pragma mark MGButtonActionResponder

- (void)refreshAction {
	[self refresh];
}

- (void)bookmarkAction {
	NSLog(@"Bookmark Button Pushed");	
}

- (void)searchAction {
	NSLog(@"Search Button Pushed");	
}

- (void)configureAction {
	//Present welcome screen.
	[MG_TOOLBAR setHidden:YES];
	[[MG_DELEGATE navigationController] presentModalViewController:[[[MGWelcomeScreen alloc] init] autorelease] animated:YES];
}

- (void)replyAction {
	_editorController = [[EditorController alloc] initWithType:EditorControllerTypeReply 
													  delegate:self 
													 submitUrl:[kNeoGafBaseUrl stringByAppendingString:@"newreply.php"]];
	[[MG_DELEGATE navigationController] presentModalViewController:[_editorController openEditorWithRequiredTitle:NO] animated:YES];
}

- (void)createThreadAction {
	_editorController = [[EditorController alloc] initWithType:EditorControllerTypeThread 
													  delegate:self 
													 submitUrl:[kNeoGafBaseUrl stringByAppendingString:@"newthread.php"]];
	[[MG_DELEGATE navigationController] presentModalViewController:[_editorController openEditorWithRequiredTitle:YES] animated:YES];
}

- (void)quoteReplyActionForURL:(NSString*)url {		
	_editorController = [[EditorController alloc] initWithType:EditorControllerTypeReplyWithQuote
													  delegate:self 
													 submitUrl:[kNeoGafBaseUrl stringByAppendingString:@"newreply.php"]
													contentUrl:url];
	[[MG_DELEGATE navigationController] presentModalViewController:[_editorController openEditorWithRequiredTitle:NO] animated:YES];
}

- (void)editReplyActionForURL:(NSString*)url {
	_editorController = [[EditorController alloc] initWithType:EditorControllerTypeEdit
													  delegate:self 
													 submitUrl:[kNeoGafBaseUrl stringByAppendingString:@"editpost.php"]
													contentUrl:url];
	[[MG_DELEGATE navigationController] presentModalViewController:[_editorController openEditorWithRequiredTitle:NO] animated:YES];
}

#pragma mark -
#pragma mark EditorControllerDelegate

- (NSDictionary*)submissionParamsForEditor:(EditorController*)editor {
	switch (editor.type) {
		case EditorControllerTypeEdit:
			return [self submissionParamsForEdit];
			break;
		default:
			return [self submissionParamsForCreateOrReply];
			break;
	}
}

- (void)editorDidSubmit:(EditorController*)editor {
	[self.modalViewController dismissModalViewControllerAnimated:YES];	
	[self refreshAfterSubmitAsNecessary];	
	[_editorController release];
}
- (void)editorDidCancel:(EditorController*)editor {
	[self.modalViewController dismissModalViewControllerAnimated:YES];	
	[_editorController release];
}

@end

