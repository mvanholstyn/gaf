//
//  MGStyleSheet.m
//  MobileGAF
//
//  Created by Juice on 4/19/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "MGStyleSheet.h"
#import <Three20/Three20.h>
#import "MobileGAFAppDelegate.h"

@implementation MGStyleSheet

#pragma mark -
#pragma mark Styles

/* Config View */


- (TTStyle*)embossedButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
											   color2:RGBCOLOR(216, 221, 231) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:TTSTYLEVAR(linkTextColor)
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(225, 225, 225)
											   color2:RGBCOLOR(196, 201, 221) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	} else {
		return nil;
	}
}

/* Forum View */

- (TTStyle*)threadTitle {
	return 
	[TTBoxStyle styleWithMargin:UIEdgeInsetsZero padding:UIEdgeInsetsZero next:
	 [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13] next:nil
	  ]];
}

- (TTStyle*)threadSubtext {
	return 
	[TTBoxStyle styleWithMargin:UIEdgeInsetsZero padding:UIEdgeInsetsMake(0, 1, 0, 1) 
						   minSize:CGSizeMake(0, 15) position:TTPositionStatic 
						   next:nil];
}

- (TTStyle*)threadSubtextFont {
	
	TTTextStyle *textStyle = [TTTextStyle styleWithFont:[UIFont systemFontOfSize:11] 
												  color:[UIColor grayColor] 
										minimumFontSize:7 shadowColor:[UIColor blackColor] 
										   shadowOffset:CGSizeMake(1,1) next:nil];
	textStyle.verticalAlignment = UIControlContentVerticalAlignmentCenter;

	return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0, 3, 0, 2) padding:UIEdgeInsetsMake(0, 0, -3, 0) next:textStyle];
}

/* For the bottom of the last sticky */
- (TTStyle*)horizontalRule {
	return
	[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(10,-10,-10,-10) padding:UIEdgeInsetsMake(0, 0, 0, 0) next:
	 [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithRed:0.675 green:0.675 blue:0.675 alpha:1.0] 
										  color2:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0] next:
	  [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13] color:[UIColor whiteColor] next:nil	 
	 ]]];
}

/* Thread View */

/* Header with author info */
- (TTStyle*)authorarea {
	return 	
	[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(-10,-10,0,-10) padding:UIEdgeInsetsZero
						minSize:CGSizeMake(0, self.authorHeaderHeight) position:TTPositionStatic next:
	[TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithRed:0.675 green:0.675 blue:0.675 alpha:1.0] 
										color2:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0] next:nil]];
}

/* User name (white) */
- (TTStyle*)authortext {
	TTTextStyle *textStyle = [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:18]  color:[UIColor whiteColor]
										minimumFontSize:15 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
										   shadowOffset:CGSizeMake(0, -3) next:nil];	
	TTBoxStyle *box = [TTBoxStyle styleWithFloats:TTPositionStatic next:nil];
	box.margin = UIEdgeInsetsMake(0, 5, 0, 0);
	box.minSize = CGSizeMake(WINDOW_WIDTH-self.avatarImageSize.width-self.quoteImageSize.width, 0);
	box.padding = UIEdgeInsetsMake(self.avatarImageSize.height - textStyle.font.pointSize - 1, 0, 0, 0);
	box.next = textStyle;
	return box;
}

/* User name (red) */
/* relies on authortext! */
- (TTStyle*)moderatortext {
	TTBoxStyle *authorText = (TTBoxStyle*)[self authortext];
	TTTextStyle *textStyle = (TTTextStyle*)authorText.next;
	textStyle.color = [UIColor colorWithRed:.686 green:0 blue:0 alpha:1];
	return authorText;
}

/* relies on authortext! */
- (TTStyle*)authorSubArea {
	TTBoxStyle *authorTextHeaderBoxStyle = (TTBoxStyle*)[self authortext];
	TTBoxStyle *boxStyle = [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(-1 * authorTextHeaderBoxStyle.padding.top+2, 0, 0, 0)
											   padding:UIEdgeInsetsMake(0, self.avatarImageSize.width+5, 0, 0) next:
	[TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13]  color:[UIColor whiteColor]
															   minimumFontSize:13 shadowColor:[UIColor whiteColor]
																  shadowOffset:CGSizeZero next:nil]];	
	return boxStyle;
}

/* Custom link for dark backgrounds. */
- (TTStyle*)authorTextLink:(UIControlState)state {
	
	UIColor *lightBlueColor = [UIColor colorWithRed:.824 green:.851 blue:1 alpha:1];
	
	if (state == UIControlStateHighlighted) {
		return
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(-3, -4, -3, -4) next:
		 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4.5] next:
		  [TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0.75 alpha:1] next:
		   [TTInsetStyle styleWithInset:UIEdgeInsetsMake(3, 4, 3, 4) next:
			[TTTextStyle styleWithColor:lightBlueColor next:nil]]]]];
	} else {
		return
		[TTTextStyle styleWithColor:lightBlueColor next:nil];
	}
}

