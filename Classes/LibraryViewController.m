    //
//  LibraryViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import "LibraryViewController.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "Library.h"
#import "LibraryGridCell.h"
#import "PDFReaderController.h"
#import "WebViewController.h"

@implementation LibraryViewController
@synthesize theGridView=_gridView;
@synthesize managedObjectContext, fetchedResultsController;
@synthesize books, backgroundImage, progressIndicator, progressLabel, downloadProgress, spinner;
@synthesize appDelegate, networkQueue, selectedBook, obfuBookId, _LibraryLoaded, _isLoggedIn;
@synthesize syncButton;

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

		// set the app Delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
		// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait)
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	else
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
	
	// set the db context
	self.managedObjectContext = [appDelegate managedObjectContext];
	
	// init the grid view
	/*CGRect bookGridFrame;
	bookGridFrame.size.width = 900;
	bookGridFrame.size.height = 630;
	bookGridFrame.origin.x = 20;
	bookGridFrame.origin.y = 117; */
	
	self.theGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.theGridView.autoresizesSubviews = NO;
	//self.theGridView.frame = bookGridFrame;
	self.theGridView.delegate = self;
	self.theGridView.dataSource = self;
	self.theGridView.allowsSelection = YES;
	self.theGridView.backgroundColor = [UIColor clearColor];
	self.theGridView.bounces = YES;
	
	[self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillAppear:(BOOL)animated {
	
	self._isLoggedIn = [appDelegate _isLoggedIn];
	
	if (!_isLoggedIn){
		
		LoginViewModalController *viewController = [[LoginViewModalController alloc] initWithNibName:@"LoginViewModal" bundle:nil];
		viewController.delegate = self;
		UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
		modalNavController.modalPresentationStyle = UIModalPresentationFormSheet;
		[modalNavController setNavigationBarHidden:YES];
		
			// Present the Controller Modally	
		[self presentModalViewController:modalNavController animated:YES];
		
		[modalNavController release];
		[viewController release];
		return;
	}
		
			// deal with orientation -- load up the correct orientation
		BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
		
		if (isPortrait)
			[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
		else
			[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
		
		
			// CHECK IF USER LIBRARY HAS BEEN LOADED
		if (!_LibraryLoaded) {
				[self removeData:@"Library"];
				//[self getBooksFromDB];
			[self fetchUserLibraryFromWOWIO];
			_LibraryLoaded = YES;
		}
}


#pragma mark -
#pragma mark LoginViewModalDelegate Delegate Methods

-(void)didDismissModalView {
	
	_isLoggedIn = [appDelegate _isLoggedIn];
	if (_isLoggedIn)
		[self dismissModalViewControllerAnimated:YES];	
}

-(void)nextSteps {
	
	_isLoggedIn = [appDelegate _isLoggedIn];
	if (_isLoggedIn) {
		
			// CHECK IF USER LIBRARY HAS BEEN LOADED
		if (!_LibraryLoaded) {
			[self removeData:@"Library"];
				//[self getBooksFromDB];
			[self fetchUserLibraryFromWOWIO];
			_LibraryLoaded = YES;
		}
	}
}


#pragma mark -
#pragma mark View Rotation Methods

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
	[_gridView release];
	[managedObjectContext release];
	[fetchedResultsController release];
	[books release];
	[backgroundImage release];
	[progressIndicator release];
	[progressLabel release];
	[downloadProgress release];
	[spinner release];
	[appDelegate release];
	[networkQueue release];
	[selectedBook release];
	[obfuBookId release];
	[syncButton release];
}


#pragma mark -
#pragma mark Loading Book Images

- (void)loadContentForVisibleCells {
    NSArray *cells = [self.theGridView visibleCells];
    [cells retain];
	
	NSInteger ccnt = [cells count];
	//NSLog(@"\nVisible Cell Cnt: %d\n\n",ccnt);
	
    for (int i = 0; i < ccnt; i++) 
    { 
        // Go through each cell in the array and call its loadImage method if it responds to it.
        LibraryGridCell *bookCell = (LibraryGridCell *)[[cells objectAtIndex:i] retain];
        [bookCell loadImage];
        [bookCell release];
        bookCell = nil;
    }
    [cells release];
}


#pragma mark -
#pragma mark Book Methods

-(void)bookOpenAction:(Library *)book {
		//NSString *msg = @"Open Book action goes here!";
		//[appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	
	NSNumber *bookformat = [book bookformat];
	
	if ([bookformat intValue] > 0) 
		[self.appDelegate alertWithMessage:@"Only WOWIO PDF PLUS Books Can Be Read On The iPad At This Time!" withTitle:@"WOWIO"];
	
	else {
		
			// USING PDF VIEW CONTROLLER
		PDFReaderController *viewController = [[PDFReaderController alloc] initWithNibName:@"PDFView" bundle:nil];
			//viewController.delegate = self;
		
		UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
		modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
			//[modalNavController setNavigationBarHidden:YES];
		
		
			// ADD BOOK TO PRESENTED VIEW
		[viewController setBook:self.selectedBook];
		
		
			// SHOW VIEW CONTROLLER MODALLY	
		[self presentModalViewController:modalNavController animated:YES];
		[viewController release];
		[modalNavController release];
		

		/*
			// USING WEB VIEW
		NSString *bookpdf = [book filepath];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:bookpdf];
		
		WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
			//viewController.delegate = self;
		
		UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
		modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
			//[modalNavController setNavigationBarHidden:YES];
		
			// setup view
		NSString *bookTitle = [book title];
		bookTitle = [bookTitle stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		bookTitle = [bookTitle stringByReplacingOccurrencesOfString:@"'" withString:@""];

		NSString *bookAuthor = [book authorname];
		bookAuthor = [bookAuthor stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		bookAuthor = [bookAuthor stringByReplacingOccurrencesOfString:@"'" withString:@""];
		
		viewController.title = [NSString stringWithFormat:@"%@ by %@",bookTitle,bookAuthor];
		
			// Present the Controller Modally
		NSURL *urlLocation = [NSURL fileURLWithPath:pdfPath];
		[self presentModalViewController:modalNavController animated:YES];
		NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:urlLocation];
		
		viewController.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		viewController.scrollView.clipsToBounds = NO;		// default is NO, we want to restrict drawing within our scrollview
		viewController.scrollView.scrollEnabled = YES;
		viewController.scrollView.bounces = NO;
		viewController.scrollView.alwaysBounceHorizontal = NO;
		viewController.scrollView.alwaysBounceVertical = YES;
		viewController.scrollView.contentSize = CGSizeMake(900.0, 1004.0);
		
		viewController.webView.scalesPageToFit = YES;
		viewController.webView.allowsInlineMediaPlayback = YES;
		viewController.webView.contentMode = UIViewContentModeScaleAspectFit;
		viewController.webView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[viewController.webView loadRequest:urlRequest];
		[viewController release];
         
        */
	}
         
	[bookformat release];
}

-(void)loadBookData:(NSNumber *)bookid {
	
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

-(void)bookDelete:(Library *)book {
	
	BOOL success;
	NSError *error;
	NSString *bookpdf = [book filepath];
	NSFileManager *FileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:bookpdf];
	success = [FileManager fileExistsAtPath:pdfPath];

	if (success)
		[FileManager removeItemAtPath:pdfPath error:&error];
	
}

-(BOOL)bookCheck:(Library *)book {
	
	BOOL success;
	NSString *bookpdf;	
	NSNumber *orderbookid = [book orderbookid];
	
	self.obfuBookId = [self obfuscateOrderBookId:orderbookid];
	
	bookpdf = [book filepath];
	
	NSFileManager *FileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:bookpdf];
	success = [FileManager fileExistsAtPath:pdfPath];
	
	return success;
}

-(void)bookDownload:(Library *)book withAddress:(NSString*)ipaddress
{
	NSString *urlStr;
	NSString *sessionId = [self.appDelegate sessionId];
	NSString *bookpdf;
	NSString *ipAddr;
	
		// SEE IF IP ADDRESS WAS PROVIDED
	if ([ipaddress isEqualToString:@""])
		ipAddr = [book externalip];
	else
		ipAddr = ipaddress;
	
		// SEE IF THERE IS A URL FOR THE FILEPATH
	NSURL *tmpURL = [NSURL URLWithString:[book filepath]];
	NSString *tmpTitle = [book title];
	NSString *dspTitle = tmpTitle;
	dspTitle = [dspTitle stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	dspTitle = [dspTitle stringByReplacingOccurrencesOfString:@"'" withString:@""];
	
		// HIDE SYNC BUTTON
	[self.syncButton setHidden:YES];
	
		// HIDE SPINNER
	[self.spinner stopAnimating];
	
		// SETUP PROGRESS INDICATORS
	[self.progressLabel setHidden:NO];
	[self.progressLabel setText:[NSString stringWithFormat:@"Downloading %@",dspTitle]];
	[self.downloadProgress setHidden:NO];
	[self.downloadProgress setProgress:0.5];
	
		// SET THE TEMP BOOK TITLE
	tmpTitle = [dspTitle stringByReplacingOccurrencesOfString:@":" withString:@""];
	tmpTitle = [tmpTitle stringByReplacingOccurrencesOfString:@"-" withString:@""];
	tmpTitle = [tmpTitle stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	if ([[tmpURL scheme] isEqualToString:@"http"] || [[tmpURL scheme] isEqualToString:@"https"]) {
		urlStr = [book filepath];
		bookpdf = [NSString stringWithFormat:@"%@.pdf",tmpTitle];
	} else {
		urlStr = [NSString stringWithFormat:@"http://%@/downloadbook.asp?book=%@",ipAddr,obfuBookId];
		bookpdf = [book filepath];
	}
		//NSLog(@"\nBook Download URL: %@",urlStr);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:bookpdf];
	
		// PREP THE DOWNLOAD QUEUE
	[self setNetworkQueue:[ASINetworkQueue queue]];
		//[self.networkQueue cancelAllOperations];
	[self.networkQueue setDownloadProgressDelegate:self.downloadProgress];
	[self.networkQueue setShowAccurateProgress:YES];
	[self.networkQueue setDelegate:self];
	[self.networkQueue setMaxConcurrentOperationCount:5];
	[self.networkQueue setRequestDidFinishSelector:@selector(bookDownloadFinished:)];
	[self.networkQueue setRequestDidFailSelector:@selector(fetchRequestFailed:)];
	
		// build the request
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlStr]] autorelease];
		//[request setShowAccurateProgress:YES];
	[request setTimeOutSeconds:30];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"Content-Type" value:@"application/pdf"];
	[request addRequestHeader:@"Cookie" value:sessionId];
	[request setDownloadDestinationPath:pdfPath];
	
		// add the request to the transmission queue and set it off
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
}

