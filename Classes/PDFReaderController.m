    //
//  PDFReaderController.m
//  WOWIO
//
//  Created by Lawrence Leach on 9/7/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import "PDFReaderController.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "WebViewController.h"
//#import "PDFScrollView.h"

@implementation PDFReaderController
@synthesize book, bookView, activityIndicator, activityLabel;
@synthesize networkQueue, appDelegate;
@synthesize userId, sessionId, pgcount, pdfLegend, currentpage;

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
	
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait)
		backgroundImage = [UIImage imageNamed:@"Default-Portrait.png"];
	else
		backgroundImage = [UIImage imageNamed:@"Default-Landscape.png"];
	
	
	//load up the app delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.sessionId = [appDelegate sessionId];
	self.userId = [appDelegate userId];
	
	// Set up the book UIScrollView
	[self.bookView setShowsVerticalScrollIndicator:YES];
	[self.bookView setShowsHorizontalScrollIndicator:YES];
	[self.bookView setBounces:YES];
	[self.bookView setBouncesZoom:YES];
	[self.bookView setDecelerationRate:UIScrollViewDecelerationRateFast];
	[self.bookView setDelegate:self];
	[self.bookView setBackgroundColor:[UIColor grayColor]];
	[self.bookView setMaximumZoomScale:5.0];
	[self.bookView setMinimumZoomScale:.25];
	
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
	
	NSString *booktitle = [self.book title];
	NSString *bookauthor = [self.book authorname];
	NSString *bookpdf = [self.book filepath];
	
	self.title = [NSString stringWithFormat:@"%@ by %@", booktitle, bookauthor];
	
	
	// see if the book already exists in the documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:bookpdf];
	
	[self openBook:pdfPath];
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


#pragma mark -
#pragma mark Housekeeping Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		backgroundImage = [UIImage imageNamed:@"Default-Portrait.png"];
	else
		backgroundImage = [UIImage imageNamed:@"Default-Landscape.png"];
	
}
*/

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
	
	CGPDFDocumentRelease(pdf);
	[activityLabel release];
	[activityIndicator release];
	[book release];
	[bookView release];
	[networkQueue release];
	[appDelegate release];
	[userId release];
	[sessionId release];
	[pdfLegend release];
}


#pragma mark -
#pragma mark Book Reading Funcions

-(void)openBook:(NSString*)bookPath {
	
	// Open the PDF document
	NSURL *pdfURL = [NSURL fileURLWithPath:bookPath];
	pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	
	// Get the PDF Page that we will be drawing
	page = CGPDFDocumentGetPage(pdf, 1);
	CGPDFPageRetain(page);
	
	// SET THE PDF LEGEND
	currentpage = 1;
	pgcount = CGPDFDocumentGetNumberOfPages(pdf);
	[self.pdfLegend setText:[NSString stringWithFormat:@"Page %d of %d",1,pgcount]];
	
	// determine the size of the PDF page
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pdfScale = self.bookView.frame.size.width/pageRect.size.width;
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	
	
	// Create a low res image representation of the PDF page to display before the TiledPDFView
	// renders its content.
	UIGraphicsBeginImageContext(pageRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context,pageRect);
	
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, pageRect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Scale the context so that the PDF page is rendered 
	// at the correct size for the zoom level.
	CGContextScaleCTM(context, pdfScale,pdfScale);	
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
	
	UIGraphicsEndImageContext();
	
	backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
	backgroundImageView.frame = pageRect;
	backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.bookView addSubview:backgroundImageView];
	[self.bookView sendSubviewToBack:backgroundImageView];
	
	// Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
	pdfView = [[TiledPDFView alloc] initWithFrame:pageRect andScale:pdfScale];
	[pdfView setPage:page];
	[self.bookView addSubview:pdfView];
	
	CGPDFPageRelease(page);

}


#pragma mark -
#pragma mark Navigation Methods

-(IBAction)previousPage:(id)sender {
	//NSString *msg = @"Previous Page Navigation Goes Here!";
	//[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	
	if (currentpage > 1) {
		
		// decrement the page count
		currentpage--;
		
		// Get the PDF Page that we will be drawing
		//currentpage = CGPDFD
		page = CGPDFDocumentGetPage(pdf, currentpage);
		CGPDFPageRetain(page);
		
		// SET THE PDF LEGEND
		[self.pdfLegend setText:[NSString stringWithFormat:@"Page %d of %d",currentpage,pgcount]];
		
		// Create a low res image representation of the PDF page to display before the TiledPDFView
		// renders its content.
		UIGraphicsBeginImageContext(pageRect.size);
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		// First fill the background with white.
		CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
		CGContextFillRect(context,pageRect);
		
		CGContextSaveGState(context);
		// Flip the context so that the PDF page is rendered
		// right side up.
		CGContextTranslateCTM(context, 0.0, pageRect.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		
		// Scale the context so that the PDF page is rendered 
		// at the correct size for the zoom level.
		CGContextScaleCTM(context, pdfScale,pdfScale);	
		CGContextDrawPDFPage(context, page);
		CGContextRestoreGState(context);
		
		//UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
		
		backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
		backgroundImageView.frame = pageRect;
		backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.bookView addSubview:backgroundImageView];
		[self.bookView sendSubviewToBack:backgroundImageView];
		
		
		// Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
		pdfView = [[TiledPDFView alloc] initWithFrame:pageRect andScale:pdfScale];
		[pdfView setPage:page];
		[self.bookView addSubview:pdfView];
		
		CGPDFPageRelease(page);

	}
	
}

