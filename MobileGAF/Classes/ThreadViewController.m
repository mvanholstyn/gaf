//
//  ThreadViewController.m
//  MobileGAF
//
//  Created by Juice on 3/22/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "PostHtmlParser.h"
#import "ThreadViewController.h"

#import "Thread.h"
#import "Post.h"
#import "PostCell.h"
#import "MobileGAFAppDelegate.h"
#import <Three20/Three20.h>

@interface ThreadViewController()

- (void)downloadPosts;

- (void)updateProgressAlert;
- (void)displayProgressAlert;

@end

@implementation ThreadViewController

@synthesize toolbar;
@synthesize progressAlert;
@synthesize progressView;
@synthesize postCells;
@synthesize postHtmlParser;
@synthesize refreshButton;
@synthesize postsArray;
@synthesize thread;

#pragma mark -
#pragma mark PostCellDelegate

- (void)postCellDidFinishContentInjectionWithPost:(Post*)aPost {
	fullyRenderedPostCount++;
	[self updateProgressAlert];
}

//User clicked the reply button for this post.
- (void)handleReplyWithPost:(Post*)aPost {
	NSMutableString *url = [[[NSMutableString alloc] initWithString:kNeoGafBaseUrl] autorelease];
	[url appendString:@"newreply.php?do=newreply&p="];
	[url appendString:aPost.uid];
	NSLog(@"Opening URL %@ in Safari",url);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Post *post = (Post*)[postsArray objectAtIndex:[indexPath row]];
	
	CGFloat height = kDefaultRowHeight;
	if(post.renderedHeight) {
		height = post.renderedHeight;
	}
	
	//NSLog([[[NSString alloc] initWithFormat:@"Reporting height of %f for row %d",height,[indexPath row]] autorelease]);
	
	return height;
}


#pragma mark Application methods

- (void)updateProgressAlert {
	
	float progress = fullyRenderedPostCount / ((float)[postsArray count]);
	progressView.progress = progress;
	
	//NSLog([[[NSString alloc] initWithFormat:@"Progress is %f",progressView.progress] autorelease]);
	
	//Our posts are ready to display! clear out transient stuffz.
	if(progressView.progress == 1) {
		//alert
		[progressAlert dismissWithClickedButtonIndex:0 animated:YES];
		[progressAlert release];
		progressAlert = nil;
		
		[progressView release];
		progressView = nil;
		
		fullyRenderedPostCount = 0;
		
		//Reload table data, since we're all loaded up.
		[self.tableView reloadData];
	}
}

- (void)displayProgressAlert {
	fullyRenderedPostCount = 0;
	progressAlert = [[UIAlertView alloc] initWithTitle: @"Rendering Posts"
											   message: @"Please wait..."
											  delegate: self
									 cancelButtonTitle: nil
									 otherButtonTitles: nil];
	
	progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
    [progressAlert addSubview:progressView];
    [progressView setProgressViewStyle: UIProgressViewStyleBar];
	[progressAlert show];
}

- (void)resetContent {
	fullyRenderedPostCount = 0;
	[self.postCells removeAllObjects];
	[self.postsArray removeAllObjects];
	[self.tableView reloadData];
}

-(void)downloadPosts {
	[self downloadPostsWithThread:self.thread withCache:NO];
}

-(void)downloadPostsWithThread:(Thread*)aThread withCache:(BOOL)useCache{
	if(postHtmlParser != nil && postHtmlParser.loading == YES) {
		NSLog(@"We're already loading. Cancelling the request to download posts");
		return;		
	}
	
	if(progressView == nil) {
		[self displayProgressAlert];		
		progressAlert.title = @"Downloading Posts";
		progressView.hidden = YES;
	}
	
	
	[self setThread:aThread];		
	self.title = thread.title;
	
	//NSLog(@"Downloading Posts!");
	NSMutableString* url = [[[NSMutableString alloc] initWithString:kNeoGafBaseUrl] autorelease];
	[url appendString:thread.url];
	
	postHtmlParser = [[PostHtmlParser alloc] initWithUrl:url delegate:self isCaching:useCache];
	[postHtmlParser beginLoadingAndParsing];
}

#pragma mark -
#pragma mark HtmlParserDelegate methods


