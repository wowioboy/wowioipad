    //
//  WebViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 8/25/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController
@synthesize activityIndicator, activityLabel, webView, scrollView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.webView setDelegate:self];
	
	// load a done button
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self
											   action:@selector(dismissView:)] autorelease];
	
	// activity indicator
	CGRect actRect;
	actRect.size.width = 20;
	actRect.size.height = 20;
	actRect.origin.x = 29;
	actRect.origin.y = 35;

	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:actRect];
	[self.activityIndicator setHidesWhenStopped:YES];
	[self.activityIndicator stopAnimating];

	// activity label
	CGRect lblRect;
	lblRect.size.width = 187;
	lblRect.size.height = 21;
	lblRect.origin.x = 57;
	lblRect.origin.y = 35;
	
	self.activityLabel = [[UILabel alloc] initWithFrame:lblRect];
	[self.activityLabel setBackgroundColor:[UIColor clearColor]];
	[self.activityLabel setTextColor:[UIColor whiteColor]];
	[self.activityLabel setFont:[UIFont systemFontOfSize:12]];
	[self.activityLabel setText:@"Loading...."];
	[self.activityLabel setHidden:NO];
	
	[self.navigationController.view addSubview:[self activityLabel]];
	[self.navigationController.view addSubview:[self activityIndicator]];
	
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	
}

-(void)dismissView:(id)sender {
	
    // Call the delegate to dismiss the modal view
    //[delegate didDismissBookView];
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark webView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)wv {
    NSLog (@"webViewDidStartLoad");
    [activityIndicator startAnimating];
	[activityLabel setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    NSLog (@"webViewDidFinishLoad");
    [activityIndicator stopAnimating];
	[activityLabel setHidden:YES];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    NSLog (@"webView:didFailLoadWithError");
    [activityIndicator stopAnimating];
    if (error != NULL) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle: [error localizedDescription]
								   message: [error localizedFailureReason]
								   delegate:nil
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert release];
    }
}


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
	
	[activityLabel release];
	[activityIndicator release];
	[webView release];
	[scrollView release];
}


@end
