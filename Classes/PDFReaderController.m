    //
//  PDFReaderController.m
//  WOWIO
//
//  Created by Lawrence Leach on 9/7/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "PDFReaderController.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "WebViewController.h"
#import "PDFScrollView.h"

@implementation PDFReaderController
@synthesize book, bookView, activityIndicator, activityLabel;
@synthesize networkQueue, appDelegate;
@synthesize userId, sessionId;

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
	
	//load up the app delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.sessionId = [appDelegate sessionId];
	self.userId = [appDelegate userId];
	
	// set the webview delegate
	[self.bookView setDelegate:self];
	
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
	actRect.origin.y = 12;
	
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:actRect];
	[self.activityIndicator setHidesWhenStopped:YES];
	[self.activityIndicator stopAnimating];
	
	// activity label
	CGRect lblRect;
	lblRect.size.width = 187;
	lblRect.size.height = 21;
	lblRect.origin.x = 57;
	lblRect.origin.y = 11;
	
	self.activityLabel = [[UILabel alloc] initWithFrame:lblRect];
	[self.activityLabel setBackgroundColor:[UIColor clearColor]];
	[self.activityLabel setTextColor:[UIColor whiteColor]];
	[self.activityLabel setFont:[UIFont systemFontOfSize:12]];
	[self.activityLabel setText:@"Loading...."];
	[self.activityLabel setHidden:YES];
	
	[self.navigationController.view addSubview:[self activityLabel]];
	[self.navigationController.view addSubview:[self activityIndicator]];
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}

-(void)viewDidAppear:(BOOL)animated {
	
	BOOL success;

	//NSNumber *bookid = [self.book bookid];
	NSString *booktitle = [self.book title];
	NSString *bookauthor = [self.book authorname];
	NSString *bookpdf = [self.book filepath];
	//NSLog(@"\nTitle: %@ (%@)\nOrder ID: %@\nEncrypted Order ID: %@\nFile: %@\n\n",booktitle,bookid,orderbookid,encbookid,bookpdf);
	
	self.title = [NSString stringWithFormat:@"%@ by %@", booktitle, bookauthor];
	
	
	// see if the book already exists in the documents directory
	NSFileManager *FileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:bookpdf];
	success = [FileManager fileExistsAtPath:pdfPath];
	
	//NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"1001ArabianNiSinba02_9826901" ofType:@"pdf"];
	//NSURL *pdfURL = [NSURL URLWithString:resourcePath];
	//[self.bookView loadRequest:[NSURLRequest requestWithURL:pdfURL]];
	
	PDFScrollView *sv = [[PDFScrollView alloc] initWithFrame:[[self view] bounds]];
	[self.bookView addSubview:sv];
	
	
	//if (success) {
		// load the book from docs directory
		//[self openWOWIOBook:bookpdf];
		
	//} else {
		// go download the book from WOWIO and save it to the docs directory
		//[self performSelector:@selector(loadBookData:)];
	//}
}

-(void)dismissView:(id)sender {
	
    // Call the delegate to dismiss the modal view
    //[delegate didDismissBookView];
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Book Viewer

-(void)loadBookData:(id)sender {
	
	// get the filename to store the book data to...
	NSString *bookpdf = [self.book filepath];
	NSNumber *orderbookid = [self.book orderbookid];
	NSString *encbookid = [self obfuscateOrderBookId:orderbookid];

	// go get the book data
	NSString *ipAddr = [self.book externalip];
	NSString *urlStr = [NSString stringWithFormat:@"http://%@/downloadbook.asp?book=%@",ipAddr,encbookid];
	NSLog(@"Book Download URL: %@",urlStr);
	//NSURL *url = [NSURL URLWithString:urlStr];
	//NSData *bookData = [NSData dataWithContentsOfURL:url];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:bookpdf];
	//[bookData writeToFile:pdfPath atomically:YES];
	
	[self setNetworkQueue:[ASINetworkQueue queue]];
	[self.networkQueue cancelAllOperations];
	[self.networkQueue setDelegate:self];
	[self.networkQueue setMaxConcurrentOperationCount:5];
	[self.networkQueue setRequestDidFinishSelector:@selector(bookLoadFinished:)];
	[self.networkQueue setRequestDidFailSelector:@selector(bookLoadFailed:)];
	
	// build the request
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlStr]] autorelease];
	[request setTimeOutSeconds:60];
	[request addRequestHeader:@"Content-Type" value:@"application/pdf"];
	[request addRequestHeader:@"Cookie" value:self.sessionId];
	[request setDownloadDestinationPath:pdfPath];
	
	// add the request to the transmission queue and set it off
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
}

- (void)bookLoadFailed:(ASIHTTPRequest *)request
{
	NSString *errorString = @"A communication error occurred.\nWe are unable to download your book at this time.\n\nPlease retry your request again later.";
	[appDelegate alertWithMessage:errorString withTitle:@"WOWIO"];
}

