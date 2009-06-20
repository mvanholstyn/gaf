//
//  MGWebViewController.h
//  MobileGAF
//
//  Created by Juice on 5/3/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>


@interface MGWebViewController : TTWebController {
	NSString *urlAsString;
}

@property (nonatomic, retain) NSString *urlAsString;

- (id)initWithUrl:(NSString*)aUrl;

@end


