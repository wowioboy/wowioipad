//
//  FeaturesViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright Pure Engineering 2010. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "FeaturesViewController.h"
#import "LoginViewController.h"
#import "WebViewController.h"
//#import "BookViewController.h"
#import "BookDetailController.h"
#import "Topbooks.h"
#import "Newreleases.h"
#import "Book.h"
#import "BookGridCell.h"
#import "Agilespace.h"
//#import "GridCellSelector.h"

@implementation FeaturesViewController

@synthesize releasesGrid, sellersGrid;
@synthesize backgroundImage;
@synthesize imageView, webView, mainContainer, mainScrollView, contentView, infoButton, pageControl, featuredItems;
@synthesize headline, featuredHeadlines, activityIndicator, activityLabel, webViewController;
@synthesize topSellersButton, topSellersLabel, bookButton;
@synthesize fetchedResultsController, managedObjectContext, bookViewController, aboutViewController;
//@synthesize loginController, modalNavController;
@synthesize appDelegate, networkQueue, _isLoggedIn, _contentLoaded;
@synthesize topbooks, featured, newReleases, gridList, featuredContent, webViewItems;
@synthesize topSellersView, newReleasesView, numberFormatter;
@synthesize agilePage, repeatingTimer, selectedBookid, selectedBook;

const CGFloat kFeatureScrollObjWidth	= 900.0;
const CGFloat kFeatureScrollObjHeight	= 330.0;
const NSUInteger kNumMaxFeaturedImages	= 6;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setMaximumFractionDigits:1];
	[numberFormatter setRoundingMode: NSNumberFormatterRoundUp];
	
	_contentLoaded = NO;
	
	//load up the app delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// set db context
	self.managedObjectContext = [self.appDelegate managedObjectContext];
	
	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);

	CGRect headFrm = [self.headline frame];
	headFrm.size.width = 337;
	headFrm.size.height = 21;
	headFrm.origin.y = 8;
	
	CGRect pageFrm = [self.pageControl frame];
	pageFrm.size.width = 78;
	pageFrm.size.height = 36;
	pageFrm.origin.y = 1;
	
	CGRect btnFrm = [self.topSellersButton frame];
	btnFrm.size.width = 72;
	btnFrm.size.height = 37;
	btnFrm.origin.y = 366;
	
	CGRect topFrm = [self.topSellersLabel frame];
	topFrm.size.width = 366;
	topFrm.size.height = 21;
	topFrm.origin.y = 9;
	
	if (isPortrait) {
		headFrm.origin.x = 80;
		pageFrm.origin.x = 760;
		btnFrm.origin.x = 754;
		topFrm.origin.x = 80;
		
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
		[self.topSellersLabel setFrame:topFrm];
		
	} else {
		headFrm.origin.x = 20;
		pageFrm.origin.x = 802;
		btnFrm.origin.x = 808;
		topFrm.origin.x = 20;
		
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
		[self.topSellersLabel setFrame:topFrm];
	}
	/*
	// init the grid view
	CGRect featGridFrame;
	featGridFrame.size.width = 900;
	featGridFrame.size.height = 630;
	featGridFrame.origin.x = 0;
	featGridFrame.origin.y = 407;
	
	self.theGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.theGridView.autoresizesSubviews = NO;
	self.theGridView.frame = featGridFrame;
	self.theGridView.delegate = self;
	self.theGridView.dataSource = self;
	self.theGridView.allowsSelection = YES;
	self.theGridView.backgroundColor = [self colorWithHexString:@"ecd2ad"];
	*/
	
	/*
	CGRect newGridFrame;
	newGridFrame.size.width = 900;
	newGridFrame.size.height = 530;
	newGridFrame.origin.x = 0;
	newGridFrame.origin.y = 1037;
	
	self.newReleasesGrid.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.newReleasesGrid.autoresizesSubviews = NO;
	self.newReleasesGrid.frame = newGridFrame;
	self.newReleasesGrid.delegate = self;
	self.newReleasesGrid.dataSource = self;
	self.newReleasesGrid.allowsSelection = YES;
	self.newReleasesGrid.backgroundColor = [self colorWithHexString:@"ecd2ad"];
	*/
	//[self.featuredContent addSubview:[self theGridView]];
	//[self.featuredContent addSubview:[self newReleasesGrid]];
	
	// set the webview delegate
	//webViewController
	//self.webView.delegate = self;
	
	[self.mainScrollView setContentSize:CGSizeMake(1024, (2562 + 500))];
	
}

