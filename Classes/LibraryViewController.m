    //
//  LibraryViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "LibraryViewController.h"
#import "Library.h"
#import "LibraryGridCell.h"
#import "PDFReaderController.h"
#import "WebViewController.h"

@implementation LibraryViewController
@synthesize theGridView=_gridView;
@synthesize managedObjectContext, fetchedResultsController;
@synthesize books, backgroundImage;
@synthesize appDelegate, networkQueue;

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

	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait)
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	else
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
	
	// set the app Delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
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
	self.theGridView.bounces = NO;
}

-(void)viewWillAppear:(BOOL)animated {
	
	if ([self.books count] == 0) {
		[self getBooksFromDB];
		NSLog(@"\n\nTitle: %@\nAuthor: %@",[self.books valueForKey:@"title"],[self.books valueForKey:@"authorname"]);
	}
	
	//load library images
	[self loadContentForVisibleCells];
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
#pragma mark Book Viewer

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


#pragma mark -
#pragma mark Grid View Data Source & Delegates

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return [self.books count];
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
	// deselect the selected grid cell
	[self.theGridView deselectItemAtIndex:index animated:NO];
	
	PDFReaderController *viewController = [[PDFReaderController alloc] initWithNibName:@"PDFView" bundle:nil];
	//viewController.delegate = self;
	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
	//[modalNavController setNavigationBarHidden:YES];
	
	// add book to the presented view
	Library *book = (Library*)[books objectAtIndex:index];
	[viewController setBook:book];
	
	// Present the Controller Modally	
	[self presentModalViewController:modalNavController animated:YES];
	
	[viewController release];
	[modalNavController release];
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString * GridCellIdentifier = @"GridCellIdentifier";
    
	Library *citem = (Library*)[books objectAtIndex:index];
    AQGridViewCell * cell = nil;
    LibraryGridCell *gridCell = (LibraryGridCell *)[aGridView dequeueReusableCellWithIdentifier: GridCellIdentifier];
	
	if (gridCell == nil)
	{
		gridCell = [[[LibraryGridCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 100.0, 100.0) 
										reuseIdentifier: GridCellIdentifier] autorelease];
		gridCell.selectionStyle = AQGridViewCellSelectionStyleGlow;
	}
	gridCell.delegate = self;
	gridCell.item = citem;
	
	cell = gridCell;
    return cell;
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(150.0, 150.0) );
}


#pragma mark -
#pragma mark DB Methods

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
	
	// set the filter predicate
	//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookid=%@",bookid];
	//[fetchRequest setPredicate:predicate];
	
	NSSortDescriptor *categoryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:categoryDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: Unable to Pull User Library From the db!\n");
	}
	
	// clean up after yourself
	//[predicate release];
	//[categoryDescriptor release];
	[sortDescriptors release];
	
	// set the book ivar object
	self.books = mutableFetchResults;
	[self.theGridView reloadData];
	
}

@end