//Just draws a little button. Not using it ATM.
- (TTStyle*)headerButton {
	return 
	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -5, -4, -6) next:
	  [TTShadowStyle styleWithColor:[UIColor darkGrayColor] blur:2 offset:CGSizeMake(1,1) next:
	   [TTReflectiveFillStyle styleWithColor:[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1] next:
		[TTSolidBorderStyle styleWithColor:[UIColor whiteColor] width:1 next:
		 [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:16] color:[UIColor colorWithRed:.2 green:.2 blue:.25 alpha:.9] textAlignment:UITextAlignmentRight next:nil
		  ]]]]]];
}

/* row appears beneath the user header if there's a title on the post. */
- (TTStyle*)postTitleArea {
	return 
	[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0,-10,0,-10) padding:UIEdgeInsetsMake(1, 2, 0, 1) next:	
	[TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0] 
										color2:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] next:
	[TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:14]  color:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0]
				minimumFontSize:12 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
				   shadowOffset:CGSizeMake(-1, -3) next:nil]]];	
}

/* Outermost div of a post. Just needs padding/margin */
- (TTStyle*)postarea {
	return 
	[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(-12, -5, -12, -5) padding:UIEdgeInsetsZero next:nil];
}

/*"Originally Posted by.." header of a quoted text*/
- (TTStyle*)quoteheader {
	return
	[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(-20, 0, -4, 0) padding:UIEdgeInsetsZero next:
	 [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12]  color:[UIColor blackColor]
				minimumFontSize:10 shadowColor:[UIColor whiteColor]
				   shadowOffset:CGSizeMake(0, 0) next:nil]];
	
}

/*Quoted text*/
- (TTStyle*)quotearea {
	return 
	 [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(-13, 3, 3, 3) padding:UIEdgeInsetsMake(3,5,3,5) next:
    [TTSolidFillStyle styleWithColor:[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0] next:
	  [TTSolidBorderStyle styleWithColor:[UIColor blackColor] width:1 next:nil]]];
}


- (TTStyle*)ignorePostArea {
	return 	
	[TTBoxStyle styleWithMargin:UIEdgeInsetsMake(-10,-10,-10,-10) padding:UIEdgeInsetsMake(0, 10, 0, 0)
						minSize:CGSizeMake(0, self.authorHeaderHeight) position:TTPositionStatic next:
	 [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithRed:0.975 green:0.975 blue:0.975 alpha:1.0] 
										 color2:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0] next:nil]];
}

- (TTStyle*)spoiler:(UIControlState)state {
	if (state == UIControlStateHighlighted) {
		return
		[TTSolidFillStyle styleWithColor:[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.0] next:
		 [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(3, 3, 3, 3) padding:UIEdgeInsetsMake(3,3,3,3) next:nil]];
	} else {
		return 
		[TTSolidFillStyle styleWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0] next:
		 [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(3, 3, 3, 3) padding:UIEdgeInsetsMake(0,0,0,0) next:nil]];
	}
}

/* Red text. Rarely used. */
- (TTStyle*)highlight {
	return
	[TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13]  color:[UIColor redColor]
			   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:1 alpha:0.9]
				  shadowOffset:CGSizeMake(0, -1) next:nil];
	
}

/* Defines div size */
- (TTStyle*)uiToolbarPaddingStyle {
	TTBoxStyle *toolbarPadding = [TTBoxStyle styleWithPadding:UIEdgeInsetsZero next:nil];
	toolbarPadding.minSize = CGSizeMake(0, self.uiToolbarHeight/2);
	return toolbarPadding;
}

#pragma mark -
#pragma mark Properties

- (UIColor*)userDefaultTintColor {
	NSString *colorDesc = [[NSUserDefaults standardUserDefaults] stringForKey:@"toolbar_color"];
	if([colorDesc isEqualToString:@"orange"]) {
		return GAFORANGE;
	} else if([colorDesc isEqualToString:@"blue"]) {
		return [super navigationBarTintColor];
	} else if([colorDesc isEqualToString:@"purple"]) {
		return [UIColor colorWithRed:.514 green:.164 blue:.816 alpha:1.0];
	} else if([colorDesc isEqualToString:@"black"]) {
		return [UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1.0];	
	} else {
		return GAFORANGE;
	}
}

/* Override the bar tint */
- (UIColor*)navigationBarTintColor {
	return [self userDefaultTintColor];
}

- (UIColor*)toolbarTintColor {
	return [self userDefaultTintColor];
}

- (UIColor*)tabBarTintColor {
	return [self userDefaultTintColor];
}

- (NSUInteger)authorHeaderHeight{
	if(self.quoteImageSize.height > self.avatarImageSize.height) {
		return self.quoteImageSize.height;		
	} else {
		return self.avatarImageSize.height;
	}
}

- (CGSize)avatarImageSize {
	//Current ratio is 2.10526:1
	return CGSizeMake(43, 57);
}

- (CGSize)quoteImageSize {
	return CGSizeMake(30, 57);
}

- (NSUInteger)uiToolbarHeight{
	return 40;
}

- (CGFloat)uiToolbarAlpha{
	CGFloat opacity = [[NSUserDefaults standardUserDefaults] floatForKey:@"toolbar_opacity_value"];
	if(!opacity) {
		opacity = .75;		
	}
	return opacity;
}


@end
