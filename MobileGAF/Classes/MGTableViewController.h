//
//  MGTableViewController.h
//  MobileGAF
//
//  Created by Juice on 4/19/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "HtmlParser.h"
#import "UINavigationBarTouchable.h"
#import "MobileGAFAppDelegate.h"
#import "MGToolbar.h"
#import "EditorController.h"


@interface MGTableViewController : TTTableViewController <TTMessageControllerDelegate,EditorControllerDelegate,HtmlParserDelegate, MGButtonActionResponder, UINavigationBarTouchableDelegate> {
	EditorController *_editorController;
}

@property (nonatomic, retain) EditorController *editorController;

- (void)refresh;
- (void)setAdjustingFontOnNavigationItemWithTitle:(NSString*)title;

//For after reply/edit/create submission
- (void)refreshAfterSubmitAsNecessary;
- (NSDictionary*)submissionParamsForEdit;
- (NSDictionary*)submissionParamsForCreateOrReply;

@end

