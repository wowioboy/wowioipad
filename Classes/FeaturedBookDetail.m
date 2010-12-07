    //
//  FeaturedBookDetail.m
//  WOWIO
//
//  Created by Lawrence Leach on 7/8/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "FeaturedBookDetail.h"
#import "WebViewController.h"
#import "Topbooks.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@implementation FeaturedBookDetail
@synthesize bookTitle, bookAuthor, bookLength, bookPublishDate, bookPublisher, bookIsbn, bookIsbnLabel, bookDetails, bookJacket, bookRating;
@synthesize book, delegate, appDelegate, networkQueue;
@synthesize managedObjectContext;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// set the db context
	self.managedObjectContext = [appDelegate managedObjectContext];
	
	// load a done button
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self
											   action:@selector(dismissBookView:)] autorelease];

	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}

-(void)viewDidAppear:(BOOL)animated {
	
	self.title = [NSString stringWithFormat:@"%@ by %@",[book title],[book authorname]];

	[self.bookTitle setNumberOfLines:2];
	[self.bookTitle setLineBreakMode:UILineBreakModeWordWrap];
	[self.bookTitle setAdjustsFontSizeToFitWidth:NO];
	[self.bookTitle setText:[book title]];
	
	[self.bookAuthor setText:[book authorname]];
	[self.bookPublisher setText:[book publishername]];
	[self.bookLength setText:[NSString stringWithFormat:@"%@ pages",[book pagecount]]];
	[self.bookPublishDate setText:[book publicationdate]];
	[self.bookIsbnLabel setHidden:YES];
	[self.bookIsbn setHidden:YES];
	[self.bookRating setHidden:YES];
	
	// start activity indicator
	[spinner startAnimating];
	
	// fetch book jacket image
	//NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wowio.com%@",[book coverimagepath_l]]];
	//NSLog(@"\nBook: %@\nImage URL: %@\n\n",[book title],url);
	//[self fetchBookJacket:url];
	
	[self.bookJacket setImage:[book bookCover]];
	
	
	// format book details display
	[self.bookDetails setFont:[UIFont systemFontOfSize:14.0]];
	[self.bookDetails setText:[book details]];

	//NSLog(@"\nTitle:%@\nDescription:%@\n\n",[book title],[book details]);
}


#pragma mark -
#pragma mark Button Methods

-(IBAction)downloadAction:(id)sender {
	NSString *msg = @"Download action goes here!";
	[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
}

-(IBAction)previewAction:(id)sender {
	//NSString *msg = @"Preview action goes here!";
	//[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	[self loadBookPreview:[self.book bookid]];
}

-(void)loadBookPreview:(NSNumber *)bookid {
	
	WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	//viewController.delegate = self;
	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
	//[modalNavController setNavigationBarHidden:YES];
	
	// setup view
	viewController.title = [NSString stringWithFormat:@"%@ by %@",[self.book title], [self.book authorname]];
	
	// Present the Controller Modally
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",bookPreviewURL,bookid]];
	[self presentModalViewController:modalNavController animated:YES];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:URL];
	[viewController.webView loadRequest:urlRequest];
	
}

-(IBAction)purchaseAction:(id)sender {
	NSString *msg = [NSString stringWithFormat:@"Purchase Routine for Book \"%@\" Goes Here",[[self.book title] capitalizedString]];
	[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	//[self purchaseBook:[self.book bookid]];
}

-(void)dismissBookView:(id)sender {
	
    // Call the delegate to dismiss the modal view
    //[delegate didDismissBookView];
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Book Cover Loading

-(void)fetchBookJacket:(NSURL *)url
{
	[self setNetworkQueue:[ASINetworkQueue queue]];
	//[self.networkQueue cancelAllOperations];
	[self.networkQueue setDelegate:self];		
	[self.networkQueue setRequestDidFinishSelector:@selector(fetchRequestDone:)];
	[self.networkQueue setRequestDidFailSelector:@selector(fetchRequestWentWrong:)];
	
	// submit the request
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"Content-Type" value:@"image/jpeg"];
	[request addRequestHeader:@"Accept" value:@"image/jpeg"];
	
	// add the request to the queue and set it off
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	
}

- (void)fetchRequestDone:(ASIHTTPRequest *)request
{
	NSLog(@"Got back the book detail image!");
	
	//NSString *rsltStr = [request responseString];
	//NSLog(@"Fetch Result: %@",rsltStr);
	
	// stop the activity indicator
	[spinner stopAnimating];

    NSData *data = [request responseData];
	//NSLog(@"%@",[self imgData]);
	
	UIImage *remoteImage = [[UIImage alloc] initWithData:data];
	
	//NSData *imageData = UIImagePNGRepresentation(self.remoteImage);
	//UIImage *img = [[UIImage alloc] initWithData:imageData];
	//NSLog(@"%@",img);
	self.bookJacket.image = remoteImage;
	
    [remoteImage release];
    [data release];
}

- (void)fetchRequestWentWrong:(ASIHTTPRequest *)request
{
    NSString *msg = @"There was an error getting the book jacket!";
	[self.appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
}


#pragma mark -
#pragma mark Housekeeping Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