- (void)bookDownloadFinished:(ASIHTTPRequest *)request
{
	BOOL haveBook;
	
		// HIDE SYNC BUTTON
	[self.syncButton setHidden:NO];
	
		// HIDE THE PROGRESS INDICATOR BAR AND LABEL
	[self.progressLabel setHidden:YES];
	[self.downloadProgress setHidden:YES];
	[self.downloadProgress setProgress:0.0];

	haveBook = [self bookCheck:selectedBook];
	if (haveBook){
		[self bookOpenAction:selectedBook];
	} else
		[self.appDelegate alertWithMessage:@"There was problem downloading your book.\nPlease contact WOWIO Customer Support\nsupport@wowio.com" withTitle:@"WOWIO"];
}

-(void)bookCheckOnWOWIO:(NSString *)bookid {
	
	if ([self.appDelegate internetCheck]) {
		
			// HIDE SYNC BUTTON
		[self.syncButton setHidden:YES];
		
		NSString *sessionId = [self.appDelegate sessionId];
		NSString *urlStr = [NSString stringWithFormat:@"%@%@",bookPresentURL,bookid];
			//NSLog(@"\nBook Check URL: %@",urlStr);
		
			// INITIALIZE THE TRANSMISSION QUEUE
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDownloadProgressDelegate:progressIndicator];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(bookCheckFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(fetchRequestFailed:)];
		
			// BUILD THE REQUEST
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlStr]] autorelease];
		[request setTimeOutSeconds:60];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Cookie" value:sessionId];
		
			// ADD THE REQUEST THEN INITIATE IT
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
	}
}

