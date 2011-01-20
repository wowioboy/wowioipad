//
//  CategoryDetailViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/29/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "CategoryDetailViewController.h"
#import "CJSONDeserializer.h"
#import "BookGridCell.h"
#import "Book.h"
#import "BookViewController.h"
#import "ASINetworkQueue.h"
#import	"ASIHTTPRequest.h"

@implementation CategoryDetailViewController
@synthesize gridView=_gridView;
@synthesize managedObjectContext, fetchedResultsController, activityIndicator, progressIndicator;
@synthesize categoryId, books, backgroundImage;
@synthesize appDelegate, networkQueue, gridColor, progressLabel;
@synthesize nextButton, prevButton;
@synthesize currentPage, previousPage;

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
	
	// set default value of page
	currentPage = 1;
	previousPage = 0;
	[self.prevButton setEnabled:NO];
	
	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait) {
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];

		// set the panel nav buttons
		CGRect nxtBtn = CGRectMake(676, 910, 72, 37);
		CGRect prvBtn = CGRectMake(20, 910, 72, 37);
		nextButton.frame = nxtBtn;
		prevButton.frame = prvBtn;
		
	} else {
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
		
		// set the panel nav buttons
		CGRect nxtBtn = CGRectMake(932, 652, 72, 37);
		CGRect prvBtn = CGRectMake(20, 652, 72, 37);
		nextButton.frame = nxtBtn;
		prevButton.frame = prvBtn;
		
	}
	
	// set the app Delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// set the db context
	self.managedObjectContext = [appDelegate managedObjectContext];
	
	
	// load a button to return to the category list
	UIImage *buttonImage = [UIImage imageNamed:@"button_categories.png"];
	UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[aButton setImage:buttonImage forState:UIControlStateNormal];
	aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
	
	// Initialize the UIBarButtonItem
	UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
	
	// Set the Target and Action for aButton
	[aButton addTarget:self action:@selector(dismissCategoryView:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = aBarButtonItem;
	
	// Release buttonImage
	[buttonImage release];
	
	
	
	// init the grid view
	self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.gridView.autoresizesSubviews = YES;
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
	self.gridView.backgroundColor = [UIColor clearColor];
	//self.gridView.backgroundColor = [self colorWithHexString:@"ecd2ad"];
}

-(void)viewWillAppear:(BOOL)animated {
	
	// zap the current book list view
	self.books = nil;
	[self.gridView reloadData];
	
}

-(void)viewDidAppear:(BOOL)animated {

		// zap the current book list view
	self.books = nil;
	[self.gridView reloadData];
	
		// show that we're loading up data
	//[self.activityIndicator startAnimating];
	
		// fetched book results
	[self getBooksForCategoryFromWOWIO];

	/*
		// fetched db results
	 NSError *error;
	 if (![[self fetchedResultsController] performFetch:&error]) {
			 // Update to handle the error appropriately.
	 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	 exit(-1);  // Fail
	 }
	 */
	 [self.gridView reloadData];
	 
}


#pragma mark -
#pragma mark Button Actions

-(void)dismissCategoryView:(id)sender {
	
    // dismiss the modal view
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)nextButtonAction:(id)sender {
	
	if ([self.books count] < maxBooksPerPanel) {
		[self.nextButton setEnabled:NO];
	} else {
		[self.nextButton setEnabled:YES];

		self.currentPage++;
		self.books = nil;
		[self.gridView reloadData];
		[self getBooksForCategoryFromWOWIO];
		[self.prevButton setEnabled:YES];
	}
}

-(IBAction)prevButtonAction:(id)sender {
	if (currentPage > 1) {
		
		self.currentPage--;
		self.books = nil;
		[self.gridView reloadData];
		[self getBooksForCategoryFromWOWIO];
		[self.nextButton setEnabled:YES];
	}		
}

#pragma mark -
#pragma mark Housekeeping Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
		
		// set the panel nav buttons
		CGRect nxtBtn = CGRectMake(676, 910, 72, 37);
		CGRect prvBtn = CGRectMake(20, 910, 72, 37);
		nextButton.frame = nxtBtn;
		prevButton.frame = prvBtn;
		
	} else {
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
		
			// set the panel nav buttons
		CGRect nxtBtn = CGRectMake(932, 652, 72, 37);
		CGRect prvBtn = CGRectMake(20, 652, 72, 37);
		nextButton.frame = nxtBtn;
		prevButton.frame = prvBtn;
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
	[activityIndicator release];
	[progressIndicator release];
	[categoryId release];
	[books release];
	[backgroundImage release];
	[appDelegate release];
	[networkQueue release];
	[gridColor release];
	[progressLabel release];
	[nextButton release];
	[prevButton release];
}


#pragma mark -
#pragma mark DB Fetch Methods

- (NSFetchedResultsController *)fetchedResultsController {
    
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
    
		// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
		// limit the size of dataset returned
	[fetchRequest setFetchLimit:20];
	
		// set the filter predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mainbookcategoryid=%@",[self categoryId]];
	[fetchRequest setPredicate:predicate];	
	
		// Create the sort descriptors array.
	NSSortDescriptor *categoryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bookcategory" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:categoryDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
		// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
		// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[categoryDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

-(void)getBooksForCategoryFromDB:(NSString*)catid {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
		// set the filter predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mainbookcategoryid=%@",[self categoryId]];
	[fetchRequest setPredicate:predicate];
	
	NSSortDescriptor *categoryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:categoryDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	
		// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: '%@' was NOT found in the db!\n",catid);
	}
	
	// clean up after yourself
	//[predicate release];
	//[categoryDescriptor release];
	//[sortDescriptors release];
	
	// set the book ivar object
	self.books = mutableFetchResults;
	[self.gridView reloadData];
}



