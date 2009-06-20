//
//  Forum.h
//  MobileGAF
//
//  Created by Juice on 3/20/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Post;

@interface Forum :  NSManagedObject  
{
}

@property (retain) NSNumber * postCount;
@property (retain) NSString * name;
@property (retain) NSNumber * threadCount;
@property (retain) Post * mostRecentPost;

@end