- (void)handleParseResults:(NSMutableArray*)results {
	//NSLog(@"Handling parse results.");
	if(progressAlert != nil) {
		progressAlert.title = @"Rendering Posts";
		progressView.hidden = NO;
	}
		
	
	[self setPostsArray:results];
	
	//Initialize all our cells
	for (int i = 0; i < [results count]; i++) {
		Post *post = (Post*)[results objectAtIndex:i];
		
		[postCells setValue:[[[PostCell alloc] initWithFrame:CGRectMake(0, 0, 320.0, kDefaultRowHeight) 
											 reuseIdentifier:@"PostCell" 
													withPost:post 
												   withIndex:i
													delegate:self] 
							 autorelease] forKey:[[[NSString alloc] initWithFormat:@"%d",i] autorelease]];
	}
		
	//NSLog(@"Refreshing content...");
	//[self.tableView reloadData];
}

- (void)parsingFailed:(NSError*)error {
	NSLog(@"Loading failed. Will drop the loading popup.");
	if(progressAlert != nil) {
		[progressAlert dismissWithClickedButtonIndex:0 animated:YES];		
	}
	
	//Popup an alert
	NSMutableString *message;
	
	NSRange is500Range = [[error description] rangeOfString:@"500."];	
	if(is500Range.location != NSNotFound) {
		message  = [NSMutableString stringWithString:@"Got a 500 Error from the server :( "];
	} else {
		message = [NSMutableString stringWithString:@"Error occurred while loading: "];
		[message appendString:[error localizedDescription]];		
	}
	
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Connection failed" 
													 message:message
													delegate:nil 
										   cancelButtonTitle:@"Taking a Deep Breath" 
										   otherButtonTitles:nil] autorelease];
	[alert show];
}

#pragma mark View Controller methods

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 //Set up a child controller...
 }
 return self;
 }
 */


- (void)viewDidLoad {
    [super viewDidLoad];
	//NSLog(@"Thread view has loaded.");
	
	[self.tableView setScrollsToTop:YES];
	
//	MobileGAFAppDelegate *appDelegate = (MobileGAFAppDelegate*)[UIApplication sharedApplication].delegate;
//	appDelegate.navigationController.toolbarHidden = NO;
//	[self setToolbar:appDelegate.navigationController.toolbar];


	
	//Set up Refresh Button
	refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(downloadPosts)];
	refreshButton.enabled=YES;
	self.navigationItem.rightBarButtonItem = refreshButton;
	
	//Initialize my custom cell array
	postCells = [[NSMutableDictionary alloc] init];
}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self resetContent];
	
	//Release all of our transient assets.
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [postsArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return [postCells objectForKey:[[[NSString alloc] initWithFormat:@"%d",[indexPath row]] autorelease]];
	
	/*
	 NSLog(@"Creating cell for row");
	 
	 static NSString *CellIdentifier = @"PostCell";
	 PostCell *cell = (PostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	 
	 Post *post = (Post *)[postsArray objectAtIndex:indexPath.row];
	 
	 if (cell == nil) {
	 NSLog(@"Initializing a post cell");
	 CGRect rect;		 
	 rect = CGRectMake(0.0, 0.0, 320.0, 60.0);
	 cell = [[PostCell alloc] initWithFrame:rect reuseIdentifier:CellIdentifier withPost:post delegate:self];		
	 
	 } else {
	 //Reload the web content in the post to match this one.
	 [cell refreshWebViewWithPost:post];
	 }
	 
	 NSLog(@"Returning");
	 return cell;
	 */
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)dealloc {
	[progressView release];
	[progressAlert release];
	[refreshButton release];
	[postHtmlParser release];
	[postCells release];
	[postsArray release];
	[thread release];	
	
    [super dealloc];
}


@end


/*
 #pragma mark -
 #pragma mark UIViewController methods
 
 - (void)loadView {
 [super loadView];
 
 
 self.autoresizesForKeyboard = YES;
 self.variableHeightRows = YES;
 
 self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
 style:UITableViewStylePlain];
 self.tableView.autoresizingMask = 
 UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 [self.view addSubview:self.tableView];
 
 }
 
 
 #pragma mark -
 #pragma mark TTTableViewController methods
 
 - (id<TTTableViewDataSource>)createDataSource {
 NSLog(@"Asked to create data source..");
 
 NSMutableArray *cells = [[[NSMutableArray alloc] initWithCapacity:[postsArray count]]autorelease];
 for (Post* post	in postsArray) {
 
 /**
 [cells addObject: [[[PostCell alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60) 
 reuseIdentifier:@"PostCell" 
 withPost:post 
 delegate:self] 
 autorelease]];	
 **//*
  
  [cells addObject: [[[TTSubtextTableField alloc] initWithText:@"Post by a user"
  subtext:post.content] autorelease]];
  }
  
  return [[[TTListDataSource alloc] initWithItems:cells] autorelease];
  }
  */






