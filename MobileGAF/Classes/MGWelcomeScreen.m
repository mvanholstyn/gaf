//
//  MGWelcomeScreen.m
//  MobileGAF
//
//  Created by Juice on 6/8/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "MGWelcomeScreen.h"
#import "MobileGAFAppDelegate.h"
#import "MGStyleSheet.h"
#import "Account.h"

@interface MGWelcomeScreen()

- (void)cancel;
- (void)save;

@end


@implementation MGWelcomeScreen

@synthesize delegate = _delegate,
			responsibleForReleasingSelf = _responsibleForReleasingSelf;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[_delegate release];
	[_navigationBar release];
	[_accountNameField release];
	[_passwordField release];
	[super dealloc];
}

#pragma mark -
#pragma mark MGWelcomeScreen

+ (MGWelcomeScreen*)welcomeScreen {
	MGWelcomeScreen *welcomeScreen = [[MGWelcomeScreen alloc] init];
	[welcomeScreen setResponsibleForReleasingSelf:YES];
	return welcomeScreen;
}

- (void)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	
	if([_delegate respondsToSelector:@selector(welcomeScreen:wasSaved:)]) {
		NSLog(@"Telling delegate I wasn't saved.");
		[_delegate welcomeScreen:self wasSaved:NO];
	} else {
		NSLog(@"no delegate to report to..");		
	}
	if(_responsibleForReleasingSelf) {
		[self autorelease];
	}
}
- (void)save {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

	[settings setValue:_accountNameField.text forKey:@"account_name"];
	[settings setValue:_passwordField.text forKey:@"account_password"];
	
	//Update account object too.
	Account *account = MG_ACCOUNT;
	[account setName:_accountNameField.text];
	[account setPassword:_passwordField.text];
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	
	if([_delegate respondsToSelector:@selector(welcomeScreen:wasSaved:)]) {
		NSLog(@"Telling delegate I wasn't saved.");
		[_delegate welcomeScreen:self wasSaved:YES];
	} else {
		NSLog(@"no delegate..");
	}
	if(_responsibleForReleasingSelf) {
		[self autorelease];
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	
	self.autoresizesForKeyboard = YES;
	self.variableHeightRows = YES;
	
	self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, 
																	self.view.bounds.origin.y+TOOLBAR_HEIGHT, 
																	self.view.bounds.size.width, 
																	self.view.bounds.size.height-TOOLBAR_HEIGHT)
												   style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.tableView];

	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																			  style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save"
																			   style:UIBarButtonItemStyleDone target:self action:@selector(save)] autorelease];
	self.navigationItem.title = @"Settings";
	_navigationBar = [[UINavigationBar alloc] initWithFrame:
					  CGRectMake(0, 0, WINDOW_WIDTH, TOOLBAR_HEIGHT)];
	_navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	[_navigationBar pushNavigationItem:self.navigationItem animated:NO];
	[self.view addSubview:_navigationBar];
}

#pragma mark -
#pragma mark TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	_accountNameField = [[TTTextFieldTableField alloc] initWithTitle:@"Name" text:[settings valueForKey:@"account_name"]];										
	_accountNameField.delegate = self;
	
	_passwordField = [[TTTextFieldTableField alloc] initWithTitle:@"Password" text:[settings valueForKey:@"account_password"]];
	_passwordField.delegate = self;
	_passwordField.secureTextEntry = YES;
	_passwordField.delegate = self;
	
	return [TTSectionedDataSource dataSourceWithObjects:
			@"",
			[[[TTIconTableField alloc] initWithText:@"Welcome to MobileGAF!" url:nil image:@"bundle://Icon.png"] autorelease],
			[[[TTSummaryTableField alloc] initWithText:@"Have an account? Enter it here!"] autorelease],
			@"",
			_accountNameField,
			_passwordField,
			@"",
			[[[TTSummaryTableField alloc] initWithText:@"Want more options? Check out MobileGAF in the Settings app."] autorelease],			
			nil];
}

@end