- (void)bookCheckFinished:(ASIHTTPRequest *)request
{
	
		// HIDE SYNC BUTTON
	[self.syncButton setHidden:NO];
	
	NSString *rsltStr = [request responseString];
	
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableDictionary *feed = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	
	NSArray *result = [feed objectForKey:@"filepresent"];
	NSArray *st = [result valueForKey:@"status"];
	NSString *status = [st objectAtIndex:0];
		
		//NSLog(@"\nRaw Result String:\n%@",rsltStr);
		//NSLog(@"\nBook Check Status:\n%@",status);
	
	if ([status isEqualToString:@"READY"]) {
		generatingBook = NO;
		[self fetchUserLibraryBookFromWOWIO:obfuBookId];
		
	} else if ([status isEqualToString:@"REGEN"]) {
		if (!generatingBook) {
			generatingBook = YES;
			[self bookRegenerate:obfuBookId];
		}
		
	} else if ([status isEqualToString:@"NOTREADY"]) {
		[self performSelector:@selector(bookCheckOnWOWIO:) withObject:obfuBookId afterDelay:0.7];
	} else {
		[self.appDelegate alertWithMessage:@"There was a problem downloading your book.\n\nImmediately notify WOWIO Customer Support:\nhelp@wowio.com" withTitle:@"WOWIO"];
	}
}

