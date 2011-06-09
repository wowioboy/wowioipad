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
#import "Featuredpublishers.h"
#import "LoginViewController.h"
#import "WebViewController.h"
#import "BookViewController.h"
//#import "BookDetailController.h"
#import "Book.h"
#import "BookGridCell.h"
#import "Agilespace.h"
//#import "GridCellSelector.h"

@implementation FeaturesViewController

	//@synthesize sellersGrid;
@synthesize backgroundImage;
@synthesize imageView, webView, mainContainer, mainScrollView, topSellersView, contentView, infoButton, pageControl, featuredItems;
@synthesize headline, featuredHeadlines, activityIndicator, featLoadIndicator, topLoadIndicator, activityLabel, webViewController;
@synthesize topSellersButton, topSellersLabel, bookButton;
@synthesize fetchedResultsController, managedObjectContext, aboutViewController, topSellersController;
//@synthesize loginController, modalNavController;
@synthesize appDelegate, networkQueue, _isLoggedIn, _contentLoaded, _topsellersLoaded;
@synthesize topbooks, featured, newReleases, gridList, webViewItems;
@synthesize numberFormatter, delegate, fetchCount, urlArray;
@synthesize agilePage, repeatingTimer, selectedBookid, selectedBook;
@synthesize theGridView=_gridView;
@synthesize gridData;

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
	_featuresFetched = NO;
	
	//load up the app delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// set db context
	self.managedObjectContext = [self.appDelegate managedObjectContext];
	
	[self.mainScrollView setAutoresizesSubviews:YES];
	
	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);

	CGRect headFrm = [self.headline frame];
	headFrm.size.width = 337;
	headFrm.size.height = 21;
	headFrm.origin.y = 10;
	
	CGRect pageFrm = [self.pageControl frame];
	pageFrm.size.width = 100;
	pageFrm.size.height = 36;
	pageFrm.origin.y = 4;
	
	CGRect btnFrm = [self.topSellersButton frame];
	btnFrm.size.width = 72;
	btnFrm.size.height = 37;
	btnFrm.origin.y = 366;
	
	CGRect topFrm = [self.topSellersLabel frame];
	topFrm.size.width = 366;
	topFrm.size.height = 21;
	topFrm.origin.y = 9;
	
	UIImage *bgImage;
	CGRect featGridFrame;

	if (isPortrait) {
		
		[self.mainScrollView setContentSize:CGSizeMake(690, (1024 + 500))];
		
		headFrm.origin.x = 95;
		pageFrm.origin.x = 700;
		btnFrm.origin.x = 754;
		topFrm.origin.x = 95;
		
		bgImage = [UIImage imageNamed:@"Default-Portrait.png"];
		
		featGridFrame.origin.x = 60;
		featGridFrame.size.width = 770;

		
	} else {
		
		[self.mainScrollView setContentSize:CGSizeMake(1024, (1024 + 500))];
		
		headFrm.origin.x = 20;
		pageFrm.origin.x = 802;
		btnFrm.origin.x = 808;
		topFrm.origin.x = 20;
		
		bgImage = [UIImage imageNamed:@"Default-Landscape.png"];
		
		featGridFrame.origin.x = 0;
		featGridFrame.size.width = 900;

	}
	
	[self.topSellersLabel setFrame:topFrm];
	[self.headline setFrame:headFrm];
	[self.pageControl setFrame:pageFrm];
	[self.backgroundImage setImage:bgImage];

		// SET THE BOOK GRID
	 featGridFrame.size.height = 3000;
	 featGridFrame.origin.y = 40;
	 
	 self.theGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	 self.theGridView.autoresizesSubviews = YES;
	 //self.theGridView.frame = featGridFrame;
	 self.theGridView.bounces = YES;
	 self.theGridView.scrollEnabled = YES;
	 self.theGridView.delegate = self;
	 self.theGridView.dataSource = self;
	 self.theGridView.allowsSelection = YES;
	 self.theGridView.backgroundColor = [UIColor clearColor];
	
	//[self.featuredContent addSubview:[self theGridView]];
	//[self.featuredContent addSubview:[self newReleasesGrid]];
	
	// set the webview delegate
	//webViewController
	//self.webView.delegate = self;
	
	topSellersView = [[UIView alloc] init];
	
	
		// LOAD UP BOOK FEATURES
	fetchCount = 0;
	
		// init the data array
	self.urlArray = [NSArray arrayWithObjects:topBooksURL, newReleasesURL, bookCatCountURL, homepageAgileSpaceURL, nil];
		//self.urlArray = [NSArray arrayWithObjects:bookCatCountURL, topBooksURL, newReleasesURL, homepageAgileSpaceURL, nil];
	
		// zap book data
	[self removeData:@"Book"];
	[self removeData:@"Agilespace"];
	
		// get all of the data
	[self fetchWowioData];
}