-(void)viewWillAppear:(BOOL)animated {
	
	self._isLoggedIn = [appDelegate _isLoggedIn];
	
	if (!_isLoggedIn){
		
		LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
		viewController.delegate = self;
		
		UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
		modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
		[modalNavController setNavigationBarHidden:YES];
		
		// Present the Controller Modally	
		[self presentModalViewController:modalNavController animated:NO];
		
		[modalNavController release];
		[viewController release];
		return;
	}
	
	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	CGRect headFrm = [self.headline frame];
	headFrm.size.width = 337;
	headFrm.size.height = 21;
	headFrm.origin.y = 8;
	
	CGRect pageFrm = [self.pageControl frame];
	pageFrm.size.width = 78;
	pageFrm.size.height = 36;
	pageFrm.origin.y = 1;
	
	CGRect btnFrm = [self.topSellersButton frame];
	btnFrm.size.width = 72;
	btnFrm.size.height = 37;
	btnFrm.origin.y = 366;
	
	CGRect topFrm = [self.topSellersLabel frame];
	topFrm.size.width = 366;
	topFrm.size.height = 21;
	topFrm.origin.y = 9;
	
	if (isPortrait) {
		headFrm.origin.x = 80;
		pageFrm.origin.x = 760;
		btnFrm.origin.x = 754;
		topFrm.origin.x = 80;
		
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
		[self.topSellersLabel setFrame:topFrm];
		
	} else {
		headFrm.origin.x = 20;
		pageFrm.origin.x = 802;
		btnFrm.origin.x = 808;
		topFrm.origin.x = 20;
		
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
		[self.topSellersLabel setFrame:topFrm];
	}
	
	if (!_contentLoaded) {
		
		// load up agilespace items
		[self fetchAgileContentFromDB];
	
		// set up agilespace
		[self setupAgileContentSpace];
	
		// set the default headline
		//NSString *defHeadline = (NSString *)[self.featuredHeadlines objectAtIndex:0];
		NSArray *htmlObj = (NSArray *)[featuredItems objectAtIndex:0];
		NSString *defHeadline = [htmlObj valueForKey:@"details"];
		[self.headline setText:defHeadline];
	}
	// get top book data
	//self.topbooks = [appDelegate fetchBookDataFromDB:@"Topbooks" withSortDescriptor:@"title"];
	
	// get new release book data
	//self.newReleases = [appDelegate fetchBookDataFromDB:@"Newreleases" withSortDescriptor:@"title"];
	
	// load the grid
	//[self.theGridView reloadData];
	
	// load the book covers
	//[self loadContentForVisibleCells];
	//[self.releasesGrid loadContentForVisibleCells];
	//[self.sellersGrid loadContentForVisibleCells];
}



#pragma mark -
#pragma mark Housekeeping Methods

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	CGRect headFrm = [self.headline frame];
	headFrm.size.width = 337;
	headFrm.size.height = 21;
	headFrm.origin.y = 8;
	
	CGRect pageFrm = [self.pageControl frame];
	pageFrm.size.width = 78;
	pageFrm.size.height = 36;
	pageFrm.origin.y = 1;
	
	CGRect btnFrm = [self.topSellersButton frame];
	btnFrm.size.width = 72;
	btnFrm.size.height = 37;
	btnFrm.origin.y = 366;
	
	CGRect topFrm = [self.topSellersLabel frame];
	topFrm.size.width = 366;
	topFrm.size.height = 21;
	topFrm.origin.y = 9;
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		headFrm.origin.x = 80;
		pageFrm.origin.x = 760;
		btnFrm.origin.x = 754;
		topFrm.origin.x = 80;
		
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
		[self.topSellersLabel setFrame:topFrm];
		
		
	} else {
		headFrm.origin.x = 20;
		pageFrm.origin.x = 802;
		btnFrm.origin.x = 808;
		topFrm.origin.x = 20;
		
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
		[self.topSellersLabel setFrame:topFrm];
		
	}
	
	// set all of the ui elements frame sizes
	self.headline.frame = headFrm;
	self.pageControl.frame = pageFrm;
	self.topSellersButton.frame = btnFrm;
	self.topSellersLabel.frame = topFrm;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
	[topSellersLabel release];
	//webView.delegate = nil;
	[webViewItems release];
	[activityIndicator release];
	[activityLabel release];
	//[modalNavController release];
	[aboutViewController release];
}