-(void)bookRegenerate:(NSString *)bookid {
	
	if ([self.appDelegate internetCheck]) {
		
			// SET THE GENERATING FLAG
		generatingBook = YES;
		
			// BUILD THE REGENERATION REQUEST URL	
		NSString *sessionId = [self.appDelegate sessionId];
		NSString *urlStr = [NSString stringWithFormat:@"%@%@",bookRebuildURL,bookid];
			//NSLog(@"\nRegen URL: %@",urlStr);
		
			// HIDE SYNC BUTTON
		[self.syncButton setHidden:YES];
		
			// PROGRESS LABEL AND BAR & SPINNER
		[spinner startAnimating];
		[progressLabel setHidden:NO];
		[progressLabel setText:@"Preparing Your Book For Download..."];
			//[progressIndicator setHidden:NO];
			//[progressIndicator setProgress:0.0];
		
			// INITIALIZE THE TRANSMISSION QUEUE
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDownloadProgressDelegate:progressIndicator];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(bookRegenFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(fetchRequestFailed:)];
		
			// BUILD THE REGENERATION REQUEST
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlStr]] autorelease];
		[request setTimeOutSeconds:60];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Cookie" value:sessionId];
		
			// ADD THE REQUEST THEN INITIATE IT
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
	}
}

- (void)bookRegenFinished:(ASIHTTPRequest *)request
{
		// HIDE SYNC BUTTON
		//[self.syncButton setHidden:NO];
	
		// GRAB AND PARSE THE REGEN RESULT
	NSString *rsltStr = [request responseString];	
	NSArray *result = [rsltStr componentsSeparatedByString:@"|"];
	NSString *okorno = [result objectAtIndex:0];
	NSString *orderid = [result objectAtIndex:1];
		//NSLog(@"\nRegen Result String:\n%@",rsltStr);
		//NSLog(@"\nResult:%@\nOrder id:%@\n",okorno,orderid);
	
	if ([okorno isEqualToString:@"OK"]) {
		
		if (generatingBook)
			generatingBook = NO;

		[self performSelector:@selector(bookCheckOnWOWIO:) withObject:orderid afterDelay:2.0];
		[self bookDelete:selectedBook];
	
	} else
		[self.appDelegate alertWithMessage:@"Book Regeneration Failed!" withTitle:@"WOWIO"];
}


