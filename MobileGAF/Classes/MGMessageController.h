//
//  MGMessageController.h
//  MobileGAF
//
//  Created by Juice on 5/14/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "LoginRequestDispatcher.h"

/** Goal here is to rip out anything requiring recipients. **/
@interface MGMessageController : TTMessageController {
	NSString *_waitingToDisplayStatusMessage;
	BOOL _viewHasAppeared;
}

@property (nonatomic, retain) NSString *waitingToDisplayStatusMessage;
@property BOOL viewHasAppeared;

- (id)init;
/* Designated initializer */
- (id)initWithRequiredTitle:(BOOL)required;

- (void)undoSendCommand;
- (void)updateLoadingStatusView:(BOOL)makeVisible message:(NSString*)message;
- (void)updateLoadingStatusView:(BOOL)makeVisible;

- (void)attemptLoginWithDelegate:(id<LoginRequestDispatcherDelegate,UIAlertViewDelegate>)delegate;

@end




