//
//  Thread.h
//  MobileGAF
//
//  Created by Juice on 3/21/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Forum;

@interface Thread :  NSManagedObject  
{
}

@property (retain) NSString * title;
@property (retain) Forum * forum;

@end