#pragma mark -
#pragma mark Grid View Data Source & Delegates

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return [self.books count];
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
	BOOL haveBook;
	
	// deselect the selected grid cell
	[self.theGridView deselectItemAtIndex:index animated:NO];
	
	// add book to the presented view
	Library *book = (Library*)[books objectAtIndex:index];
	self.selectedBook = book;
	
	NSNumber *bookFormat = [book bookformat];
	
	if ([bookFormat intValue] > 0) 
		[self.appDelegate alertWithMessage:@"Only WOWIO Plus PDF Books Can Be Viewed At This Time!" withTitle:@"WOWIO"];
	
	else {
			// CHECK IF BOOK CAN BE DOWNLOADED
		haveBook = [self bookCheck:self.selectedBook];
			//[self regenerateBook:book];
		
		if (haveBook) {
			[self performSelector:@selector(bookOpenAction:) withObject:self.selectedBook];
		} else {
			
			if ([bookFormat intValue] == 0)
				[self performSelector:@selector(bookCheckOnWOWIO:) withObject:self.obfuBookId];
			else {
				[self bookDownload:self.selectedBook withAddress:@""];
			}
		}
	}
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString * GridCellIdentifier = @"GridCellIdentifier";
    
	Library *citem = (Library*)[books objectAtIndex:index];
    AQGridViewCell * cell = nil;
    LibraryGridCell *gridCell = (LibraryGridCell *)[aGridView dequeueReusableCellWithIdentifier: GridCellIdentifier];
	
	if (gridCell == nil)
	{
		gridCell = [[[LibraryGridCell alloc] initWithFrame: CGRectMake(200.0, 145.0, 200.0, 145.0) 
										reuseIdentifier: GridCellIdentifier] autorelease];
		gridCell.selectionStyle = AQGridViewCellSelectionStyleGlow;
	}
	gridCell.delegate = self;
	gridCell.item = citem;
	
		//NSLog(@"\nTitle: %@ (%d)\nFilepath: %@\n",[citem title],[citem bookid],[citem filepath]);
	
	cell = gridCell;
    return cell;
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(200.0, 180.0) );
}


#pragma mark -
#pragma mark DB Methods

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

- (NSFetchedResultsController *)fetchedResultsController {
    
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
    
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *bookDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:bookDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[bookDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

-(void)getBooksFromDB {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
		//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title <> '%@'",@"(null)"];
		//[fetchRequest setPredicate:predicate];
	
	NSSortDescriptor *titleSort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:titleSort, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: Unable to Pull User Library From the db!\n");
	}
	
	// clean up after yourself
	//[predicate release];
	[titleSort release];
	[sortDescriptors release];
	
	// set the book ivar object
	self.books = mutableFetchResults;
	if ([self.books count] > 0) {
		[self.theGridView reloadData];
			//[self loadContentForVisibleCells];
		
	} else
		[self fetchUserLibraryFromWOWIO];
			
}

- (void)saveAction {
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
		exit(-1);
	}
}

-(void)removeData:(NSString*)theEntity {
	
	int i;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity;
	if (entity = [NSEntityDescription entityForName:theEntity 
							 inManagedObjectContext:self.managedObjectContext]) {
		
		[fetchRequest setEntity:entity];
		
			//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@",@""];
			//[fetchRequest setPredicate:predicate];
		
		NSError *error;
		NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];		
		[fetchRequest release];
		
		for (i = 0; i<[items count]; i++) {
			NSManagedObject *managedObject = [items objectAtIndex:i];		
			[self.managedObjectContext deleteObject:managedObject];
		}
	}
}