-(void)viewWillAppear:(BOOL)animated {
	
	/*
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
	*/
	
	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	CGRect headFrm = [self.headline frame];
	headFrm.size.width = 337;
	headFrm.size.height = 21;
	headFrm.origin.y = 10;
	
	CGRect pageFrm = [self.pageControl frame];
	pageFrm.size.width = 100;
	pageFrm.size.height = 36;
	pageFrm.origin.y = 4;
	
	CGRect btnFrm = [self.topSellersButton frame];
	btnFrm.size.width = 72;
	btnFrm.size.height = 37;
	btnFrm.origin.y = 366;
	
	CGRect topFrm = [self.topSellersLabel frame];
	topFrm.size.width = 366;
	topFrm.size.height = 21;
	topFrm.origin.y = 9;
	
	CGRect mainScrollFrame;
	UIImage *bgImage;
	
	if (isPortrait) {
		headFrm.origin.x = 95;
		pageFrm.origin.x = 700;
		btnFrm.origin.x = 754;
		topFrm.origin.x = 95;
		
		mainScrollFrame.size.width = 730;
		mainScrollFrame.size.height = 1024;
		mainScrollFrame.origin.x = 20;
		mainScrollFrame.origin.y = 44;
		[self.mainScrollView setContentSize:CGSizeMake(690, (1024 + 500))];
		
		bgImage = [UIImage imageNamed:@"Default-Portrait.png"];
		
	} else {
		headFrm.origin.x = 20;
		pageFrm.origin.x = 802;
		btnFrm.origin.x = 808;
		topFrm.origin.x = 20;
		
		mainScrollFrame.size.width = 1024;
		mainScrollFrame.size.height = 730;
		mainScrollFrame.origin.x = 0;
		mainScrollFrame.origin.y = 44;
		[self.mainScrollView setContentSize:CGSizeMake(1024, (1024 + 500))];
		
		bgImage = [UIImage imageNamed:@"Default-Landscape.png"];
	}

	[self.mainScrollView setFrame:mainScrollFrame];
	[self.backgroundImage setImage:bgImage];
	[self.topSellersLabel setFrame:topFrm];
	[self.headline setFrame:headFrm];
	[self.pageControl setFrame:pageFrm];
	
	if (!_contentLoaded) {
		
		// load up agilespace items
		//[self fetchAgileContentFromDB];
	
		// set up agilespace
		//[self setupAgileContentSpace];
	
		// set the default headline
		//NSString *defHeadline = (NSString *)[self.featuredHeadlines objectAtIndex:0];
		NSArray *htmlObj = (NSArray *)[featuredItems objectAtIndex:0];
		NSString *defHeadline = [htmlObj valueForKey:@"details"];
		[self.headline setText:defHeadline];
		
	}
}
/*
-(void)viewDidAppear:(BOOL)animated
{
	if (!_topsellersLoaded) {
		
		
			// LOAD UP THE TOP SELLERS
		[self performSelector:@selector(getTopSellersFromDB:)];
		
			//NSLog(@"\nNo. of Top Sellers: %d\n",[self.gridData count]);
		
		[self.theGridView reloadData];
		
			// ADD THE BOOK GRID VIEW TO THE DISPLAY
			//[self.topSellersView addSubview:self.theGridView];
		
			// SET THE FLAG TO INDICATE TOP SELLERS HAS LOADED
		_topsellersLoaded = YES;
		
	} else {
		[self.theGridView reloadData];
	}

}
*/

#pragma mark -
#pragma mark Housekeeping Methods

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

