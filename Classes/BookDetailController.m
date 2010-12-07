//
//  BookDetailController.m
//  WOWIO
//
//  Created by Lawrence Leach on 9/13/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "BookDetailController.h"
#import "WebViewController.h"
#import "Library.h"
#import "Book.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@implementation BookDetailController
@synthesize bookTitle, bookAuthor, bookLength, bookPublishDate, bookPublisher, bookIsbn, bookIsbnLabel, bookRatingsLabel, bookDetails, bookJacket, bookRating;
@synthesize image, spinner, bookRetailPrice, bookRetailLabel;
@synthesize book, appDelegate, networkQueue;
@synthesize managedObjectContext, fetchedResultsController;
@synthesize numberFormatter, selectedBookid;
@synthesize downloadButton, previewButton, buyButton, readButton;
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
	
	// setup the number formatter
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
	// load a back button to return to the main panel
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
	
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	
}

-(void)viewDidAppear:(BOOL)animated {
	
		// set book details
	[book setDelegate:self];
	self.title = [book title];
	
	NSNumber *previewpagecount = [book previewpagecount];
	NSNumber *pagecount = [book pagecount];
	NSNumber *purchased = [book purchased];
	
	[self.bookTitle setNumberOfLines:2];
	[self.bookTitle setLineBreakMode:UILineBreakModeWordWrap];
	[self.bookTitle setAdjustsFontSizeToFitWidth:NO];
	[self.bookTitle setText:[book title]];
	
	[self.bookAuthor setText:[book authorname]];
	[self.bookPublisher setText:[book publishername]];
	if ([previewpagecount isEqualToNumber:[NSNumber numberWithInt:0]])
		[self.bookLength setText:[NSString stringWithFormat:@"%@ pages",pagecount]];
	else 
		[self.bookLength setText:[NSString stringWithFormat:@"%@ pages (%@ page preview)",pagecount, previewpagecount]];
	
	[self.bookPublishDate setText:[book publicationdate]];
	[self.bookIsbnLabel setHidden:NO];
	[self.bookIsbn setHidden:NO];
	[self.bookIsbn setText:[book isbn]];
	
	[self.bookRetailLabel setHidden:NO];
	[self.bookRetailPrice setHidden:NO];
	
	
	// buttons
	if ([previewpagecount isEqualToNumber:[NSNumber numberWithInt:0]] || ![purchased isEqualToNumber:[NSNumber numberWithInt:0]]) {
		[self.readButton setHidden:NO];
		[self.previewButton setHidden:YES];
		//[self.buyButton setHidden:NO];
	} else {
		[self.readButton setHidden:YES];
		[self.previewButton setHidden:NO];
		//[self.buyButton setHidden:YES];
	}
	
	[self.downloadButton setHidden:YES];
	
	
	// format the display of the retail price
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
			priceamt = @"Get PDF FREE";
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
	
	// format rating stars
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
	
	// start activity indicator
	//[spinner startAnimating];
	
	// set book jacket image
	[self.bookJacket setImage:[book bookCover]];
	
	// format book details display
	[self.bookDetails setFont:[UIFont systemFontOfSize:14.0]];
	[self.bookDetails setText:[book details]];
}



#pragma mark -
#pragma mark Button Methods

-(IBAction)downloadAction:(id)sender {
	NSString *msg = @"Download action goes here!";
	[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
}

-(IBAction)previewAction:(id)sender {
	NSString *msg = [NSString stringWithFormat:@"Preview action goes here!",[self selectedBookid]];
	[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	[self loadBookPreview:[self selectedBookid]];
}

-(IBAction)purchaseAction:(id)sender {
	NSString *msg = [NSString stringWithFormat:@"Purchase Routine for Book \"%@\" Goes Here",[[self.book title] capitalizedString]];
	[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	//[self purchaseBook:[self selectedBookid]];
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
	modalNavController.modalPresentationStyle = UIModalPresentationPageSheet;
	//[modalNavController setNavigationBarHidden:YES];
	
	// setup view
	viewController.title = @"WOWIO";
	
	// Present the Controller Modally
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",bookPreviewURL,bookid]];
	[self presentModalViewController:modalNavController animated:YES];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:URL];
	[viewController.webView loadRequest:urlRequest];
	
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
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
    
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Agilebook" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// set the filter predicate
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"bookid=%@",[self selectedBookid]];
	[fetchRequest setPredicate:predicate];
	
	
	// Create the sort descriptors array.
	NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sorttitle" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:titleDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[titleDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

-(void)fetchBookDataFromDB {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Agilebook" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
	// set the filter predicate
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"bookid=%@",[self selectedBookid]];
	[fetchRequest setPredicate:predicate];
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: NO user data was found in the db!\n");
	}
	
	// set the user ivar object
	self.book = (Book *)[mutableFetchResults objectAtIndex:0];
	
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
