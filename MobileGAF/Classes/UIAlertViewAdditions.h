//
//  NSObjectAdditions.h
//  MobileGAF
//
//  Created by Juice on 4/18/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIAlertView (MGAlertViewCategory)

+ (void)debugAlertWithMessage:(NSString*)message;
+ (void)simpleAlertWithTitle:(NSString*)title message:(NSString*)message;
+ (void)choiceAlertWithTitle:(NSString*)title message:(NSString*)message buttonName:(NSString*)buttonName delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)choiceAlertWithTitle:(NSString*)title message:(NSString*)message buttonName:(NSString*)buttonName nextButtonName:(NSString*)nextButtonName delegate:(id<UIAlertViewDelegate>)delegate;

@end
