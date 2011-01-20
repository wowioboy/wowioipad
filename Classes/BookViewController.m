    //
//  BookViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/30/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "BookViewController.h"
#import "WebViewController.h"
#import "Book.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@implementation BookViewController
@synthesize bookTitle, bookAuthor, bookLength, bookLengthLabel, bookPublishDate, bookPublisher, bookIsbn, bookIsbnLabel, bookRatingsLabel, bookDetails, bookJacket, bookRating, bookFilesize, bookFilesizeLabel;
@synthesize image, book, spinner, bookRetailPrice, bookRetailLabel;
@synthesize networkQueue, appDelegate;
@synthesize managedObjectContext, numberFormatter, formatFlag, formatText;
@synthesize downloadButton, previewButton, buyButton, readButton;
@synthesize bookFormatLabel, bookFormat;

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
	
	
	numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setUsesGroupingSeparator:YES];
	[numberFormatter setAllowsFloats:YES];
	[numberFormatter setCurrencyCode:@"USD"];
	[numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setCurrencyDecimalSeparator:@"."];
	[numberFormatter setCurrencyGroupingSeparator:@","];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
	appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// set the db context
	self.managedObjectContext = [appDelegate managedObjectContext];
	
	/*
	// load a done button
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self
											   action:@selector(dismissBookView:)] autorelease];
	*/
	
	// load a button to return to the category list
	UIImage *buttonImage = [UIImage imageNamed:@"button_back.png"];
	UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setImage:buttonImage forState:UIControlStateNormal];
	aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
	
	// Initialize the UIBarButtonItem
	UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
	
	// Set the Target and Action for aButton
	[aButton addTarget:self action:@selector(dismissBookView:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = aBarButtonItem;
	
	// Release buttonImage
	[buttonImage release];

	// set nav bar style
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}

-(void)viewDidAppear:(BOOL)animated {
	
		// BASIC BOOK DETAILS
	NSString *newTitle = [book title];
	newTitle = [newTitle stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	self.title = newTitle;
	
	[self.book setDelegate:self];
	[self.bookAuthor setText:[book authorname]];
	[self.bookPublisher setText:[book publishername]];
	[self.bookTitle setNumberOfLines:3];
	[self.bookTitle setLineBreakMode:UILineBreakModeWordWrap];
	[self.bookTitle setAdjustsFontSizeToFitWidth:NO];
	[self.bookTitle setText:newTitle];
	[self.bookPublishDate setText:[book publicationdate]];
	[self.bookRetailLabel setHidden:NO];
	[self.bookRetailPrice setHidden:NO];
	[self.bookIsbnLabel setHidden:NO];
	[self.bookIsbn setHidden:NO];
	[self.bookIsbn setText:[book isbn]];
	[self.downloadButton setHidden:YES];
	
	
		// DETERMINE BOOK FORMAT
	NSNumber *bformatade_epub = [self.book bformatade_epub];
	NSNumber *bformatade_pdf = [self.book bformatade_pdf];
	NSNumber *bformatepub = [self.book bformatepub];
	NSNumber *bformatereader = [self.book bformatereader];
	NSNumber *bformatwowio = [self.book bformatwowio];
	NSString *filesize;
	
	BOOL wowiopdf = [bformatwowio boolValue];		// wowio pdf
	BOOL ade_pdf = [bformatade_pdf boolValue];		// digitial editions pdf
	BOOL ade_epub = [bformatade_epub boolValue];	// digitial editions epub
	BOOL epub = [bformatepub boolValue];			// drm-free epub
	BOOL ereader = [bformatereader boolValue];		// palm ereader
	
	if (wowiopdf) {
		formatFlag = 0;
		formatText = @"WOWIO PDF PLUS";
		filesize = [book filesize];
		
	} else if (ade_pdf) {
		formatFlag = 1;
		formatText = @"DIGITAL EDITIONS PDF";
		filesize = [book ade_pdf_filesize];
		
	} else if (ade_epub) {
		formatFlag = 2;
		formatText = @"DIGITAL EDITIONS EPUB";
		filesize = [book ade_epub_filesize];
		
	} else if (epub) {
		formatFlag = 3;
		formatText = @"DRM-FREE EPUB";
		filesize = [book epub_filesize];
		
	} else if (ereader)	{
		formatFlag = 4;
		formatText = @"PALM EREADER";
		filesize = [book ereader_filesize];
	}

		//NSLog(@"Book Filesize: %@",filesize);
	[self.bookFormat setText:formatText];
	
		// FILE SIZE
	if ([filesize isEqualToString:@""]) {
		[self.bookFilesize setHidden:YES];
		[self.bookFilesizeLabel setHidden:YES];
		
	} else {
		[self.bookFilesize setHidden:NO];
		[self.bookFilesizeLabel setHidden:NO];
		[self.bookFilesize setText:filesize];
	}


		// PAGE COUNTS
	NSNumber *previewpagecount = [book previewpagecount];
	NSNumber *pagecount = [book pagecount];
	NSNumber *purchased = [book purchased];
	if ([previewpagecount isEqualToNumber:[NSNumber numberWithInt:0]]) {
		
		if ([pagecount isEqualToNumber:[NSNumber numberWithInt:0]]) {
			[self.bookLength setHidden:YES];
			[self.bookLengthLabel setHidden:YES];
		} else {
			[self.bookLength setHidden:NO];
			[self.bookLengthLabel setHidden:NO];
			[self.bookLength setText:[NSString stringWithFormat:@"%@ pages",pagecount]];
		}
		
	} else 
		[self.bookLength setText:[NSString stringWithFormat:@"%@ pages (%@ page preview)",pagecount, previewpagecount]];
	
	
	
		// BUTTONS
	if (![[book imagesubpath] isEqualToString:@""]) {
		[self.readButton setHidden:YES];
		[self.previewButton setHidden:YES];
		
	} else {
		if ([previewpagecount isEqualToNumber:[NSNumber numberWithInt:0]] || ![purchased isEqualToNumber:[NSNumber numberWithInt:0]]) {
		
			[self.readButton setHidden:NO];
			[self.previewButton setHidden:YES];
			//[self.buyButton setHidden:NO];
		} else {
			[self.readButton setHidden:YES];
			[self.previewButton setHidden:NO];
			//[self.buyButton setHidden:YES];
		}
	}

	
		// FORMAT THE DISPLAY OF THE RETAIL PRICE
	NSString *priceamt;
	NSNumber *bavailable = [book bavailable];
	NSNumber *becommerce = [book becommerce];
	NSNumber *bnodrm = [book bnodrm];
	NSNumber *bbooksponsor = [book bbooksponsor];
	NSString *indexname = [book indexname];
	NSNumber *retailprice = [book retailprice];
	
	if (![bavailable isEqualToNumber:[NSNumber numberWithInt:0]] && ![becommerce isEqualToNumber:[NSNumber numberWithInt:0]] || ![bnodrm isEqualToNumber:[NSNumber numberWithInt:0]]) {
		
		if ([retailprice intValue] > 0) {
			
			if ([bbooksponsor isEqualToNumber:[NSNumber numberWithInt:0]]) {
				NSString *thePrice = [retailprice stringValue];
				NSNumber *fprice = [NSNumber numberWithFloat:[thePrice floatValue]];
				priceamt = [numberFormatter stringFromNumber:fprice];
				[self.buyButton setHidden:NO];
				[self.downloadButton setHidden:YES];

			} else {
				priceamt = [NSString stringWithFormat:@"Free from %@",[indexname capitalizedString]];
				[self.buyButton setHidden:YES];
				[self.downloadButton setHidden:NO];
			}
			
		} else {
			priceamt = @"FREE";
			[self.buyButton setHidden:YES];
			[self.downloadButton setHidden:NO];
		}
		
	} else {
		priceamt = @"";
		[self.bookRetailLabel setHidden:YES];
		[self.bookRetailPrice setHidden:YES];
		[self.buyButton setHidden:YES];
	}
	[self.bookRetailPrice setText:[NSString stringWithFormat:@"%@",priceamt]];
	
	
		// FORMAT RATING STARS
	NSString *rateStr = [NSString stringWithFormat:@"%@.png",[book avgrating]];
	self.bookRating.image = [UIImage imageNamed:rateStr];
	
	// check if book has a rating and display it otherwise hide the fields
	if ([book avgrating] == nil) {
		[self.bookRatingsLabel setHidden:YES];
		[self.bookRating setHidden:YES];

	} else {
		[self.bookRatingsLabel setHidden:NO];
		[self.bookRating setHidden:NO];
	}

	
		// SET BOOK JACKET IMAGE
	[self.bookJacket setImage:[book bookCover]];
	
	
		// FORMAT THE DISPLAY OF BOOK DETAILS
	//[self.bookDetails setFont:[UIFont systemFontOfSize:14.0]];
	//[self.bookDetails setText:[book details]];
	NSString *theDetails = [book details];
	NSString *htmlPage = [NSString stringWithFormat:@"<html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=UTF-8\" /><title>%@</title><style> body{ font-family:Ariel, Helvetica, serif; font-size:14px; margin:0px; padding:0px; color:#515151;}</style></head><body>%@</body></html>",newTitle,theDetails];
	
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
	
	// stuff the value into the webview object
	//self.bookDetails = [[UIWebView alloc] init];
	[self.bookDetails setOpaque:NO];
	[self.bookDetails setBackgroundColor:[UIColor clearColor]];
	[self.bookDetails loadHTMLString:htmlPage baseURL:baseURL];
}


#pragma mark -
#pragma mark Button Methods

-(IBAction)downloadAction:(id)sender {
	//NSString *msg = @"Download action goes here!";
	//[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	// book values
	NSString *bookTtl = [self.book title];
	NSString *bookAuth = [self.book authorname];
	//NSNumber *bookPrice = [self.book retailprice];
	//NSString *userId = [appDelegate userId];
	NSNumber *bookId = [self.book bookid];
	
	WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	//viewController.delegate = self;
	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
	//[modalNavController setNavigationBarHidden:YES];
	
	// setup view
	viewController.title = [NSString stringWithFormat:@"%@ by %@",bookTtl,bookAuth];
	
	// Present the Controller Modally
	[self presentModalViewController:modalNavController animated:YES];
	
	// open webview with purhcase process started	
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?nBookId=%@&nFormat=%d",bookPurchaseURL,bookId, formatFlag]];
	NSLog(@"\nPurchase URL: %@\n\n",URL);
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:URL];
	[viewController.webView loadRequest:urlRequest];
	[viewController release];
}

-(IBAction)previewAction:(id)sender {
	//NSString *msg = @"Preview action goes here!";
	//[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	[self loadBookPreview:[self.book bookid]];
}

-(IBAction)purchaseBookAction:(id)sender {
	
	// book values
	NSString *bookTtl = [self.book title];
	NSString *bookAuth = [self.book authorname];
	//NSNumber *bookPrice = [self.book retailprice];
	//NSString *userId = [appDelegate userId];
	NSNumber *bookId = [self.book bookid];
		
	WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	//viewController.delegate = self;
	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
	//[modalNavController setNavigationBarHidden:YES];
	
	// setup view
	viewController.title = [NSString stringWithFormat:@"%@ by %@",bookTtl,bookAuth];
	
	// Present the Controller Modally
	[self presentModalViewController:modalNavController animated:YES];

	// open webview with purhcase process started	
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?nBookId=%@&nFormat=%d",bookPurchaseURL,bookId, formatFlag]];
	NSLog(@"\nPurchase URL: %@\n\n",URL);
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:URL];
	[viewController.webView loadRequest:urlRequest];
	[viewController release];
	
	// close the parent window
	//[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)readBookAction:(id)sender {
	//NSString *msg = [NSString stringWithFormat:@"Purchase Routine for Book \"%@\" Goes Here",[[self.book title] capitalizedString]];
	//[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	[self loadBookPreview:[self.book bookid]];
}