-(void)removeBook:(NSNumber*)bookid {
	
	int i;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity;
	if (entity = [NSEntityDescription entityForName:@"Library" 
							 inManagedObjectContext:self.managedObjectContext]) {
		
		[fetchRequest setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookid = %d",bookid];
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


#pragma mark -
#pragma mark Fetch Methods

-(void)fetchUserLibraryBookFromWOWIO:(NSString*)bookid 
{
	if ([self.appDelegate internetCheck]) {
		
			// set progress indicator
		[self.progressLabel setHidden:NO];		
		[self.progressLabel setText:@"Updating Your Library..."];
		[self.progressIndicator setHidden:NO];
		[self.progressIndicator setProgress:0.0];
		
		NSString *sessionId = [appDelegate sessionId];
		
			// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDownloadProgressDelegate:progressIndicator];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(updateRequestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(fetchRequestFailed:)];
		
			// build the request
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",userLibraryBook,bookid]]] autorelease];
		[request setTimeOutSeconds:20];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Cookie" value:sessionId];
		
			// add the request to the transmission queue and set it off
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
	}
}

-(IBAction)fetchUserLibraryFromWOWIO {
	
	if ([self.appDelegate internetCheck]) {
		
			// HIDE SYNC BUTTON
		[self.syncButton setHidden:YES];
		
			// SETUP PROGRESS INDICATORS
		[self.progressLabel setHidden:NO];	
		[self.progressLabel setText:@"Syncing Your Book Library with WOWIO..."];
		[self.progressIndicator setHidden:NO];
		[self.progressIndicator setProgress:0.1];
		
		NSString *sessionId = [appDelegate sessionId];
		
			// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
			//[self.networkQueue cancelAllOperations];
		[self.networkQueue setDownloadProgressDelegate:progressIndicator];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(fetchRequestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(fetchRequestFailed:)];
		
			// build the request
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:userLibrary]] autorelease];
		[request setTimeOutSeconds:20];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Cookie" value:sessionId];
			
			// add the request to the transmission queue and set it off
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
	}
}

- (void)fetchRequestFailed:(ASIHTTPRequest *)request
{
		// PROGRESS INDICATORS
	[self.progressLabel setHidden:YES];
	[self.progressIndicator setHidden:YES];
	[self.progressIndicator setProgress:0.0];

	NSString *errorString = @"A communication error occurred.\n\nPlease retry your request later.";
	[appDelegate alertWithMessage:errorString withTitle:@"WOWIO"];
	return;
}

