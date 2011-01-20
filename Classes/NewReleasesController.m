    //
//  NewReleasesController.m
//  WOWIO
//
//  Created by Lawrence Leach on 9/17/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "NewReleasesController.h"
#import "LoginViewController.h"
#import "WebViewController.h"
#import "NewReleases.h"
#import "NewReleasesGridCell.h"


@implementation NewReleasesController
@synthesize releaseGridView=_releaseGridView;
@synthesize releaseItems;
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
	 
	 self.releaseGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	 self.releaseGridView.autoresizesSubviews = NO;
	 //self.releaseGridView.frame = featGridFrame;
	 self.releaseGridView.delegate = self;
	 self.releaseGridView.dataSource = self;
	 self.releaseGridView.allowsSelection = YES;
	 self.releaseGridView.backgroundColor = [UIColor clearColor];
	 
	 // get top book data
	 self.releaseItems = [appDelegate fetchBookDataFromDB:@"Newreleases" withSortDescriptor:@"title"];
	 
	 // load the grid
	 [self.releaseGridView reloadData];
	 
	 // load the book covers
	 [self loadContentForVisibleCells];
}


/*
-(void)awakeFromNib {
	
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
	
	self.releaseGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.releaseGridView.autoresizesSubviews = NO;
	//self.releaseGridView.frame = featGridFrame;
	self.releaseGridView.delegate = self;
	self.releaseGridView.dataSource = self;
	self.releaseGridView.allowsSelection = YES;
	self.releaseGridView.backgroundColor = [UIColor clearColor];
	
	// get top book data
	self.releaseItems = [appDelegate fetchBookDataFromDB:@"Newreleases" withSortDescriptor:@"title"];
	
	// load the grid
	[self.releaseGridView reloadData];
	
	// load the book covers
	[self loadContentForVisibleCells];
}
*/

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


#pragma mark -
#pragma mark Loading Book Images

- (void)loadContentForVisibleCells {
    NSArray *cells = [self.releaseGridView visibleCells];
    [cells retain];
	
	NSInteger ccnt = [cells count];
	//NSLog(@"\nVisible Cell Cnt: %d\n\n",ccnt);
	
    for (int i = 0; i < ccnt; i++) 
    { 
        // Go through each cell in the array and call its loadImage method if it responds to it.
        NewReleasesGridCell *bookCell = (NewReleasesGridCell *)[[cells objectAtIndex:i] retain];
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
    return [self.releaseItems count];
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{	
	self.releaseItems = [appDelegate fetchBookDataFromDB:@"Newreleases" withSortDescriptor:@"title"];
	// deselect the selected grid cell
	[self.releaseGridView deselectItemAtIndex:index animated:NO];
	
	NewReleasesBookDetail *viewController = [[NewReleasesBookDetail alloc] initWithNibName:@"BookDetailView" bundle:nil];
	//viewController.delegate = self;
	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationPageSheet;
	//[modalNavController setNavigationBarHidden:YES];
	
	// add book to the presented view
	Newreleases *book = (Newreleases*)[releaseItems objectAtIndex:index];
	[viewController setBook:book];
	
	// Present the Controller Modally	
	[self presentModalViewController:modalNavController animated:YES];
	
	//[viewController release];
	//[modalNavController release];
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString *GridCellIdentifier = @"NRCellIdentifier";
    
	Newreleases *citem = (Newreleases*)[releaseItems objectAtIndex:index];
    AQGridViewCell * cell = nil;
    NewReleasesGridCell *gridCell = (NewReleasesGridCell *)[aGridView dequeueReusableCellWithIdentifier: GridCellIdentifier];
	
	if (gridCell == nil)
	{
		gridCell = [[[NewReleasesGridCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 200.0, 150.0) 
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Property" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// set the filter predicate
	/*NSPredicate *predicate = [NSPredicate
	 predicateWithFormat:@"memberid=%@",[self memberid]];
	 [fetchRequest setPredicate:predicate];*/
	
	
	// Create the sort descriptors array.
	NSSortDescriptor *addressDescriptor = [[NSSortDescriptor alloc] initWithKey:@"propertyaddress" ascending:YES];
	NSSortDescriptor *priceDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:priceDescriptor, addressDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"propertyid" cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[addressDescriptor release];
	[priceDescriptor release];
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