/*
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	CGRect headFrm = [self.headline frame];
	headFrm.size.width = 337;
	headFrm.size.height = 21;
	headFrm.origin.y = 10;
	
	CGRect pageFrm = [self.pageControl frame];
	pageFrm.size.width = 100;
	pageFrm.size.height = 36;
	pageFrm.origin.y = 4;
	
	CGRect btnFrm = [self.topSellersButton frame];
	btnFrm.size.width = 72;
	btnFrm.size.height = 37;
	btnFrm.origin.y = 366;
	
	CGRect topFrm = [self.topSellersLabel frame];
	topFrm.size.width = 366;
	topFrm.size.height = 21;
	topFrm.origin.y = 9;
	
	CGRect mainScrollFrame;
	UIImage *bgImage;
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		headFrm.origin.x = 95;
		pageFrm.origin.x = 700;
		btnFrm.origin.x = 754;
		topFrm.origin.x = 95;
		
		mainScrollFrame.size.width = 690;
		mainScrollFrame.size.height = 1524;
		mainScrollFrame.origin.x = 20;
		mainScrollFrame.origin.y = 44;
		
		[self.mainScrollView setContentSize:CGSizeMake(690, (1024 + 500))];
		
		bgImage = [UIImage imageNamed:@"Default-Portrait.png"];
		
	} else {
		headFrm.origin.x = 20;
		pageFrm.origin.x = 802;
		btnFrm.origin.x = 808;
		topFrm.origin.x = 20;
		
		mainScrollFrame.size.width = 1024;
		mainScrollFrame.size.height = 1524;
		mainScrollFrame.origin.x = 0;
		mainScrollFrame.origin.y = 44;
		
		[self.mainScrollView setContentSize:CGSizeMake(1024, (1024 + 500))];
		
		bgImage = [UIImage imageNamed:@"Default-Landscape.png"];
	}
	
	// set all of the ui elements frame sizes
	//self.mainScrollView.frame = mainScrollFrame;
	self.headline.frame = headFrm;
	self.pageControl.frame = pageFrm;
	self.topSellersButton.frame = btnFrm;
	self.topSellersLabel.frame = topFrm;

		// SET THE BG IMAGE
	[self.backgroundImage setImage:bgImage];
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

- (void)dealloc {
    [super dealloc];
	
	[backgroundImage release];
	[topSellersLabel release];
	//webView.delegate = nil;
	[webViewItems release];
	[activityIndicator release];
	[featLoadIndicator release];
	[topLoadIndicator release];
	[activityLabel release];
	//[modalNavController release];
	[aboutViewController release];
	[imageView release];
	[webView release];
	[mainContainer release];
	[mainScrollView release];
	[topSellersView release];
	[contentView release];
	[infoButton release];
	[pageControl release];
	[featuredItems release];
	[headline release];
	[featuredHeadlines release];
	[webViewController release];
	[topSellersButton release];
	[bookButton release];
	[fetchedResultsController release];
	[managedObjectContext release];
	[aboutViewController release];
	[topSellersController release];
	[appDelegate release];
	[networkQueue release];
	[topbooks release];
	[gridList release];
	[webViewItems release];
	[numberFormatter release];
	[repeatingTimer release];
	[selectedBookid release];
	[selectedBook release];
	[_gridView release];
	[gridData release];
}


#pragma mark -
#pragma mark Grid View Data Source & Delegates

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return [self.gridData count];
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString * GridCellIdentifier = @"GridCellIdentifier";
    
	
	Book *citem = (Book*)[gridData objectAtIndex:index];
    AQGridViewCell * cell = nil;
    BookGridCell *gridCell = (BookGridCell *)[aGridView dequeueReusableCellWithIdentifier: GridCellIdentifier];

		//NSLog(@"\nFeature Title: %@\n",[citem title]);
	
	if (gridCell == nil)
	{
		gridCell = [[[BookGridCell alloc] initWithFrame: CGRectMake(200.0, 150.0, 200.0, 150.0) 
										reuseIdentifier: GridCellIdentifier] autorelease];
		gridCell.selectionStyle = AQGridViewCellSelectionStyleGlow;
	}
	gridCell.delegate = self;
	gridCell.item = citem;
	
	cell = gridCell;
    return cell;
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
		//self.gridData = [appDelegate fetchBookDataFromDB:@"Book" withSortDescriptor:@"title"];
		//[self performSelector:@selector(getBooksFromDB:)];
		//NSLog(@"\nTapped A Book In The Grid!\n\n");
	
		// deselect the selected grid cell
	[self.theGridView deselectItemAtIndex:index animated:NO];
	
	BookViewController *viewController = [[BookViewController alloc] initWithNibName:@"BookDetailView" bundle:nil];
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationPageSheet;
		//[modalNavController setNavigationBarHidden:YES];
	
		// add book to the presented view
	viewController.managedObjectContext = self.managedObjectContext;
	Book *book = (Book*)[gridData objectAtIndex:index];
	[viewController setBook:book];
	
		// Present the Controller Modally	
	[self presentModalViewController:modalNavController animated:YES];
	
	[viewController release];
		//[modalNavController release];
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(200.0, 150.0) );
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
		//NSLog(@"Starting agile space load...");
}

-(void)webViewDidFinishLoad:(UIWebView *)wv {
	
	[self.activityIndicator stopAnimating];
	[self.activityLabel setHidden:YES];
		//NSLog(@"agile space load item finished!");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	NSLog(@"Web View Load Failed with Error: %@",[error localizedDescription]);
}

- (BOOL)webView:(UIWebView*)wv shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSError *error;
		//NSInteger fetchCount;

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
			/* fetchCount = [[fetchedResultsController fetchedObjects] count];
			if (fetchCount > 0) {
				
					NSLog(@"grabbing book from db");
					//NSString *theTitle = [htmlObj valueForKey:@"details"];
				[self showBook:bookid];
				
			} else {
				
					NSLog(@"grabbing book from wowio");
				[self fetchAgileBookData:bookid];
				
			}*/
			[self fetchAgileBookData:bookid];
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

