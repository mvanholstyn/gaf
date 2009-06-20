//
//  PostCell.m
//  MobileGAF
//
//  Created by Juice on 3/22/09.
//  Copyright 2009 Justin Searls. All rights reserved.
//

#import "PostCell.h"
#import "Post.h"
#import "User.h"
#import "PostCellHeader.h"
#import "UIWebViewFactory.h"
#import <Three20/Three20.h>


@interface PostCell()

- (void) injectJavaScriptIntoWebViewWithPost:(Post*)aPost;

@end


@implementation PostCell

@synthesize headerController;
@synthesize header;
@synthesize delegate;
@synthesize webView;
@synthesize post;

#pragma mark -
#pragma mark UIWebViewDelegate methods

/**
 * Once the web view has loaded the local HTML, we'll run this JS against it to push in a 
 *	post.
 ***********/
- (void)webViewDidFinishLoad:(UIWebView *)wv {
	if(post != nil) {
		[self injectJavaScriptIntoWebViewWithPost:post];
	}
	loaded = YES;
}

#pragma mark -
#pragma mark Application Methods

- (void) injectJavaScriptIntoWebViewWithPost:(Post*)aPost {
	NSString *htmlToInject = aPost.content;
	
	if(aPost.content == nil || [aPost.content length] == 0) {
		htmlToInject = @"&nbsp;";
	}
	
	NSMutableString *cleanedUpHtmlToInject = [[[NSMutableString alloc] initWithString:htmlToInject] autorelease];
	
	//Escape quotes
	[cleanedUpHtmlToInject replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSLiteralSearch range:NSMakeRange(0, [cleanedUpHtmlToInject length])];

	//Strip newlines.
	[cleanedUpHtmlToInject replaceOccurrencesOfString:@"\r\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [cleanedUpHtmlToInject length])];	
	[cleanedUpHtmlToInject replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [cleanedUpHtmlToInject length])];	
	
	//replace this cell's view's content DIV with whatever was in the post.
	NSMutableString *jsToInvoke = [[[NSMutableString alloc] initWithString:@"setContent(\""] autorelease];
	[jsToInvoke appendString:cleanedUpHtmlToInject];
	[jsToInvoke appendString:@"\");"];
	[webView stringByEvaluatingJavaScriptFromString:jsToInvoke];

	//Should resize the webview appropriately...	
	CGRect newWebFrame = [webView frameOfElement:@"document.getElementById('mobileGafPostContent')"];	
	newWebFrame.origin.y = header.frame.size.height;
	newWebFrame.size.height += kMargin;
	[webView setFrame:newWebFrame];
	
	CGRect totalFrame = CGRectMake(0.0, 0.0, 
								   self.frame.size.width, 
								   self.header.frame.size.height + newWebFrame.size.height);
	[self setFrame:totalFrame];
	[self.contentView setFrame:totalFrame];
	
	[aPost setRenderedHeight:totalFrame.size.height];	
	//NSLog([[[NSString alloc] initWithFormat:@"Post's new rendered height: %f",aPost.renderedHeight] autorelease]);
	
	[self.delegate postCellDidFinishContentInjectionWithPost:aPost];
}

- (void) refreshWebViewWithPost:(Post*)aPost {
	//NSLog(@"Injecting Post into WebView.");
	
	[self setPost:aPost];
	if(loaded) {
		[self injectJavaScriptIntoWebViewWithPost:post];
	}
	
}


/**
 * Designated initializer.
 */
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier withPost:(Post*)aPost withIndex:(NSUInteger)index delegate:(id<PostCellDelegate>)aDelegate {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {

		//Initialize some stuff.
		loaded = NO;
		[self setDelegate:aDelegate];
		[self setPost:aPost];		

		//PostCell config
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundColor = [UIColor whiteColor];
		self.contentView.backgroundColor = [UIColor whiteColor];
		
		//Initialize my header.
		headerController = [[UIViewController alloc] initWithNibName:@"PostCellHeader" 
																				 bundle:[NSBundle mainBundle]];
		[self setHeader:(PostCellHeader*)headerController.view];
		[header setDelegate:aDelegate];
		[header setPost:aPost];
		header.userNameLabel.text = post.author.name;		
		if(aPost.author != nil && [aPost.author.avatarUrl length] > 0) {
			header.avatarImage.autoresizesToImage = NO;
			header.avatarImage.url = aPost.author.avatarUrl;			
		}
		
		[self.contentView addSubview:header];				
		
		//Use the webview from the factory or make a new one.				
		if([[UIWebViewFactory getInstance].webViews count] > index) {
			//NSLog(@"Using web view from factory");
			webView = [[[UIWebViewFactory getInstance] webViewAtIndex:index] retain];
			[self injectJavaScriptIntoWebViewWithPost:post];
			loaded = YES;
		} else {
			NSLog(@"Warning: Rolling my own web view.");
			CGRect webFrame = CGRectMake(0.0, header.frame.size.height, frame.size.width, frame.size.height-header.frame.size.height);
			webView = [[UIWebView alloc] initWithFrame:webFrame];  
			[webView setBackgroundColor:[UIColor whiteColor]];
			[webView setDelegate:self];

			//Load my standard postCell.html page. (JS will be used to differentiate these with content)
			[webView loadRequest:[NSURLRequest requestWithURL:
								  [NSURL fileURLWithPath:[[NSBundle mainBundle]
														  pathForResource:@"postCell" 
														  ofType:@"html"]
											 isDirectory:NO]]];			
		}
		
		[self.contentView addSubview:webView];
		
	}
    return self;
}	

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	return [self initWithFrame:frame reuseIdentifier:reuseIdentifier withPost:nil withIndex:0 delegate:nil];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	[headerController release];
	[post release];
	[header release];
	[webView release];
	[delegate release];
    [super dealloc];
}


@end








