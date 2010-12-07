    //
//  LoadingViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/10/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "LoadingViewController.h"
#import "WOWIOAppDelegate.h"
#import "CJSONDeserializer.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@implementation LoadingViewController
@synthesize backgroundImage;
@synthesize hostStatus, internetStatus, wifiStatus;
@synthesize networkQueue, appDelegate, managedObjectContext;

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
	
	// set the data store
	self.managedObjectContext = [appDelegate managedObjectContext];

	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait)
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	else
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
	
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	} else {
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
	}
	
}


#pragma mark -
#pragma mark Content Methods

#pragma mark Features
-(void)getData:(NSString *)feed {
	
	if ([self internetCheck]) {
				
		// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
		
		// build the request
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] 
									initWithURL:[NSURL 
												 URLWithString:feed]] autorelease];
		[request setTimeOutSeconds:20];
		[request setRequestMethod:@"GET"];
		
		// add the request to the transmission queue and set it off
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSString *errorString = @"A communication error occurred.\n\nPlease retry your request.";
	[appDelegate alertWithMessage:errorString withTitle:@"WOWIO"];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	
	NSMutableArray *books = [[[NSMutableArray alloc] init] autorelease];
	
	NSString *rsltStr = [request responseString];
	NSDictionary *responseHeaders = [request responseHeaders];
	
	NSLog(@"Response String: %@\n",rsltStr);
	NSLog(@"\nResponse Headers: %@",responseHeaders);
	
	//NSString *connectionResult = (NSString*)[responseHeaders valueForKey:@"Content-Type"];
	//NSInteger connectionResultLength = (NSInteger)[responseHeaders valueForKey:@"Content-Length"];
	
	// NEW JSON WAY
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableArray *feed = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:&error];
	
	books = nil;
	books = feed;
	//NSLog(@"Articles: %@\n",articles);
	
	// if we have props save em' to the db
	if ([books count] >0)
		NSLog(@"Data Returned: \n%@",books);
	
}

#pragma mark Categories
-(void)getCategories {
	
}

#pragma mark Top Sellers
-(void)getTopSellers {
	
}


#pragma mark -
#pragma mark Connectivity Check Method

-(BOOL)internetCheck {
	
	
	BOOL _isInternetConnectivity = YES;
	
	// check if there is internet connectivity
	[appDelegate performSelector:@selector(updateReachabilityStatus)];
	
	hostStatus = [appDelegate hostStatus];
	wifiStatus = [appDelegate wifiStatus];
	internetStatus = [appDelegate internetStatus];
	
	if (hostStatus == NotReachable && internetStatus == NotReachable && wifiStatus == NotReachable) {
		
		// alert the user that there is no internet connectivity
		NSString *errorString = @"There is Currently NO Internet Connectivity.\nYou will be unable to use the WOWIO bookstore effectively\nuntil connectivity has been restored.";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:errorString
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		_isInternetConnectivity = NO;
	}
	
	return _isInternetConnectivity;
}


#pragma mark -
#pragma mark Housekeeping Methods

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