#pragma mark -
#pragma mark Fetch Methods -- WOWIO

-(void)getBooksForCategoryFromWOWIO {
	
	if ([self internetCheck]) {
		
		NSString *sessionId = [appDelegate sessionId];
		
		// set progress indicator
		[self.progressLabel setHidden:NO];		
		[self.progressIndicator setHidden:NO];
		[self.progressIndicator setProgress:0.0];
		
		// start activity indicator
		//[self.activityIndicator startAnimating];
		
		// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDownloadProgressDelegate:progressIndicator];
		[self.networkQueue setShowAccurateProgress:YES];
		[self.progressLabel setHidden:NO];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(booksRequestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(booksRequestFailed:)];
		
		NSString *url = [NSString stringWithFormat:@"%@&nBookCategoryId=%@&nPage=%d&nPageSize=%d",booksForCategoryURL,self.categoryId,self.currentPage,maxBooksPerPanel];
			//NSLog(@"%@",url);
		
		// build the request
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] 
										initWithURL:[NSURL 
													 URLWithString:url]] autorelease];
		[request setTimeOutSeconds:20];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Cookie" value:sessionId];
			
		// add the request to the transmission queue and set it off
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
		
	}
}

- (void)booksRequestFailed:(ASIHTTPRequest *)request
{
	// progress indicators
	[self.progressLabel setHidden:YES];
	[self.progressIndicator setHidden:YES];
	[self.progressIndicator setProgress:0.0];
	
	// start activity indicator
	[self.activityIndicator stopAnimating];
	
	NSString *errorString = @"A communication error occurred.\n\nPlease retry your request.";
	[appDelegate alertWithMessage:errorString withTitle:@"WOWIO"];
	return;
}

- (void)booksRequestFinished:(ASIHTTPRequest *)request
{
	// progress indicators
	[self.progressLabel setHidden:YES];
	[self.progressIndicator setHidden:YES];
	[self.progressIndicator setProgress:0.0];

	// start activity indicator
	[self.activityIndicator stopAnimating];
	
	NSString *rsltStr = [request responseString];
	//NSDictionary *responseHeaders = [request responseHeaders];
	//NSDictionary *requestHeaders = [request requestHeaders];
	
	// FORMAT 
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableDictionary *feed = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"cat_browse"];
	
	//NSLog(@"\nCategory Books: %@\n\n",obj);
	[self writeBookDataToDB:@"Book" withData:obj];
	
	// get the books from the db after a short delay
	[self performSelector:@selector(getBooksForCategoryFromDB:) withObject:self.categoryId];
}


#pragma mark -
#pragma mark Grid View Data Source & Delegates

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return ([self.books count]);
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
	// deselect the selected grid cell
	[self.gridView deselectItemAtIndex:index animated: NO];
	
	// grab and set the book to be displayed
	BookViewController *viewController = [[BookViewController alloc] initWithNibName:@"BookDetailView" bundle:nil];	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationPageSheet;
	//[modalNavController setNavigationBarHidden:YES];
	
	// add book to the presented view
	Book *book = (Book*)[books objectAtIndex:index];
	[viewController setBook:book];
	
	// present the controller modally	
	[self presentModalViewController:modalNavController animated:YES];
	
	[viewController release];
	[modalNavController release];
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * GridCellIdentifier = @"GridCellIdentifier";
    
	Book *citem = (Book*)[self.books objectAtIndex:index];
    AQGridViewCell * cell = nil;
    BookGridCell *gridCell = (BookGridCell *)[aGridView dequeueReusableCellWithIdentifier: GridCellIdentifier];
	
	if (gridCell == nil)
	{
		gridCell = [[[BookGridCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 200.0, 150.0) 
											reuseIdentifier: GridCellIdentifier] autorelease];
		gridCell.selectionStyle = AQGridViewCellSelectionStyleGlow;
	}
	gridCell.item = citem;
	cell = gridCell;
    
    return cell;
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(200.0, 168.0) );
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
		
		// set the predicate
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mainbookcategoryid=%@",[self categoryId]];
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

-(void)writeBookDataToDB:(NSString*)tablename withData:(NSMutableArray *)data {
	
	// flush existing data from selected table
	[self removeData:tablename];
	
		//NSLog(@"\nCategory book data: %@",data);
	
		int i;
		for (i = 0; i<[data count]; i++) {
			Book *book = (Book *)[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
			
			NSArray *obj = [data objectAtIndex:i];
			NSNumber *cpage = [NSNumber numberWithInt:currentPage];
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
			NSNumber *mainbookcategoryid = [NSNumber numberWithInt:[self.categoryId intValue]];
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
			NSString *filesize = [obj valueForKey:@"filesize"];
			if ([filesize isKindOfClass:[NSNull class]]) {
				filesize = @"";
			}
			NSNumber *recstatus = [obj valueForKey:@"recstatus"];
			NSNumber *ratingcount = [obj valueForKey:@"ratingcount"];
			NSString *ratingString = [ratingcount stringValue];
			NSNumber *avgrating = [obj valueForKey:@"avgrating"];
			NSString *avgRatingString = [avgrating stringValue];
			avgRatingString = [avgRatingString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
			
			NSString *sorttitle = [obj valueForKey:@"sorttitle"];
			
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
			[book setCpage:cpage];
			[book setSorttitle:sorttitle];
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
			[book setFilesize:filesize];
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

	
	// now go get the book records from the db
	//[self getBooksForCategoryFromDB:[self categoryId]];
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


#pragma mark -
#pragma mark colorWithHexString

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


@end