#pragma mark -
#pragma mark Dismiss Modal View Methods

-(void)didDismissModalView {
	
	[self dismissModalViewControllerAnimated:YES];
}

-(void)didDismissBookView {
	
	[self dismissModalViewControllerAnimated:YES];
}

-(void)layoutFeaturedScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [contentView subviews];
	
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			curXLoc += (kFeatureScrollObjWidth);
		}
	}
	
	// set the content size so it can be scrollable
	int imgCnt = [featuredItems count];
	contentView.contentSize = CGSizeMake((imgCnt * kFeatureScrollObjWidth), kFeatureScrollObjHeight);
}

-(void)layoutFeaturedScrollContent
{
	UIWebView *view = nil;
	NSArray *subviews = [contentView subviews];
	
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIWebView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			curXLoc += (kFeatureScrollObjWidth);
		}
	}
	
	// set the content size so it can be scrollable
	int featCnt = [featuredItems count];
	contentView.contentSize = CGSizeMake((featCnt * kFeatureScrollObjWidth), kFeatureScrollObjHeight);
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollview {
	return webView;
}

// method to change to the default image
- (void)changeAgilePage:(id)sender {
    
	NSInteger fcnt = [featuredHeadlines count];
	NSInteger pcnt = self.agilePage - 1;
	
	// determine if I need to reset the current page
	if (pcnt == fcnt)
		self.agilePage = 0;
	
    // update the scroll view to the appropriate page
    CGRect frame = contentView.frame;
    frame.origin.x = frame.size.width * [self agilePage];
    frame.origin.y = 0;
    [contentView scrollRectToVisible:frame animated:YES];
	
	// change the page control
	[pageControl setCurrentPage:[self agilePage]];
	
	// change the headline
	[self swapHeadline:[self agilePage]];

	// increment the page counter
	self.agilePage++;
}


#pragma mark -
#pragma mark Agilespace Methods

-(void)fetchAgileContentFromDB {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Agilespace" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *agileDescriptor = [[NSSortDescriptor alloc] initWithKey:@"details" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:agileDescriptor, nil];
	//[fetchRequest setSortDescriptors:sortDescriptors];
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: NO agile data was found in the db!\n");
	}
	
	// clean up after yourself
	[agileDescriptor release];
	[sortDescriptors release];
	
	// set an image for each category
	//[self getCategoryImage:mutableFetchResults];
	
	// set the book ivar object
	self.featuredItems = mutableFetchResults;
	
	
	// set the content loaded flag
	_contentLoaded = YES;
}

