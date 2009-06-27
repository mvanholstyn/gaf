//
//  MobileGAFAppDelegate.m
//  MobileGAF
//
//  Created by Juice on 3/20/09.
//  Copyright Justin Searls 2009. All rights reserved.
//

#import "MobileGAFAppDelegate.h"
#import "RootViewController.h"
#import "UIWebViewFactory.h"
#import "LoginRequestDispatcher.h"
#import "Account.h"
#import "UIAlertViewAdditions.h"
#import "MGStyleSheet.h"
#import "MGToolbar.h"
#import "UINavigationBarTouchable.h"
#import "MGToolbar.h"
#import "ObjectiveResourceConfig.h"
#import <Three20/Three20.h>

@interface MobileGAFAppDelegate()

/** Configures the application based on the user's Settings.bundle settings. **/
- (void)setupUserConfiguration;
- (void)setupToolbar;
- (void)clearAllCaches;
- (void)setupObjectiveResource;

@end


@implementation MobileGAFAppDelegate

@synthesize account;
@synthesize shouldLoadPostImages;
@synthesize shouldLoadAvatarImages;
@synthesize shouldDelegateImagesToExternalService = _shouldDelegateImagesToExternalService;
@synthesize mgToolbar = _mgToolbar;
@synthesize navigationController;
@synthesize window;


#pragma mark -
#pragma mark MobileGAFAppDelegate

- (void)setupObjectiveResource {
	//Set the address of the rails site. The trailing slash is required
	[ObjectiveResourceConfig setSite:@"http://gaf.heroku.com/"];
	
	//Set the username and password to be used for the remote site
//	[ObjectiveResourceConfig setUser:@"remoteResourceUserName"];
//	[ObjectiveResourceConfig setPassword:@"remoteResourcePassword"];
	
	//Set ObjectiveResource to use either XML or JSON
	[ObjectiveResourceConfig setResponseType:JSONResponse];
}

- (void)setupUserConfiguration {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	/* Set defaults, since apparently iPhone sucks at initializing the DB itself */
	NSDictionary *appDefaults = [[[NSDictionary alloc] initWithObjectsAndKeys:
								  kCFBooleanTrue, @"show_sticky_threads",
								  kCFBooleanTrue, @"show_user_tags",
								  kCFBooleanTrue, @"image_avatar",
								  kCFBooleanTrue, @"image_post",
								  kCFBooleanTrue, @"image_cloud_processing",
								  kCFBooleanFalse, @"clear_cache",
								  [NSNumber numberWithInt:1], @"scroll_to_bottom",
								  nil] autorelease];
	[settings registerDefaults:appDefaults]; 
	
	//First things first, if cache has to be reset, do it ASAP to avoid future crashes.
	if([settings boolForKey:@"clear_cache"]) {
		[self clearAllCaches];
		[settings setBool:NO forKey:@"clear_cache"];
	}
	
	/* Load the contents up. */
	[self setShouldDelegateImagesToExternalService:[settings boolForKey:@"image_cloud_processing"]];
	[self setShouldLoadAvatarImages:[settings boolForKey:@"image_avatar"]];
	[self setShouldLoadPostImages:[settings boolForKey:@"image_post"]];	
	[[TTURLRequestQueue mainQueue] setMaxContentLength:(1000 * [settings integerForKey:@"image_size_max"])];	
	
	self.account = [[[Account alloc] init] autorelease];
	[self.account setName:[settings stringForKey:@"account_name"]];
	[self.account setPassword:[settings stringForKey:@"account_password"]];
	
}

- (void)setupToolbar {
	_mgToolbar = [[MGToolbar alloc] initWithView:navigationController.view];
	_mgToolbar.hidden = NO;
}

- (void)clearAllCaches {
	[[TTURLCache sharedCache] removeAll:YES];
}

#pragma mark -
#pragma mark Application lifecycle


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
		NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
		//[UIAlertView debugAlertWithMessage:@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!"];
	}	

	//load user conf
	[self setupUserConfiguration];
	
	//Set our style sheet
	[TTStyleSheet setGlobalStyleSheet:[[[MGStyleSheet alloc] init] autorelease]];	
	
	[self setupObjectiveResource];
	
	//Set our custom touchable navbar.
	[self.navigationController setNavigationBar:[[[UINavigationBarTouchable alloc] init] autorelease]];

	[self setupToolbar];
//	
//	#ifdef __IPHONE_3_0
////	navigationController.toolbarHidden = YES;
//	#else
//
//	#endif
	

	[window addSubview:navigationController.view];		
	[navigationController.view addSubview:_mgToolbar];
	[window makeKeyAndVisible];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
	//Dump current status.
	
	
	/* //2.0 core data setup
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
	 */
}



#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[_mgToolbar release];
	
	/* // Core Data setup for 2.0
	 [managedObjectContext release];
	 [managedObjectModel release];
	 [persistentStoreCoordinator release];
	 */
	
	[account release];
	
	[window release];
	[super dealloc];
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
//- (IBAction)saveAction:(id)sender {
	/* // Core Data setup for 2.0
	 NSError *error;
	 if (![[self managedObjectContext] save:&error]) {
	 // Handle error
	 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	 exit(-1);  // Fail
	 }
	 */
//}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
/* // Core Data setup for 2.0
 - (NSManagedObjectContext *) managedObjectContext {
 
 if (managedObjectContext != nil) {
 return managedObjectContext;
 }
 
 NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
 if (coordinator != nil) {
 managedObjectContext = [[NSManagedObjectContext alloc] init];
 [managedObjectContext setPersistentStoreCoordinator: coordinator];
 }
 return managedObjectContext;
 }
 */

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
/* // Core Data setup for 2.0
 - (NSManagedObjectModel *)managedObjectModel {
 
 if (managedObjectModel != nil) {
 return managedObjectModel;
 }
 managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
 return managedObjectModel;
 }
 */

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
/* // Core Data setup for 2.0
 - (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
 
 if (persistentStoreCoordinator != nil) {
 return persistentStoreCoordinator;
 }
 
 NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"MobileGAF.sqlite"]];
 
 NSError *error;
 persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
 if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
 // Handle error
 }    
 
 return persistentStoreCoordinator;
 }
 */

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
/* // Core Data setup for 2.0
 - (NSString *)applicationDocumentsDirectory {
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
 return basePath;
 }
 */

@end





