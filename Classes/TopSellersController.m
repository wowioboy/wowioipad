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
@synthesize gridData, testLabel;
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"Top Sellers View Loaded!");
	
	
	self.testLabel.text = @"Test text";
}
*/

-(void)awakeFromNib {
	NSLog(@"Top Sellers Are Awake Now!");
	
		//load up the app delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
		// set db context
	self.managedObjectContext = [self.appDelegate managedObjectContext];	

		// init the grid view
	CGRect featGridFrame;
	
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait) {
		featGridFrame.origin.x = 60;
		featGridFrame.size.width = 770;
		
	} else {
		featGridFrame.origin.x = 0;
		featGridFrame.size.width = 900;
	}
	
	featGridFrame.size.height = 3000;
	featGridFrame.origin.y = 40;
	
	self.theGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.theGridView.autoresizesSubviews = NO;
	self.theGridView.frame = featGridFrame;
	self.theGridView.bounces = YES;
	self.theGridView.scrollEnabled = YES;
	self.theGridView.delegate = self;
	self.theGridView.dataSource = self;
	self.theGridView.allowsSelection = YES;
	self.theGridView.backgroundColor = [UIColor clearColor];

	[self performSelector:@selector(getBooksFromDB:)];
	
	NSLog(@"\nNo. of Top Sellers: %d\n",[self.gridData count]);
	
	[self.theGridView reloadData];
}

/*
-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"Top Sellers Will Appear");
	
	[self performSelector:@selector(getBooksFromDB:)];
	[self.theGridView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
	NSLog(@"Top Sellers Did Appear");
	
	[self performSelector:@selector(getBooksFromDB:)];
	[self.theGridView reloadData];
}
*/

-(void)didDismissModalView {
	
	[self dismissModalViewControllerAnimated:YES];
}

-(void)didDismissBookView {
	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Housekeeping Methods

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	CGRect featGridFrame;
	featGridFrame.size.height = 3000;
	featGridFrame.origin.y = 407;
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		featGridFrame.origin.x = 60;
		featGridFrame.size.width = 770;
		
	} else {
		featGridFrame.origin.x = 0;
		featGridFrame.size.width = 900;
	}
	
	self.theGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.theGridView.autoresizesSubviews = NO;
		//self.theGridView.frame = featGridFrame;
	self.theGridView.bounces = YES;
	self.theGridView.scrollEnabled = YES;
	self.theGridView.delegate = self;
	self.theGridView.dataSource = self;
	self.theGridView.allowsSelection = YES;
	self.theGridView.backgroundColor = [UIColor clearColor];
	
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
	
	/*
	int bookCnt = [self.gridData count];
	NSLog(@"Top Books Fetched Count: %d\n%@",bookCnt);
	
	[self.theGridView reloadData];
	*/
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

- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString * GridCellIdentifier = @"GridCellIdentifier";
    
	Book *citem = (Book*)[gridData objectAtIndex:index];
    AQGridViewCell * cell = nil;
    BookGridCell *gridCell = (BookGridCell *)[aGridView dequeueReusableCellWithIdentifier: GridCellIdentifier];
	
	NSLog(@"\nTitle: %@\n",[citem title]);
	
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
	NSLog(@"\nTapped A Book In The Grid!\n\n");
	
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
	
		//[viewController release];
		//[modalNavController release];
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(200.0, 150.0) );
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