-(void)setupAgileContentSpace {
	
	// load up promo images and headlines
	//self.featuredItems = [NSArray arrayWithObjects:@"promo_04.png",@"promo_01.png",@"promo_02.png",@"promo_03.png",nil];
	//self.featuredHeadlines = [NSArray arrayWithObjects:@"2010 WOWIO Comic Cruise",@"NOIR: Cold, Hard Fiction",@"ComicCon 2010",@"WOWIO",nil];
	self.featuredHeadlines = [[NSMutableArray alloc] init];
	self.webViewItems = [[NSMutableArray alloc] init];
	
	// Load up the view with an array of gallery images
	//contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScrollObjWidth, kScrollObjHeight)];
	[contentView setBackgroundColor:[UIColor blackColor]];
	[contentView setCanCancelContentTouches:YES];
	contentView.contentSize = CGSizeMake(kFeatureScrollObjWidth, kFeatureScrollObjHeight);
	//contentView.maximumZoomScale = 4.0;
	//contentView.minimumZoomScale = 0.75;
	contentView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	contentView.clipsToBounds = NO;		// default is NO, we want to restrict drawing within our scrollview
	contentView.scrollEnabled = YES;
	contentView.bounces = NO;
	contentView.alwaysBounceHorizontal = YES;
	contentView.alwaysBounceVertical = NO;
	contentView.delegate = self;
	
	// set this to NO if you want free-flowing scrolling rather than stopping at each photo
	contentView.pagingEnabled = YES;
	
	// load all the images from our bundle and add them to the scroll view
	NSUInteger i;
	int featCnt = [featuredItems count];
	for (i = 0; i < featCnt; i++)
	{
		NSArray *htmlObj = (NSArray *)[featuredItems objectAtIndex:i];
		NSString *htmlRaw = [htmlObj valueForKey:@"contenthtmlipad"];
		NSString *htmlTitle = [htmlObj valueForKey:@"details"];
		NSNumber *bookid = [htmlObj valueForKey:@"bookid"];
			//NSString *urlString = [NSString stringWithFormat:@"%@%@",singleBookURL,bookid];
				
		NSString *htmlPage = [NSString stringWithFormat:@"<html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=UTF-8\" /><title>%@</title><style> body{ margin:0px; padding:0px;}</style></head><body><a href=\"ipd://bookid=%@\">%@</a></body></html>",htmlTitle,bookid,htmlRaw];
		
		[self.featuredHeadlines insertObject:htmlObj atIndex:i];
		
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
		
		// stuff the value into the webview object
		webView = [[UIWebView alloc] init];
		webView.delegate = self;
		[webView loadHTMLString:htmlPage baseURL:baseURL];
		
		// setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
		CGRect rect = webView.frame;
		rect.size.height = kFeatureScrollObjHeight;
		rect.size.width = kFeatureScrollObjWidth;
		webView.frame = rect;
		webView.tag = i+1;	// tag our images for later use when we place them in serial fashion
		[self.webViewItems insertObject:webView atIndex:i];
		[contentView addSubview:[self.webViewItems objectAtIndex:i]];
		//webView.delegate = nil;
		//[webView release];
	}
	
	[self layoutFeaturedScrollContent];	// now place the photos in a serial layout within the scrollview
	
	// define the page control
	NSInteger noofPages = [featuredItems count];
	[pageControl setNumberOfPages:noofPages];
	[pageControl setCurrentPage:0];
	[pageControl setBackgroundColor:[UIColor clearColor]];
	[pageControl setAlpha:85.5];
	[pageControl setOpaque:NO];
	//[self.view insertSubview:pageControl aboveSubview:contentView]; // add the page control to the main view above the images 
	
	// change to the appropriate image
	agilePage = 0;

	if (noofPages > 1) {
		
			// instantiate the timer
			NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0
															  target:self selector:@selector(changeAgilePage:)
															userInfo:nil repeats:YES];
			self.repeatingTimer = timer;
	}
}


#pragma mark -
#pragma mark WebView Delegate

-(void)webViewDidStartLoad:(UIWebView *)wv {
	
	[self.activityIndicator startAnimating];
	[self.activityLabel setHidden:NO];
	NSLog(@"Starting agile space load...");
}

-(void)webViewDidFinishLoad:(UIWebView *)wv {
	
	[self.activityIndicator stopAnimating];
	[self.activityLabel setHidden:YES];
	NSLog(@"load finished!");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	NSLog(@"Web View Load Failed with Error: %@",[error localizedDescription]);
}

- (BOOL)webView:(UIWebView*)wv shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSError *error;
	NSInteger fetchCount;

	// detect user content tap
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		
		NSLog(@"Agile item was tapped!");
		
		
		NSURL *URL = [request URL];
		if ([[URL scheme] isEqualToString:@"ipd"]) {
			//[[UIApplication sharedApplication] openURL: URL];
			
				//WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
				//UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
				//modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
			
			// setup view
			NSInteger currentTag; 
			currentTag = wv.tag - 1;
			NSArray *htmlObj = (NSArray *)[featuredItems objectAtIndex:currentTag];
			NSNumber *bookid = [htmlObj valueForKey:@"bookid"];
			
				// save the book id
			[self setSelectedBookid:bookid];
			
				// see if we have this book in the db already
			if (![[self fetchedResultsController] performFetch:&error])
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			
			// check if we have the book already... if we do, show it. Otherwise download it.
			fetchCount = [[fetchedResultsController fetchedObjects] count];
			if (fetchCount > 0) {
				
				NSLog(@"grabbing book from db");
				NSString *theTitle = [htmlObj valueForKey:@"details"];
				[self showBook:bookid andTitle:theTitle];
				
			} else {
				
				NSLog(@"grabbing book from wowio");
				[self fetchBookData:bookid];
				
			}
			
			// Present the Controller Modally	
			//[self presentModalViewController:modalNavController animated:YES];
			//NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:URL];
			//[viewController.webView loadRequest:urlRequest];
		}
		return NO;
	}
	return YES;
}