-(void)showBook:(NSNumber*)bookid {
	
	[self fetchBookDataFromDB:bookid];
	BookViewController *viewController = [[BookViewController alloc] initWithNibName:@"BookDetailView" bundle:nil];
	 
	//NSLog(@"Selected Book: %@",self.selectedBook);
	
		// add book to the presented view
	viewController.managedObjectContext = self.managedObjectContext;
	viewController.book = self.selectedBook;
		//viewController.selectedBookid = bookid;
	viewController.title = [self.selectedBook title];
	 
	
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
	aboutViewController.delegate = self;
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

-(void)fetchWowioData {
	
	if ([self internetCheck]) {
		
		
			//NSString *sessionId = [appDelegate sessionId];
		
			// start the load indicator
		[self.featLoadIndicator startAnimating];
		[self.topLoadIndicator startAnimating];
		
			// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
		
		int i;
		int urlCnt = [self.urlArray count];
		for (i=0; i<urlCnt; i++) {
			
			NSString *url = (NSString *) [urlArray objectAtIndex:i];
			
				// build the request
			ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] 
										initWithURL:[NSURL 
													 URLWithString:url]] autorelease];
			[request setTimeOutSeconds:20];
			[request setRequestMethod:@"GET"];
				//[request addRequestHeader:@"Cookie" value:sessionId];
			
				// add the request to the transmission queue and set it off
			[self.networkQueue addOperation:request];
		}
		[self.networkQueue go];
		
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSString *errorString = @"A communication error occurred.\n\nPlease retry your request later.";
	[appDelegate alertWithMessage:errorString withTitle:@"WOWIO"];
	return;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	++fetchCount;
	
	NSString *rsltStr = [request responseString];
		//NSDictionary *responseHeaders = [request responseHeaders];
		//NSDictionary *requestHeaders = [request requestHeaders];
	
		//NSLog(@"Response String: %@\n\n",rsltStr);
		//NSLog(@"Request Headers: %@\n\n",requestHeaders);
		//NSLog(@"Response Headers: %@\n\n",responseHeaders);
	
		// NEW JSON WAY
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableDictionary *feed = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
		//NSLog(@"Returned Feed:\n%@\n\n",feed);
	
	if ([feed objectForKey:@"categorybookcount"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"categorybookcount"];
			//NSLog(@"Category Totals:\n%@\n\n",obj);
		[self writeCategoryDataToDB:obj];
		
	} else if ([feed objectForKey:@"lib_purchased"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"lib_purchased"];
			//NSLog(@"User Library:\n%@\n\n",obj);
		[self writeBookDataToDB:@"Library" withData:obj];
		
	} else if ([feed objectForKey:@"agilespace"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"agilespace"];
			//NSLog(@"Agile Space Object:\n%@\n\n",obj);
		[self writeBookDataToDB:@"Agilespace" withData:obj];
		
	} else if ([feed objectForKey:@"home_topbooks"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_topbooks"];
			//NSLog(@"\nTop Books:\n%@\n\n",obj);
		[self writeBookDataToDB:@"Topbooks" withData:obj];
		
		
	} else if ([feed objectForKey:@"home_topcomics"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_topcomics"];
		[self writeBookDataToDB:@"Topcomics" withData:obj];
		
	} else if ([feed objectForKey:@"home_brainbytes"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_brainbytes"];
		[self writeBookDataToDB:@"brainbytes" withData:obj];
		
	} else if ([feed objectForKey:@"home_newreleases"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_newreleases"];
			//NSLog(@"New Releases:\n%@\n\n",obj);
		[self writeBookDataToDB:@"Newreleases" withData:obj];
		
	} else if ([feed objectForKey:@"home_sponsored"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_sponsored"];		
		[self writeBookDataToDB:@"Sponsored" withData:obj];
		
	} else if ([feed objectForKey:@"home_featuredbook"]) {
		
			//NSLog(@"Found Featured Books");
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_featuredbook"];
			//NSLog(@"\n%@",obj);
		
		[self writeBookDataToDB:@"Featuredbooks" withData:obj];
		
	} else if ([feed objectForKey:@"home_staffpicks"]) {
		
			//NSLog(@"Found Staff Picks");
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_staffpicks"];
			//NSLog(@"\n%@",obj);
		
		[self writeBookDataToDB:@"Staffpicks" withData:obj];
		
	} else if ([feed objectForKey:@"home_featuredpublisher"]) {
		
			//NSLog(@"Found Featured Publishers");
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_featuredpublisher"];
			//NSLog(@"\n%@",obj);
		
		[self writeBookDataToDB:@"Featuredpublishers" withData:obj];
	}	
	
		// show the app interface
	int urlCnt = [self.urlArray count];
	if (fetchCount == urlCnt) {
		[featLoadIndicator stopAnimating];
		[topLoadIndicator stopAnimating];
		_featuresFetched = YES;
	}
	
	if (_featuresFetched && !_topsellersLoaded) {
		
		[self performSelector:@selector(getTopSellersFromDB:)];		
		[self.theGridView reloadData];
		_topsellersLoaded = YES;
		
			// load up agilespace items
		[self fetchAgileContentFromDB];
		
			// set up agilespace
		[self setupAgileContentSpace];
		
			// USE THIS IF/WHEN THE LOGIN PANEL IS PUT BACK IN
		//[delegate didDismissModalView];
	}
}


#pragma mark -
#pragma mark Features Methods

-(void)fetchFeatures {
	
	if ([self internetCheck]) {
		
		[featLoadIndicator startAnimating];
		[topLoadIndicator startAnimating];
		
			//NSString *sessionId = [appDelegate sessionId];
		
			// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
		
		
			// build the request
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:homepageAgileSpaceURL]] autorelease];
		[request setTimeOutSeconds:20];
		[request setRequestMethod:@"GET"];
			//[request addRequestHeader:@"Cookie" value:sessionId];
		
			// add the request to the transmission queue and set it off
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
		
	}
}


#pragma mark -
#pragma mark DB Fetch Methods

-(void)getTopSellersFromDB:(id)sender {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
		// set the filter predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_topseller=%d or is_newrelease=%d or is_featured=%d",1,1,1];
	[fetchRequest setPredicate:predicate];
	
	NSSortDescriptor *theDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:theDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];	
	
		// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: 'Top Books' were NOT found in the db!\n");
	}
	
		// clean up after yourself
		//[predicate release];
	[theDescriptor release];
	[sortDescriptors release];
	
		// set the book ivar object
	self.gridData = mutableFetchResults;
}

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
	
		//NSLog(@"\n%@\n\n",obj);
	
		// Save Agile book data to the db
	[self writeBookDataToDB:@"Book" withData:obj];
}

