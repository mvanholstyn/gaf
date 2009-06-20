//
//  NSObjectAdditions.m
//  MobileGAF
//
//  Created by Juice on 4/18/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "UIAlertViewAdditions.h"


@implementation UIAlertView (MGAlertViewCategory)

+ (void)debugAlertWithMessage:(NSString*)message {
	[[[[UIAlertView alloc] initWithTitle:@"Debug" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];	
}

+ (void)simpleAlertWithTitle:(NSString*)title message:(NSString*)message {
	[[[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];		
}

+ (void)choiceAlertWithTitle:(NSString*)title message:(NSString*)message buttonName:(NSString*)buttonName delegate:(id<UIAlertViewDelegate>)delegate {
	[[[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:buttonName,nil] autorelease] show];			
}

+ (void)choiceAlertWithTitle:(NSString*)title message:(NSString*)message buttonName:(NSString*)buttonName nextButtonName:(NSString*)nextButtonName delegate:(id<UIAlertViewDelegate>)delegate {
	[[[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:buttonName,nextButtonName,nil] autorelease] show];			
}


@end
