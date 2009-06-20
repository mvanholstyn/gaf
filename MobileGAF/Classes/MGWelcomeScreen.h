//
//  MGWelcomeScreen.h
//  MobileGAF
//
//  Created by Juice on 6/8/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

#define kAccountNameLabel @"Name"
#define kAccountPasswordLabel @"Password"

@class MGWelcomeScreen;

@protocol MGWelcomeScreenDelegate <NSObject>

@optional
- (void)welcomeScreen:(MGWelcomeScreen*)welcomeScreen wasSaved:(BOOL)saved;

@end



@interface MGWelcomeScreen : TTTableViewController <UITextFieldDelegate> {
	UINavigationBar* _navigationBar;
	
	TTTextFieldTableField *_accountNameField;
	TTTextFieldTableField *_passwordField;
	
	BOOL _responsibleForReleasingSelf;

	id<MGWelcomeScreenDelegate> _delegate;
}

@property (nonatomic,retain) id<MGWelcomeScreenDelegate> delegate;

@property BOOL responsibleForReleasingSelf;

+ (MGWelcomeScreen*)welcomeScreen;

@end

