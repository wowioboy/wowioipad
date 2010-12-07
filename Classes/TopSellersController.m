    //
//  TopSellersController.m
//  WOWIO
//
//  Created by Lawrence Leach on 9/17/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "TopSellersController.h"
#import "LoginViewController.h"
#import "WebViewController.h"
#import "Book.h"
#import "BookGridCell.h"


@implementation TopSellersController
@synthesize theGridView=_gridView;
@synthesize gridData;
@synthesize fetchedResultsController, managedObjectContext, appDelegate, bookViewController, webViewController;


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
	
	NSLog(@"Top Sellers Loaded!");
}


-(void)awakeFromNib {
	//NSLog(@"You are awake now!");
	
	//load up the app delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// set db context
	self.managedObjectContext = [self.appDelegate managedObjectContext];
	
	// init the grid view
	CGRect featGridFrame;
	featGridFrame.size.width = 900;
	featGridFrame.size.height = 630;
	featGridFrame.origin.x = 0;
	featGridFrame.origin.y = 407;
	
	self.theGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.theGridView.autoresizesSubviews = NO;
	//self.theGridView.frame = featGridFrame;
	self.theGridView.bounces = YES;
	self.theGridView.scrollEnabled = YES;
	self.theGridView.delegate = self;
	self.theGridView.dataSource = self;
	self.theGridView.allowsSelection = YES;
	self.theGridView.backgroundColor = [UIColor clearColor];
	
	// get top book data
	//self.gridData = [appDelegate fetchBookDataFromDB:@"Book" withSortDescriptor:@"title" withPredicate:@"is_topseller"];
	[self performSelector:@selector(getBooksFromDB:)];
	//NSLog(@"\nTop Books In Awake Mode: %@\n\n",self.gridData);
	
	/*
		// fetched db results
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
			// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	*/
	
	// load the grid
	[self.theGridView reloadData];
	
	// load the book covers
	[self loadContentForVisibleCells];
}

-(void)viewDidAppear:(BOOL)animated {
	NSLog(@"View Did Appear");
}

-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"View Will Appear");
}

-(void)didDismissModalView {
	
	[self dismissModalViewControllerAnimated:YES];
}

-(void)didDismissBookView {
	
	[self dismissModalViewControllerAnimated:YES];
}


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

-(void)getBooksFromDB:(id)sender {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
	// set the filter predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_topseller=%d or is_newrelease=%d",1,1];
	[fetchRequest setPredicate:predicate];
	
	NSSortDescriptor *theDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:theDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];	
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: 'Topbooks' were NOT found in the db!\n");
	}
	
	// clean up after yourself
	//[predicate release];
	//[theDescriptor release];
	//[sortDescriptors release];
	
	// set the book ivar object
	self.gridData = mutableFetchResults;
		//NSLog(@"Data fetch results:\n%@",gridData);
	[self.theGridView reloadData];
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
        BookGridCell *bookCell = (BookGridCell *)[[cells objectAtIndex:i] retain];
        [bookCell loadImage];
        [bookCell release];
        bookCell = nil;
    }
    [cells release];
}


#pragma mark -
#pragma mark Grid View Data Source & Delegates

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return [self.gridData count];
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
		//self.gridData = [appDelegate fetchBookDataFromDB:@"Book" withSortDescriptor:@"title"];
	[self performSelector:@selector(getBooksFromDB:)];
	//NSLog(@"\nTop Books In Cell SELECT Mode: %@\n\n",self.gridData);
	
	// deselect the selected grid cell
	[self.theGridView deselectItemAtIndex:index animated:NO];
	
	TopSellersDetail *viewController = [[TopSellersDetail alloc] initWithNibName:@"TopSellersDetailView" bundle:nil];

	// add book to the presented view
	viewController.managedObjectContext = self.managedObjectContext;
	Book *book = (Book*)[gridData objectAtIndex:index];
	[viewController setTheBook:book];
	
	//viewController.delegate = self;
	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationPageSheet;
	//[modalNavController setNavigationBarHidden:YES];
	
	// Present the Controller Modally	
	[self presentModalViewController:modalNavController animated:YES];
	
	//[viewController release];
	//[modalNavController release];
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString * GridCellIdentifier = @"GridCellIdentifier";
    
		//NSLog(@"\nTop Books In Cell DISPLAY Mode: %@\n\n",self.gridData);
	
	Book *citem = (Book*)[gridData objectAtIndex:index];
    AQGridViewCell * cell = nil;
    BookGridCell *gridCell = (BookGridCell *)[aGridView dequeueReusableCellWithIdentifier: GridCellIdentifier];
	
	if (gridCell == nil)
	{
		gridCell = [[[BookGridCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 200.0, 150.0) 
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
    return ( CGSizeMake(200.0, 168.0) );
}



#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
    
	//NSLog(@"Your Zone: %d",self.selectedZone);
	
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// set the filter predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_topseller=%d",1];
	[fetchRequest setPredicate:predicate];
	
	
	// Create the sort descriptors array.
	NSSortDescriptor *theDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:theDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[theDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
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


@end