-(IBAction)nextPage:(id)sender {
	//NSString *msg = @"Next Page Navigation Goes Here!";
	//[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	if (currentpage < pgcount) {
		
		// increment the page count
		currentpage++;
	
		// Get the PDF Page that we will be drawing
		//currentpage = CGPDFD
		page = CGPDFDocumentGetPage(pdf, currentpage);
		CGPDFPageRetain(page);
		
		// SET THE PDF LEGEND
		[self.pdfLegend setText:[NSString stringWithFormat:@"Page %d of %d",currentpage,pgcount]];
		
		// Create a low res image representation of the PDF page to display before the TiledPDFView
		// renders its content.
		UIGraphicsBeginImageContext(pageRect.size);
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		// First fill the background with white.
		CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
		CGContextFillRect(context,pageRect);
		
		CGContextSaveGState(context);
		// Flip the context so that the PDF page is rendered
		// right side up.
		CGContextTranslateCTM(context, 0.0, pageRect.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		
		// Scale the context so that the PDF page is rendered 
		// at the correct size for the zoom level.
		CGContextScaleCTM(context, pdfScale,pdfScale);	
		CGContextDrawPDFPage(context, page);
		CGContextRestoreGState(context);
		
		//UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
		
		backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
		backgroundImageView.frame = pageRect;
		backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.bookView addSubview:backgroundImageView];
		[self.bookView sendSubviewToBack:backgroundImageView];
		
		// Create the TiledPDFView based on the size of the PDF page and scale it to fit the view.
		pdfView = [[TiledPDFView alloc] initWithFrame:pageRect andScale:pdfScale];
		[pdfView setPage:page];
		[self.bookView addSubview:pdfView];
		
		CGPDFPageRelease(page);
	}
}


#pragma mark -
#pragma mark UIScrollView DELEGATE METHODS

// A UIScrollView delegate callback, called when the user starts zooming. 
// We return our current TiledPDFView.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return pdfView;
}

// A UIScrollView delegate callback, called when the user stops zooming.  When the user stops zooming
// we create a new TiledPDFView based on the new zoom level and draw it on top of the old TiledPDFView.
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	// set the new scale factor for the TiledPDFView
	pdfScale *=scale;
	
	// Calculate the new frame for the new TiledPDFView
	pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
	
	// Create a new TiledPDFView based on new frame and scaling.
	pdfView = [[TiledPDFView alloc] initWithFrame:pageRect andScale:pdfScale];
	[pdfView setPage:page];
	
	// Add the new TiledPDFView to the PDFScrollView.
	[self.bookView addSubview:pdfView];
}

// A UIScrollView delegate callback, called when the user begins zooming.  When the user begins zooming
// we remove the old TiledPDFView and set the current TiledPDFView to be the old view so we can create a
// a new TiledPDFView when the zooming ends.
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	// Remove back tiled view.
	[oldPDFView removeFromSuperview];
	[oldPDFView release];
	
	// Set the current TiledPDFView to be the old view.
	oldPDFView = pdfView;
	[self.bookView addSubview:oldPDFView];
}


#pragma mark -
#pragma mark Conversion Funcions

/*
 Function ConvertBase10To36(nBase10)
 Dim strBase36
 Dim n
 Dim i
 
 n = nBase10
 strBase36 = ""
 
 For i = 1 To 6
 If (n Mod 36) < 10 Then
 strBase36 = Chr(48 + (n Mod 36)) & strBase36
 Else
 strBase36 = Chr(55 + (n Mod 36)) & strBase36
 End If
 n = Int(n \ 36)
 Next
 
 ConvertBase10To36 = strBase36
 End Function
*/
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

/*
 Function ObfuscateOrderBookId(nOrderBookId)
 Dim a		' OrderBookId x36
 Dim b		' random number x36
 Dim strOut
 
 Randomize
 
 a = ConvertBase10To36(nOrderBookId)
 b = ConvertBase10To36(CLng(Rnd() * 60000000) + 1)
 
 strOut = Mid(a, 4, 1) & Mid(b, 3, 1) & Mid(a, 6, 1) & Mid(b, 1, 1) & Mid(a, 3, 1) & Mid(a, 5, 1) & Mid(a, 1, 1) & Mid(b, 2, 1) & Mid(b, 5, 1) & Mid(a, 2, 1)
 
 ObfuscateOrderBookId = strOut
 End Function
*/

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