- (void)bookLoadFinished:(ASIHTTPRequest *)request
{
	NSData *rsltData = [request responseData];
	int rsltLen = [rsltData length];
	NSString *rsltStr = [request responseString];
	NSDictionary *loadHeaders = [request responseHeaders];
	NSLog(@"\nRaw Result String:\n%@",rsltStr);
	NSLog(@"\nResponse Header:\n%@",loadHeaders);
	NSLog(@"\nLength: %d\nData:%@\n",rsltLen,rsltData);
	
	NSString *bookpdf = [self.book filepath];
	[self openWOWIOBook:bookpdf];
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
	
	[activityLabel release];
	[activityIndicator release];
}


#pragma mark -
#pragma mark Book Reading Funcions

-(void)openWOWIOBook:(NSString *)pdf {
	
	BOOL success;
	NSError *error;
	NSString *tstBook = @"1001ArabianNiSinba02_9826901.pdf";
	
	NSFileManager *FileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	//NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:pdf];
	NSString *tmpPath = [documentsDirectory stringByAppendingPathComponent:tstBook];
	//NSLog(@"\nPDF: %@\nFull Path: %@\n",pdf,pdfPath);
	
	// copy the test pdf to the users document directory.
	NSString *defPdfPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tstBook];
	success = [FileManager fileExistsAtPath:tmpPath];
	
	if (success) {
		NSURL *url = [NSURL fileURLWithPath: tmpPath];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[[self bookView] loadRequest:request];
		
	} else {
		//NSString *msg = @"Book can't found and copied";
		//[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
		success = [FileManager copyItemAtPath:defPdfPath toPath:tmpPath error:&error];
		
		NSURL *url = [NSURL fileURLWithPath: tmpPath];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[[self bookView] loadRequest:request];
	}
}

-(void)openBook:(NSData *)data {
	
	// get bundle path
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
	
	// open the pdf from within the book web view
	[self.bookView loadData:data MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:baseURL];
	
}

- (UIColor *) colorWithHexString: (NSString *) stringToConvert{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	// String should be 6 or 8 characters
	if ([cString length] < 6) return [UIColor blackColor];
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	if ([cString length] != 6) return [UIColor blackColor];
	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}


#pragma mark -
#pragma mark Conversion Funcions

-(NSString*)convertBase10To36:(NSNumber*)nBase10 {
	NSString *strBase36;
	int i, n;
	
	n = [nBase10 intValue];
	strBase36 = @"";
	
	for (i=1; i<=6; i++) {
		
		int mymod;
		int myNo1;
		int myNo2;
		int asciiCode1 = 48;
		int asciiCode2 = 55;
		
		NSString *asciiStr;

		mymod = n % 36;
		
		if (mymod < 10) {
			myNo1 = asciiCode1 + (n % 36);
			asciiStr = [NSString stringWithFormat:@"%c", myNo1];
		} else {
			myNo2 = asciiCode2 + (n % 36);
			asciiStr = [NSString stringWithFormat:@"%c", myNo2];
		}
		strBase36 = [strBase36 stringByAppendingString:asciiStr];
		n = (n / 36);
	}
	return strBase36;
}

-(NSNumber*)convertBase36To10:(NSString*)strBase36 {
	int nBase10;
	NSNumber *retNum;	
	NSString *str;
	int i, n, strLen;
	
	str = strBase36;
	nBase10 = 0;
	strLen = [strBase36 length];
	
	for (i=1; i<=strLen; i++) {
		n = [str intValue];
		if (n < 64) {
			nBase10 = (nBase10 * 36) + n - 48;
			
		} else if (n > 95){
			nBase10 = (nBase10 * 36) + n - 87;
			
		} else {
			nBase10 = (nBase10 * 36) + n - 55;
		}
		//str = (n / 36);
	}
	retNum = [NSNumber numberWithInt:nBase10];
	return retNum;
}

-(NSString*)obfuscateOrderBookId:(NSNumber*)orderBookId {
	NSString *strOut;
	NSString *aStr;
	NSString *bStr;
	
	int frmNo = 1;
	int toNo = 60000000;
	int rNo = (arc4random() % (toNo - frmNo)) + 1;

	aStr = [self convertBase10To36:orderBookId];
	bStr = [self convertBase10To36:[NSNumber numberWithInt:rNo]];
	
	strOut = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",[aStr substringWithRange:NSMakeRange(3, 1)],[bStr substringWithRange:NSMakeRange(2, 1)],[aStr substringWithRange:NSMakeRange(5, 1)],[bStr substringWithRange:NSMakeRange(0, 1)],[aStr substringWithRange:NSMakeRange(2, 1)],[aStr substringWithRange:NSMakeRange(4, 1)],[aStr substringWithRange:NSMakeRange(0, 1)],[bStr substringWithRange:NSMakeRange(1, 1)],[bStr substringWithRange:NSMakeRange(4, 1)],[aStr substringWithRange:NSMakeRange(1, 1)]];
	
	return strOut;
}

@end
