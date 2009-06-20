//
//  UINavigationBarTouchable.h
//  MobileGAF
//
//  Created by Juice on 4/19/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UINavigationBarTouchableDelegate <NSObject>

- (void)navigationBarWasTouched;

@end


@interface UINavigationBarTouchable : UINavigationBar {
	id<UINavigationBarTouchableDelegate> touchDelegate;
	NSUInteger tapsRequiredToScrollToBottom;
}

@property NSUInteger tapsRequiredToScrollToBottom;
@property (nonatomic, retain) id<UINavigationBarTouchableDelegate> touchDelegate;

@end

