//
//  MobileGAFAppDelegate.h
//  MobileGAF
//
//  Created by Juice on 3/20/09.
//  Copyright Justin Searls 2009. All rights reserved.
//

#define kNeoGafBaseUrl @"http://www.neogaf.com/forum/"
#define kImageProcessUrl @"http://gafcrawler.appspot.com/imanip"
#define MG_DELEGATE (MobileGAFAppDelegate*)[UIApplication sharedApplication].delegate
#define MG_TOOLBAR [(MobileGAFAppDelegate*)[UIApplication sharedApplication].delegate mgToolbar]
#define MG_ACCOUNT [(MobileGAFAppDelegate*)[UIApplication sharedApplication].delegate account]

#define kRetryCommandName @"Retry"
#define kSettingsCommandName @"Settings"

@class MGToolbar, Account;

@interface MobileGAFAppDelegate : NSObject <UIApplicationDelegate> {

	/*
    NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	 */

	IBOutlet MGToolbar *_mgToolbar;
	IBOutlet UINavigationController *navigationController;	
    IBOutlet UIWindow *window;
	
	BOOL shouldLoadAvatarImages;
	BOOL shouldLoadPostImages;
	BOOL _shouldDelegateImagesToExternalService;
	
	Account *account;
}

@property (nonatomic, retain) Account *account;
@property BOOL shouldLoadPostImages;
@property BOOL shouldLoadAvatarImages;
@property BOOL shouldDelegateImagesToExternalService;
@property (nonatomic, retain) MGToolbar *mgToolbar;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

//- (IBAction)saveAction:sender;

//These will be used in V2 of the app...
/*
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
*/
 


@end