#pragma mark -
#pragma mark Show Book

-(void)showBook:(NSNumber*)bookid andTitle:(NSString*)bookTitle {
	
	[self fetchBookDataFromDB:bookid];
	BookDetailController *viewController = [[BookDetailController alloc] initWithNibName:@"BookView" bundle:nil];
	 
	//NSLog(@"Selected Book: %@",self.selectedBook);
	
		// add book to the presented view
	viewController.managedObjectContext = self.managedObjectContext;
	viewController.book = self.selectedBook;
	viewController.selectedBookid = bookid;
	viewController.title = bookTitle;
	 
	
	// Present the Controller Modally	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationPageSheet;	 
	[self presentModalViewController:modalNavController animated:YES];
}


#pragma mark -
#pragma mark Scrollview Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	CGFloat pageWidth = [contentView bounds].size.width;
	int CurrentPage = (scrollView.contentOffset.x / pageWidth);
	//NSLog(@"You just scrolled to page:%d\n",CurrentPage);
	[pageControl setCurrentPage:CurrentPage];
	
	// change the headline
	[self swapHeadline:CurrentPage];
}


#pragma mark -
#pragma mark Touches Events

-(void)touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
	
	NSLog(@"touches began!");
}


#pragma mark -
#pragma mark Panel Methods

-(IBAction)showAbout:(id)sender {
		
	//NSLog(@"about button touched");
	aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
	modalNavController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:modalNavController animated:YES];	
}

-(IBAction)showAll:(id)sender {
	
	NSLog(@"A show all button was tapped\nSender:%@",sender);
}

-(void)swapHeadline:(int)page {
	
	int fcnt = [self.featuredHeadlines count];
	if (page == fcnt)
		page--;
	
	//NSLog(@"\nPage: %d",[self agilePage]);
	//NSLog(@"\nHeadline Count: %d",[self.featuredHeadlines count]);
	NSArray *htmlObj = (NSArray *)[self.featuredHeadlines objectAtIndex:page];
	NSString *headlineStr = (NSString *)[htmlObj valueForKey:@"details"];
	[self.headline setText:headlineStr]; 
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
    
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:managedObjectContext];
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

-(void)fetchBookDataFromDB:(NSNumber*)bookid {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
	// set the filter predicate
	NSPredicate *predicate = [NSPredicate
							  predicateWithFormat:@"bookid=%@",bookid];
	[fetchRequest setPredicate:predicate];
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: NO user data was found in the db!\n");
	}
	
	// set the user ivar object
	self.selectedBook = (Book *)[mutableFetchResults objectAtIndex:0];
	//NSLog(@"Selected Book:\n%@",selectedBook);
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
#pragma mark Fetch Methods

-(void)fetchBookData:(NSNumber*)bookid {
	
	if ([self internetCheck]) {
		
			// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(fetchBookFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(fetchBookFailed:)];
		
			// build the request
		NSString *urlString = [NSString stringWithFormat:@"%@%@",singleBookURL,bookid];
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] 
										initWithURL:[NSURL 
													 URLWithString:urlString]] autorelease];
		[request setTimeOutSeconds:20];
		[request setRequestMethod:@"GET"];
			
			// add the request to the transmission queue and set it off
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
		
	}
}

- (void)fetchBookFailed:(ASIHTTPRequest *)request
{
	NSString *errorString = @"A communication error occurred.\n\nPlease retry your request later.";
	[appDelegate alertWithMessage:errorString withTitle:@"WOWIO"];
	return;
}

- (void)fetchBookFinished:(ASIHTTPRequest *)request
{
	
	NSString *rsltStr = [request responseString];
		//NSDictionary *responseHeaders = [request responseHeaders];
		//NSDictionary *requestHeaders = [request requestHeaders];
		
		// Convert JSON resultset to Array
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableDictionary *feed = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"bookplus"];
	
	NSLog(@"\n%@\n\n",obj);
	
		// Save Agile book data to the db
	[self writeBookDataToDB:obj];
}


#pragma mark -
#pragma mark Database Methods