-(void)dismissBookView:(id)sender {
	
    // Call the delegate to dismiss the modal view
    //[delegate didDismissBookView];
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Load Book Preview

-(void)loadBookPreview:(NSNumber *)bookid {
	
	WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
	//viewController.delegate = self;
	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
	//[modalNavController setNavigationBarHidden:YES];
	
	// setup view
	viewController.title = [NSString stringWithFormat:@"%@ by %@",[self.book title],[self.book authorname]];
	
	// Present the Controller Modally
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",bookPreviewURL,bookid]];
	[self presentModalViewController:modalNavController animated:YES];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:URL];
	[viewController.webView loadRequest:urlRequest];
	
	[viewController release];
}


#pragma mark -
#pragma mark AgileBookCellDelegate methods

- (void)bookItem:(Book *)item didLoadCover:(UIImage *)bookImage
{
    [self.bookJacket setImage:bookImage];
    [spinner stopAnimating];
}

- (void)bookItem:(Book *)item couldNotLoadImageError:(NSError *)error
{
		// there was an error. so show the "default" book image...
	NSLog(@"Error occured trying to load a book image.");
	self.bookJacket.image = [UIImage imageNamed:@"defbook.png"];
    [spinner stopAnimating];
}


#pragma mark -
#pragma mark Activity Methods

-(void)startSpinner:(id)sender {
	
	[spinner startAnimating];
}

-(void)stopSpinner:(id)sender {
	
	[spinner stopAnimating];
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
	
	[bookTitle release];
	[bookAuthor release];
	[bookLength release];
	[bookLengthLabel release];
	[bookPublishDate release];
	[bookPublisher release];
	[bookIsbn release];
	[bookIsbnLabel release];
	[bookRatingsLabel release];
	[bookDetails release];
	[bookJacket release];
	[bookRating release];
	[bookFilesize release];
	[bookFilesizeLabel release];
	[image release];
	[book release];
	[spinner release];
	[bookRetailPrice release];
	[bookRetailLabel release];
	[networkQueue release];
	[appDelegate release];
	[managedObjectContext release];
	[numberFormatter release];
	[formatText release];
	[downloadButton release];
	[previewButton release];
	[buyButton release];
	[readButton release];
	[bookFormatLabel release];
	[bookFormat release];
}


@end