- (void)fetchRequestFinished:(ASIHTTPRequest *)request
{
	
		// PROGRESS INDICATORS
	[self.progressLabel setHidden:YES];
	[self.progressIndicator setHidden:YES];
	[self.progressIndicator setProgress:0.1];

	
		// HIDE SYNC BUTTON
	[self.syncButton setHidden:NO];

	NSString *rsltStr = [request responseString];
		//NSDictionary *responseHeaders = [request responseHeaders];
		//NSDictionary *requestHeaders = [request requestHeaders];
		
		// JSON RETURN STRING
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableDictionary *feed = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	//NSLog(@"Returned Feed:\n%@\n\n",feed);
	
		// DETERMINE TYPE OF OBJECT RETURNED
	NSMutableArray *obj;	
	obj = (NSMutableArray*)[feed objectForKey:@"lib_orderbook"];
	if ([obj count] == 0)
		obj = (NSMutableArray*)[feed objectForKey:@"lib_purchased"];
		
		//NSLog(@"User Library:\n%@\n\n",obj);
	
		// CHECK TO SEE IF THEY HAVE BOOKS IN THEIR LIBRARY
	if ([obj count] == 0) {
		NSString *nobooksMsg = @"You Have NO Books in Your WOWIO Book Library.\n\nWhat's Wrong With You? BUY SOME BOOKS!";
		[appDelegate alertWithMessage:nobooksMsg withTitle:@"WOWIO"];
		return;
	}
	
		//NSLog(@"%@",obj);
		// STUFF VALUES INTO USER LIBRARY
	int i;
	for (i = 0; i<[obj count]; i++) {
		
		NSArray *bobj = [obj objectAtIndex:i];
		NSString *booktitle = [bobj valueForKey:@"title"];
		NSNumber *bookid = [bobj valueForKey:@"bookid"];
		NSNumber *orderbookid = [bobj valueForKey:@"orderbookid"];
		NSString *internalip = [bobj valueForKey:@"internalip"];
		NSString *externalip = [bobj valueForKey:@"externalip"];
		NSString *filepath = [bobj valueForKey:@"filepath"];
		
			//NSLog(@"\nTitle: %@\nBook id: %d\nOrderBookId:%d\nInternal IP:%@\nExternal IP:%@\nBook Filename:%@\n)",booktitle,[bookid intValue],[orderbookid intValue],internalip,externalip,filepath);
		
		if (![self bookInUserLibrary:bookid forOrderid:orderbookid]) {
			
			Library *book = (Library *)[NSEntityDescription 
										insertNewObjectForEntityForName:@"Library" 
										inManagedObjectContext:self.managedObjectContext];
			
			NSNumber *booktypeid = [bobj valueForKey:@"booktypeid"];
			NSNumber *contentratingid = [bobj valueForKey:@"contentratingid"];
			NSNumber *orderbookstatus = [bobj valueForKey:@"orderbookstatus"];
			NSNumber *downloadsuccess = [bobj valueForKey:@"downloadsuccess"];
			NSNumber *loboserverid = [bobj valueForKey:@"loboserverid"];
			NSString *details = [bobj valueForKey:@"description"];
			NSString *orderdate = [bobj valueForKey:@"orderdate"];
			if ([orderdate isKindOfClass:[NSNull class]])
				orderdate = @"";
			NSString *downloaddate = [bobj valueForKey:@"downloaddate"];
			if ([downloaddate isKindOfClass:[NSNull class]])
				downloaddate = @"";
			
			NSNumber *admodelid = [bobj valueForKey:@"admodelid"];
			if ([admodelid isKindOfClass:[NSNull class]])
				admodelid = [NSNumber numberWithInt:0];
			NSNumber *adid = [bobj valueForKey:@"adid"];
			if ([adid isKindOfClass:[NSNull class]])
				adid = [NSNumber numberWithInt:0];
			
			NSNumber *bnoimage = [bobj valueForKey:@"bnoimage"];
			NSString *imagesubpath = [bobj valueForKey:@"imagesubpath"];
			if ([imagesubpath isKindOfClass:[NSNull class]])
				imagesubpath = @"";
			
			NSString *imagepath = [bobj valueForKey:@"imagepath"];
			if ([imagepath isKindOfClass:[NSNull class]])
				imagepath = @"";
			
			NSString *largeimagepath = [bobj valueForKey:@"largeimagepath"];
			if ([largeimagepath isKindOfClass:[NSNull class]])
				largeimagepath = @"";
			
			NSNumber *bookcategoryid = [bobj valueForKey:@"bookcategoryid"];
			if ([bookcategoryid isKindOfClass:[NSNull class]])
				bookcategoryid = [NSNumber numberWithInt:0];
			
			NSNumber *bookcategory = [bobj valueForKey:@"bookcategory"];
			if ([bookcategory isKindOfClass:[NSNull class]])
				bookcategory = [NSNumber numberWithInt:0];
			
			NSString *indexname = [bobj valueForKey:@"indexname"];
			if ([indexname isKindOfClass:[NSNull class]])
				indexname = @"";
			
			NSNumber *publisherid = [bobj valueForKey:@"publisherid"];
			if ([publisherid isKindOfClass:[NSNull class]])
				publisherid = [NSNumber numberWithInt:0];
			
			NSNumber *bookformat = [bobj valueForKey:@"bookformat"];
			if ([bookformat isKindOfClass:[NSNull class]])
				bookformat = [NSNumber numberWithInt:0];
			
			NSString *sorttitle = [bobj valueForKey:@"sorttitle"];
			NSString *authorname = [bobj valueForKey:@"authorname"];
			NSNumber *retailprice = [bobj valueForKey:@"retailprice"];
			NSNumber *thankyoucount = [bobj valueForKey:@"thankyoucount"];
			NSNumber *previewpagecount = [bobj valueForKey:@"previewpagecount"];
			NSNumber *avgrating = [bobj valueForKey:@"avgrating"];
			NSString *avgRatingString = [avgrating stringValue];
			avgRatingString = [avgRatingString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
			
			NSNumber *ratingcount = [bobj valueForKey:@"ratingcount"];
			NSNumber *userrating = [bobj valueForKey:@"userrating"];
			
				// STORE IN THE BOOK CONTAINER
			[book setBookid:bookid];
			[book setBookformat:bookformat];
			[book setImagesubpath:imagesubpath];
			[book setImagepath:imagepath];
			[book setLargeimagepath:largeimagepath];
			[book setBnoimage:bnoimage];
			[book setBooktypeid:booktypeid];
			[book setOrderbookid:orderbookid];
			[book setContentratingid:contentratingid];
			[book setOrderbookstatus:orderbookstatus];
			book.downloadsuccess = downloadsuccess;
			book.admodelid = admodelid;
			book.adid = adid;
			book.orderdate = orderdate;
			book.internalip = internalip;
			book.externalip = externalip;
			book.downloaddate = downloaddate;
			book.indexname = indexname;
			book.title = booktitle;
			book.sorttitle = sorttitle;
			book.authorname = authorname;
			book.retailprice = retailprice;
			book.thankyoucount = thankyoucount;
			book.previewpagecount = previewpagecount;
			book.publisherid = publisherid;
			book.authorname = authorname;
			book.avgrating = avgRatingString;
			book.ratingcount = ratingcount;
			book.userrating = userrating;			
			book.loboserverid = loboserverid;			
			book.imagepath = imagepath;			
			book.filepath = filepath;			
			book.details = details;			
			book.bookcategoryid = bookcategoryid;			
			book.bookcategory = bookcategory;			
			
				// SAVE TO THE DB
			[self saveAction];
		}
	}
		// UPDATE THE GRID
	[self getBooksFromDB];
}

- (void)updateRequestFinished:(ASIHTTPRequest *)request
{
	
		// PROGRESS INDICATORS
	[self.progressLabel setHidden:YES];
	[self.progressIndicator setHidden:YES];
	[self.progressIndicator setProgress:0.0];
	
	NSString *rsltStr = [request responseString];
		//NSLog(@"\nReturned Book Update Object:%@\n\n",rsltStr);
		//NSDictionary *responseHeaders = [request responseHeaders];
		//NSDictionary *requestHeaders = [request requestHeaders];
	
		// JSON RETURN STRING
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableDictionary *feed = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
		//NSLog(@"Returned Feed:\n%@\n\n",feed);
	
		// DETERMINE TYPE OF OBJECT RETURNED
	NSMutableArray *obj;	
	obj = (NSMutableArray*)[feed objectForKey:@"lib_orderbook"];
	
		//NSLog(@"User Library:\n%@\n\n",obj);
	
		// STUFF VALUES INTO USER LIBRARY
	NSArray *bobj = [obj objectAtIndex:0];
		//NSNumber *bookid = [bobj valueForKey:@"bookid"];
		//NSNumber *orderbookid = [bobj valueForKey:@"orderbookid"];
		//NSString *internalip = [bobj valueForKey:@"internalip"];
	NSString *externalip = [bobj valueForKey:@"externalip"];
		//NSString *filepath = [bobj valueForKey:@"filepath"];
	
		// RE-ATTEMPT THE BOOK DOWNLOAD
	[self bookDownload:selectedBook withAddress:externalip];
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
	NSMutableString *strBase36 = [[NSMutableString alloc] init];
	int i, n;
	
	n = [nBase10 intValue];
	
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
		strBase36 = [NSString stringWithFormat:@"%@%@", asciiStr,strBase36];
		n = (n / 36);
	}
	return strBase36;
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
	NSMutableString *strOut = [[NSMutableString alloc] init];
	NSString *aStr;
	NSString *bStr;
	
	int frmNo = 1;
	int toNo = 60000000;
	int rNo = (arc4random() % (toNo - frmNo)) + 1;
	
	aStr = [self convertBase10To36:orderBookId];
	bStr = [self convertBase10To36:[NSNumber numberWithInt:rNo]];
		//NSLog(@"Converted: %@",aStr);
	
	strOut = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",[aStr substringWithRange:NSMakeRange(3, 1)],[bStr substringWithRange:NSMakeRange(2, 1)],[aStr substringWithRange:NSMakeRange(5, 1)],[bStr substringWithRange:NSMakeRange(0, 1)],[aStr substringWithRange:NSMakeRange(2, 1)],[aStr substringWithRange:NSMakeRange(4, 1)],[aStr substringWithRange:NSMakeRange(0, 1)],[bStr substringWithRange:NSMakeRange(1, 1)],[bStr substringWithRange:NSMakeRange(4, 1)],[aStr substringWithRange:NSMakeRange(1, 1)]];
	
	return strOut;
}

@end