-(void)removeData:(NSString*)theEntity {
	
	int i;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity;
	if (entity = [NSEntityDescription entityForName:theEntity 
							 inManagedObjectContext:self.managedObjectContext]) {
		
		[fetchRequest setEntity:entity];
		
		NSError *error;
		NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];		
		[fetchRequest release];
		
		for (i = 0; i<[items count]; i++) {
			NSManagedObject *managedObject = [items objectAtIndex:i];		
			[self.managedObjectContext deleteObject:managedObject];
		}
	}
}

-(void)writeBookDataToDB:(NSMutableArray *)data {
	
		// flush existing data from selected table
		//[self removeData:@"Book"];
	
	
	Book *book = (Book *)[NSEntityDescription 
									insertNewObjectForEntityForName:@"Book" 
									inManagedObjectContext:self.managedObjectContext];
			
	NSArray *obj = [data objectAtIndex:0];
	NSString *authorname = [obj valueForKey:@"authorname"];
	NSString *availdate = [obj valueForKey:@"availdate"];
	NSNumber *bookid = [obj valueForKey:@"bookid"];
	NSString *coverimagepath_l = [obj valueForKey:@"coverimagepath_l"];
	NSString *coverimagepath_s = [obj valueForKey:@"coverimagepath_s"];
	NSString *imagesubpath = [obj valueForKey:@"imagesubpath"];	
	NSString *details = [obj valueForKey:@"description"];
	NSNumber *mainbookcategoryid = [obj valueForKey:@"mainbookcategoryid"];
	NSString *publicationdate = [obj valueForKey:@"publicationdate"];
	NSString *booktitle = [obj valueForKey:@"title"];
	NSNumber *retailprice = [obj valueForKey:@"retailprice"];
	NSNumber *pagecount = [obj valueForKey:@"pagecount"];
	NSNumber *publisherid = [obj valueForKey:@"publisherid"];
	NSString *publishername = [obj valueForKey:@"publishername"];
	NSString *sorttitle = [obj valueForKey:@"sorttitle"];
	
	NSString *ade_epub_filesize = [obj valueForKey:@"ade_epub_filesize"];
	NSNumber *ade_epub_retailprice = [obj valueForKey:@"ade_epub_retailprice"];
	NSString *ade_epub_sku13 = [obj valueForKey:@"ade_epub_sku13"];
	NSString *ade_pdf_filesize = [obj valueForKey:@"ade_pdf_filesize"];
	NSNumber *ade_pdf_retailprice = [obj valueForKey:@"ade_pdf_retailprice"];
	NSString *ade_pdf_sku13 = [obj valueForKey:@"ade_pdf_sku13"];
	
	NSNumber *bformatade_epub = [obj valueForKey:@"bformatade_epub"];
	NSNumber *bformatade_pdf = [obj valueForKey:@"bformatade_pdf"];
	
	NSString *epub_filesize = [obj valueForKey:@"epub_filesize"];
	NSNumber *epub_retailprice = [obj valueForKey:@"epub_retailprice"];
	NSString *epub_sku13 = [obj valueForKey:@"epub_sku13"];
	NSString *ereader_filesize = [obj valueForKey:@"ereader_filesize"];
	NSNumber *ereader_retailprice = [obj valueForKey:@"ereader_retailprice"];
	NSString *ereader_sku13 = [obj valueForKey:@"ereader_sku13"];
	
	if ([ade_epub_filesize isKindOfClass:[NSNull class]])
		ade_epub_filesize = @"";
	
	if ([ade_epub_retailprice isKindOfClass:[NSNull class]])
		ade_epub_retailprice = [NSNumber numberWithFloat:0.00];
	
	if ([ade_epub_sku13 isKindOfClass:[NSNull class]])
		ade_epub_sku13 = @"";
	
	if ([ade_pdf_filesize isKindOfClass:[NSNull class]])
		ade_pdf_filesize = @"";
	
	if ([ade_pdf_retailprice isKindOfClass:[NSNull class]])
		ade_pdf_retailprice = [NSNumber numberWithFloat:0.00];
	
	if ([ade_pdf_sku13 isKindOfClass:[NSNull class]])
		ade_pdf_sku13 = @"";
	
	if ([bformatade_epub isKindOfClass:[NSNull class]])
		bformatade_epub = 0;
	
	if ([bformatade_pdf isKindOfClass:[NSNull class]])
		bformatade_pdf = 0;
	
	if ([epub_filesize isKindOfClass:[NSNull class]])
		epub_filesize = @"";
	
	if ([epub_retailprice isKindOfClass:[NSNull class]])
		epub_retailprice = [NSNumber numberWithFloat:0.00];
	
	if ([epub_sku13 isKindOfClass:[NSNull class]])
		epub_sku13 = @"";
	
	if ([ereader_filesize isKindOfClass:[NSNull class]])
		ereader_filesize = @"";
	
	if ([ereader_retailprice isKindOfClass:[NSNull class]])
		ereader_retailprice = [NSNumber numberWithFloat:0.00];
	
	if ([ereader_sku13 isKindOfClass:[NSNull class]])
		ereader_sku13 = @"";
	
	if ([coverimagepath_l isKindOfClass:[NSNull class]])
		coverimagepath_l = @"";
	
	if ([coverimagepath_s isKindOfClass:[NSNull class]])
		coverimagepath_s = @"";
	
	if ([imagesubpath isKindOfClass:[NSNull class]])
		imagesubpath = @"";
	
	if ([publishername isKindOfClass:[NSNull class]])
		publishername = @"";
	
	if ([sorttitle isKindOfClass:[NSNull class]])
		sorttitle = @"";
	
	NSNumber *becommerce = [obj valueForKey:@"becommerce"];
	NSNumber *bnodrm = [obj valueForKey:@"bnodrm"];
	NSNumber *bavailable = [obj valueForKey:@"bavailable"];
	NSNumber *bbooksponsor = [obj valueForKey:@"bbooksponsor"];
	NSString *isbn = [obj valueForKey:@"isbn"];
	NSString *indexname = [obj valueForKey:@"indexname"];
	if ([indexname isKindOfClass:[NSNull class]])
		indexname = @"";

	NSNumber *purchased = [obj valueForKey:@"purchased"];
	NSNumber *previewpagecount = [obj valueForKey:@"previewpagecount"];
	NSNumber *recstatus = [obj valueForKey:@"recstatus"];
	NSNumber *ratingcount = [obj valueForKey:@"ratingcount"];
	NSString *ratingString = [numberFormatter stringFromNumber:ratingcount];
	NSNumber *avgrating = [obj valueForKey:@"avgrating"];
	NSString *avgRatingString = [numberFormatter stringFromNumber:avgrating];
	avgRatingString = [avgRatingString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
	
	[book setBookid:bookid];
	[book setIs_agile:[NSNumber numberWithInt:1]];
	[book setSorttitle:sorttitle];
	[book setAde_epub_filesize:ade_epub_filesize];
	[book setAde_epub_retailprice:ade_epub_retailprice];
	[book setAde_epub_sku13:ade_epub_sku13];
	[book setAde_pdf_filesize:ade_pdf_filesize];
	[book setAde_pdf_retailprice:ade_pdf_retailprice];
	[book setAde_pdf_sku13:ade_pdf_sku13];
	[book setBformatade_epub:bformatade_epub];
	[book setBformatade_pdf:bformatade_pdf];
	[book setEpub_filesize:epub_filesize];
	[book setEpub_retailprice:epub_retailprice];
	[book setEpub_sku13:epub_sku13];
	[book setEreader_filesize:ereader_filesize];
	[book setEreader_retailprice:ereader_retailprice];
	[book setEreader_sku13:ereader_sku13];
	[book setBecommerce:becommerce];
	[book setBnodrm:bnodrm];
	[book setBavailable:bavailable];
	[book setAvaildate:availdate];
	[book setBbooksponsor:bbooksponsor];
	[book setIsbn:isbn];
	[book setIndexname:indexname];
	[book setCoverimagepath_l:coverimagepath_l];
	[book setCoverimagepath_s:coverimagepath_s];
	[book setImagesubpath:imagesubpath];
	[book setDetails:details];
	[book setMainbookcategoryid:mainbookcategoryid];
	[book setPublicationdate:publicationdate];
	[book setPurchased:purchased];
	[book setTitle:booktitle];
	[book setRetailprice:retailprice];
	[book setPagecount:pagecount];
	[book setPreviewpagecount:previewpagecount];
	[book setAuthorname:authorname];
	[book setPublisherid:publisherid];
	[book setPublishername:publishername];
	[book setRecstatus:recstatus];
	[book setRatingcount:ratingString];
	[book setAvgrating:avgRatingString];
	
		// write it to db
	[self saveAction];
	
}

- (void)saveAction {
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
		exit(-1);
	}
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


@end
