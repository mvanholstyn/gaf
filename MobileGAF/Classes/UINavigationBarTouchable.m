//
//  UINavigationBarTouchable.m
//  MobileGAF
//
//  Created by Juice on 4/19/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "UINavigationBarTouchable.h"


@implementation UINavigationBarTouchable

@synthesize tapsRequiredToScrollToBottom;
@synthesize touchDelegate;

#pragma mark -
#pragma mark NSObject

- (id)init {
	if(self = [super init]) {
		tapsRequiredToScrollToBottom = [[NSUserDefaults standardUserDefaults] integerForKey:@"scroll_to_bottom"];

		//If it's 0 then the default didn't stick.
		if(tapsRequiredToScrollToBottom == 0) {
			tapsRequiredToScrollToBottom = 1;
		}
	}
	return self;
}

#pragma mark -
#pragma mark UINavigationBarTouchable

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSString *originalNavItemName = self.topItem.title;

	//See if the touch changes the nav item:
	[super touchesEnded:touches withEvent:event];
	
	//If the frame didn't change and there are taps to be had, rock on.
	if([self.topItem.title isEqualToString:originalNavItemName] 
	   && tapsRequiredToScrollToBottom > 0) {
		if([[touches anyObject] tapCount] == tapsRequiredToScrollToBottom 
		   && [touchDelegate respondsToSelector:@selector(navigationBarWasTouched)]) {
			[touchDelegate navigationBarWasTouched];		
		}		
	}

}

@end