-(void)fetchAgileBookData:(NSNumber*)bookid {
	
	if ([self internetCheck]) {
		
			// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(agileBookFetchFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
		
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

- (void)agileBookFetchFinished:(ASIHTTPRequest *)request
{
	
	NSString *rsltStr = [request responseString];
		//NSDictionary *responseHeaders = [request responseHeaders];
		//NSDictionary *requestHeaders = [request requestHeaders];
	
		// Convert JSON resultset to Array
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableDictionary *feed = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"bookplus"];
	
		//NSLog(@"\n%@\n\n",obj);
	
		// Save Agile book data to the db
	[self writeBookDataToDB:@"Topbooks" withData:obj];
	[self performSelector:@selector(showBook:) withObject:self.selectedBookid afterDelay:1.0];
		//[self showBook:bookid];
}




#pragma mark -
#pragma mark Database Methods

-(BOOL)bookInUserLibrary:(NSNumber*)bookid forOrderid:(NSNumber*)orderid {
	
	BOOL luResult;
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
		// set the filter predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookid=%d and orderbookid = %@",[bookid intValue],orderid];
	[fetchRequest setPredicate:predicate];
	
		// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		return NO;
	}
	
	if ([mutableFetchResults count] >0)
		luResult = YES;
	else 
		luResult = NO;
	
		// clean up after yourself
		//[predicate release];
	
	return luResult;
}

