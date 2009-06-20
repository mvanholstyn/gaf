//
//  MGStyleSheet.h
//  MobileGAF
//
//  Created by Juice on 4/19/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "MobileGAFAppDelegate.h"

#define GAFORANGE [UIColor colorWithRed:0.9541 green:0.5098 blue:0.0980 alpha:1.0]
#define WINDOW_WIDTH ((UIDeviceOrientationIsLandscape(TTDeviceOrientation())) ? [MG_DELEGATE window].bounds.size.height : [MG_DELEGATE window].bounds.size.width)
#define WINDOW_HEIGHT ((UIDeviceOrientationIsLandscape(TTDeviceOrientation())) ? [MG_DELEGATE window].bounds.size.width : [MG_DELEGATE window].bounds.size.height)
#define SHORTEST_WINDOW_EDGE_LENGTH ([MG_DELEGATE window].bounds.size.height > [MG_DELEGATE window].bounds.size.width ? [MG_DELEGATE window].bounds.size.width : [MG_DELEGATE window].bounds.size.height)

@interface MGStyleSheet : TTDefaultStyleSheet 

@property(nonatomic,readonly) NSUInteger authorHeaderHeight;

@property(nonatomic,readonly) CGSize avatarImageSize;
@property(nonatomic,readonly) CGSize quoteImageSize;

/** Controls the toolbar at the bottom of the screen **/
@property(nonatomic,readonly) NSUInteger uiToolbarHeight;
@property(nonatomic,readonly) CGFloat uiToolbarAlpha;

@property(nonatomic,readonly) UIColor *userDefaultTintColor;
@property(nonatomic,readonly) UIColor *navigationBarTintColor;

@end