-(void)removeData:(NSString*)theEntity {
	
	int i;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity;
	if (entity == [NSEntityDescription entityForName:theEntity 
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

-(void)removeBookData:(NSString*)theEntity forFilter:(NSString*)theFilter {
	
	int i;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity;
	if (entity == [NSEntityDescription entityForName:theEntity 
							 inManagedObjectContext:self.managedObjectContext]) {
		
		[fetchRequest setEntity:entity];
		
			// set the filter predicate
		NSPredicate *predicate = [NSPredicate
								  predicateWithFormat:@"%@=1",theFilter];
		[fetchRequest setPredicate:predicate];
		
		NSError *error;
		NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];		
		[fetchRequest release];
		
		for (i = 0; i<[items count]; i++) {
			NSManagedObject *managedObject = [items objectAtIndex:i];		
			[self.managedObjectContext deleteObject:managedObject];
		}
	}
}




-(void)writeCategoryDataToDB:(NSMutableArray *)data {
	
		// remove existing categories from db
	[self removeData:@"Categories"];
	
	
	int i;
	for (i=0; i<[data count]; i++) {
		Categories * cats = (Categories *)[NSEntityDescription 
										   insertNewObjectForEntityForName:@"Categories" 
										   inManagedObjectContext:self.managedObjectContext];
		
		NSArray *obj = [data objectAtIndex:i];
		NSString *bookcategory = [obj valueForKey:@"bookcategory"];
		NSNumber *bookcategoryid = [obj valueForKey:@"bookcategoryid"];
		NSNumber *bookcount = [obj valueForKey:@"bookcount"];
		NSNumber *totalbooks = [obj valueForKey:@"totalbooks"];
		
		[cats setBookcount:bookcount];
		[cats setBookcategory:bookcategory];
		[cats setBookcategoryid:bookcategoryid];
		[cats setTotalbooks:totalbooks];
		
			// write it to db
		[self saveAction];
	}
}

-(void)writeBookDataToDB:(NSString*)tablename withData:(NSMutableArray *)data {
	
	int i;
	
		// flush existing data from selected table
	if (![tablename isEqualToString:@"Library"])
		[self removeData:tablename];
		//else
		//[self removeData:@"Library"];
	
	
	if ([tablename isEqualToString:@"Agilespace"]) {
		
		for (i = 0; i<[data count]; i++) {
			Agilespace *item = (Agilespace *)[NSEntityDescription 
											  insertNewObjectForEntityForName:@"Agilespace" 
											  inManagedObjectContext:self.managedObjectContext];
			
			NSArray *obj = [data objectAtIndex:i];
			NSNumber *bookid = [obj valueForKey:@"bookid"];
			NSString *details = [obj valueForKey:@"description"];
			NSString *contenthtml = [obj valueForKey:@"contenthtml"];
			NSString *contenthtmlipad = [obj valueForKey:@"contenthtmlipad"];
				//NSNumber *totalrecords = [obj valueForKey:@"totalrecords"];
			
				//[item setTotalrecords:totalrecords];
			[item setBookid:bookid];
			[item setDetails:details];
			[item setContenthtml:contenthtml];
			[item setContenthtmlipad:contenthtmlipad];
			
				//NSLog(@"%@",contenthtmlipad);
			
				// write it to db
			[self saveAction];
		}
		
	} else if ([tablename isEqualToString:@"Featuredpublishers"]) {
		
		for (i = 0; i<[data count]; i++) {
			Featuredpublishers *book = (Featuredpublishers *)[NSEntityDescription 
															  insertNewObjectForEntityForName:@"Featuredpublishers" 
															  inManagedObjectContext:self.managedObjectContext];
			
			NSArray *obj = [data objectAtIndex:i];
			NSNumber *bookid = [obj valueForKey:@"bookid"];
			NSString *coverimagepath_s = [obj valueForKey:@"coverimagepath_s"];
			NSString *details = [obj valueForKey:@"description"];
			NSNumber *mainbookcategoryid = [obj valueForKey:@"mainbookcategoryid"];
			NSNumber *publisherid = [obj valueForKey:@"publisherid"];
			NSString *publisherurl = [obj valueForKey:@"publisherurl"];
			NSString *booktitle = [obj valueForKey:@"title"];
			NSNumber *retailprice = [obj valueForKey:@"retailprice"];
			NSString *authorname = [obj valueForKey:@"authorname"];
				//NSString *publishername = [obj valueForKey:@"publishername"];
			
			if ([coverimagepath_s isKindOfClass:[NSNull class]])
				coverimagepath_s = @"";
			
			if ([publisherurl isKindOfClass:[NSNull class]])
				publisherurl = @"";
			
			[book setBookid:bookid];
			[book setCoverimagepath_s:coverimagepath_s];
			[book setDetails:details];
			[book setMainbookcategoryid:mainbookcategoryid];
			[book setPublisherurl:publisherurl];
			[book setPublisherid:publisherid];
			[book setTitle:booktitle];
			[book setRetailprice:retailprice];
			[book setAuthorname:authorname];
				//[book setPublishername:publishername];
			
				// write it to db
			[self saveAction];
		}
		
	} else if ([tablename isEqualToString:@"Topbooks"] || [tablename isEqualToString:@"Topcomics"] || [tablename isEqualToString:@"Featuredbooks"] || [tablename isEqualToString:@"Newreleases"] || [tablename isEqualToString:@"Staffpicks"] || [tablename isEqualToString:@"Sponsored"] || [tablename isEqualToString:@"brainbytes"]) {
		
		NSNumber *is_topseller;
		NSNumber *is_featured;
		NSNumber *is_staffpick;
		NSNumber *is_newrelease;
		NSNumber *is_sponsored;
		NSNumber *is_brainbyte;
		
		if ([tablename isEqualToString:@"Topcomics"]) {
			
			for (i = 0; i<[data count]; i++) {
				
				Book *book = (Book *)[NSEntityDescription 
									  insertNewObjectForEntityForName:@"Book" 
									  inManagedObjectContext:self.managedObjectContext];
				
				NSArray *obj = [data objectAtIndex:i];
				NSString *groupname = [obj valueForKey:@"groupname"];
				NSNumber *bookid = [obj valueForKey:@"bookid"];
				NSString *coverimagepath_l = [obj valueForKey:@"coverimagepath_l"];
				NSString *coverimagepath_s = [obj valueForKey:@"coverimagepath_s"];
				NSNumber *bookgroupid = [obj valueForKey:@"bookgroupid"];
				NSString *details = [obj valueForKey:@"description"];
				NSNumber *mainbookcategoryid = [obj valueForKey:@"mainbookcategoryid"];
				NSString *publicationdate = [obj valueForKey:@"publicationdate"];
				NSString *booktitle = [obj valueForKey:@"title"];
				NSNumber *downloadcount = [obj valueForKey:@"downloadcount"];
				NSNumber *rank = [obj valueForKey:@"rank"];
				NSNumber *tcdid = [obj valueForKey:@"tcdid"];
				NSNumber *retailprice = [obj valueForKey:@"retailprice"];
				NSNumber *pagecount = [obj valueForKey:@"pagecount"];
				NSNumber *downloadsum = [obj valueForKey:@"downloadsum"];
				NSString *reportdate = [obj valueForKey:@"reportdate"];
				NSString *authorname = [obj valueForKey:@"authorname"];
				NSString *publishername = [obj valueForKey:@"publishername"];
				
				if ([details isKindOfClass:[NSNull class]])
					details = @"";
				
				if ([coverimagepath_l isKindOfClass:[NSNull class]])
					coverimagepath_l = @"";
				
				if ([coverimagepath_s isKindOfClass:[NSNull class]])
					coverimagepath_s = @"";
				
				if ([groupname isKindOfClass:[NSNull class]])
					groupname = @"";
				
				[book setIs_topcomic:[NSNumber numberWithInt:1]];
				[book setGroupname:groupname];
				[book setBookid:bookid];
				[book setCoverimagepath_l:coverimagepath_l];
				[book setCoverimagepath_s:coverimagepath_s];
				[book setBookgroupid:bookgroupid];
				[book setDetails:details];
				[book setMainbookcategoryid:mainbookcategoryid];
				[book setPublicationdate:publicationdate];
				[book setTitle:booktitle];
				[book setDownloadsum:downloadsum];
				[book setDownloadcount:downloadcount];
				[book setRank:rank];
				[book setTcdid:tcdid];
				[book setRetailprice:retailprice];
				[book setPagecount:pagecount];
				[book setReportdate:reportdate];
				[book setAuthorname:authorname];
				[book setPublishername:publishername];
				
					// write it to db
				[self saveAction];
			}
			
		} else {
			
			for (i = 0; i<[data count]; i++) {
				
				if ([tablename isEqualToString:@"Topbooks"]) {
						//NSLog(@"top books object: %@",data);
					is_topseller = [NSNumber numberWithInt:1];
				} else {
					is_topseller = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"Featuredbooks"]) {
					is_featured = [NSNumber numberWithInt:1];
				} else {
					is_featured = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"Newreleases"]) {
						//NSLog(@"new release books object: %@",data);
					is_newrelease = [NSNumber numberWithInt:1];
				} else {
					is_newrelease = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"Staffpicks"]) {
					is_staffpick = [NSNumber numberWithInt:1];
				} else {
					is_staffpick = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"Sponsored"]) {
					is_sponsored = [NSNumber numberWithInt:1];
				} else {
					is_sponsored = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"brainbytes"]) {
					is_brainbyte = [NSNumber numberWithInt:1];
				} else {
					is_brainbyte = [NSNumber numberWithInt:0];
				}
				
				
				Book *book = (Book *)[NSEntityDescription 
									  insertNewObjectForEntityForName:@"Book" 
									  inManagedObjectContext:self.managedObjectContext];
				
				NSArray *obj = [data objectAtIndex:i];
				NSNumber *bookid = [obj valueForKey:@"bookid"];
				NSNumber *becommerce = [obj valueForKey:@"becommerce"];
				NSNumber *bnodrm = [obj valueForKey:@"bnodrm"];
				NSNumber *bnoimage = [obj valueForKey:@"bnoimage"];
				NSNumber *bavailable = [obj valueForKey:@"bavailable"];
				NSNumber *bbooksponsor = [obj valueForKey:@"bbooksponsor"];
				NSString *isbn = [obj valueForKey:@"isbn"];
				NSString *coverimagepath_l = [obj valueForKey:@"coverimagepath_l"];
				NSString *coverimagepath_s = [obj valueForKey:@"coverimagepath_s"];
				NSString *imagesubpath = [obj valueForKey:@"imagesubpath"];
				NSString *details = [obj valueForKey:@"description"];
				NSString *indexname = [obj valueForKey:@"indexname"];
				if ([imagesubpath isKindOfClass:[NSNull class]]) {
					imagesubpath = @"";
				}
				if ([indexname isKindOfClass:[NSNull class]]) {
					indexname = @"";
				}
				NSNumber *mainbookcategoryid = [obj valueForKey:@"mainbookcategoryid"];
				NSString *publicationdate = [obj valueForKey:@"publicationdate"];
				NSString *booktitle = [obj valueForKey:@"title"];
				NSNumber *retailprice = [obj valueForKey:@"retailprice"];
				NSNumber *pagecount = [obj valueForKey:@"pagecount"];
				NSNumber *purchased = [obj valueForKey:@"purchased"];
				NSNumber *previewpagecount = [obj valueForKey:@"previewpagecount"];
				NSString *authorname = [obj valueForKey:@"authorname"];
				NSNumber *publisherid = [obj valueForKey:@"publisherid"];
					//NSLog(@"Publisher id: %@",publisherid);
				NSString *publishername = [obj valueForKey:@"publishername"];
				if ([publishername isKindOfClass:[NSNull class]]) {
					publishername = @"";
				}
				NSNumber *recstatus = [obj valueForKey:@"recstatus"];
				NSNumber *ratingcount = [obj valueForKey:@"ratingcount"];
				NSString *ratingString = [ratingcount stringValue];
				NSNumber *avgrating = [obj valueForKey:@"avgrating"];
				NSString *avgRatingString = [avgrating stringValue];
				avgRatingString = [avgRatingString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
				
				NSString *sorttitle = [obj valueForKey:@"sorttitle"];
				
				NSString *filesize = [obj valueForKey:@"filesize"];
				
				NSString *ade_epub_filesize = [obj valueForKey:@"ade_epub_filesize"];
				NSNumber *ade_epub_retailprice = [obj valueForKey:@"ade_epub_retailprice"];
				NSString *ade_epub_sku13 = [obj valueForKey:@"ade_epub_sku13"];
				NSString *ade_pdf_filesize = [obj valueForKey:@"ade_pdf_filesize"];
				NSNumber *ade_pdf_retailprice = [obj valueForKey:@"ade_pdf_retailprice"];
				NSString *ade_pdf_sku13 = [obj valueForKey:@"ade_pdf_sku13"];
				
				NSNumber *bformatade_epub = [obj valueForKey:@"bformatade_epub"];
				NSNumber *bformatade_pdf = [obj valueForKey:@"bformatade_pdf"];
				NSNumber *bformatwowio = [obj valueForKey:@"bformatwowio"];
				
				NSString *epub_filesize = [obj valueForKey:@"epub_filesize"];
				NSNumber *epub_retailprice = [obj valueForKey:@"epub_retailprice"];
				NSString *epub_sku13 = [obj valueForKey:@"epub_sku13"];
				NSString *ereader_filesize = [obj valueForKey:@"ereader_filesize"];
				NSNumber *ereader_retailprice = [obj valueForKey:@"ereader_retailprice"];
				NSString *ereader_sku13 = [obj valueForKey:@"ereader_sku13"];
				
				if ([filesize isKindOfClass:[NSNull class]])
					filesize = @"";
				
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
				
				if ([bformatwowio isKindOfClass:[NSNull class]])
					bformatwowio = 0;
				
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
				
				if ([imagesubpath isKindOfClass:[NSNull class]])
					imagesubpath = @"";
				
				if ([coverimagepath_l isKindOfClass:[NSNull class]])
					coverimagepath_l = @"";
				
				if ([coverimagepath_s isKindOfClass:[NSNull class]])
					coverimagepath_s = @"";
				
				if ([publishername isKindOfClass:[NSNull class]])
					publishername = @"";
				
				if ([sorttitle isKindOfClass:[NSNull class]])
					sorttitle = @"";
				
				[book setBookid:bookid];
				[book setIs_topseller:is_topseller];
				[book setIs_newrelease:is_newrelease];
				[book setIs_staffpick:is_staffpick];
				[book setIs_brainbyte:is_brainbyte];
				[book setIs_sponsored:is_sponsored];
				[book setIs_featured:is_featured];
				[book setSorttitle:sorttitle];
				[book setFilesize:filesize];
				[book setAde_epub_filesize:ade_epub_filesize];
				[book setAde_epub_retailprice:ade_epub_retailprice];
				[book setAde_epub_sku13:ade_epub_sku13];
				[book setAde_pdf_filesize:ade_pdf_filesize];
				[book setAde_pdf_retailprice:ade_pdf_retailprice];
				[book setAde_pdf_sku13:ade_pdf_sku13];
				[book setBformatade_epub:bformatade_epub];
				[book setBformatade_pdf:bformatade_pdf];
				[book setBformatwowio:bformatwowio];
				[book setEpub_filesize:epub_filesize];
				[book setEpub_retailprice:epub_retailprice];
				[book setEpub_sku13:epub_sku13];
				[book setEreader_filesize:ereader_filesize];
				[book setEreader_retailprice:ereader_retailprice];
				[book setEreader_sku13:ereader_sku13];
				[book setBecommerce:becommerce];
				[book setBnodrm:bnodrm];
				[book setBnoimage:bnoimage];
				[book setBavailable:bavailable];
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
		}
	}
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
