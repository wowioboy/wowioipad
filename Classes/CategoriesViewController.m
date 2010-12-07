//
//  CategoriesViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright Alliance Acquisitions 2010. All rights reserved.
//

#import "CategoriesViewController.h"
#import "WOWIOAppDelegate.h"
#import "Categories.h"
#import "CategoryGridCell.h"
#import "CategoryDetailViewController.h"
#import "CJSONDeserializer.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "GridColors.h"

@implementation CategoriesViewController
@synthesize gridView=_gridView;
@synthesize backgroundImage, sponsorLegend;
@synthesize appDelegate, networkQueue, categoryDetailViewController, cats;
@synthesize hostStatus, internetStatus, wifiStatus, myProgressIndicator, navBar;
@synthesize fetchedResultsController, managedObjectContext, gridColor;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// set the db context
	self.managedObjectContext = [appDelegate managedObjectContext];

	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait)
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	else
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];

	// init the grid view
	self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.gridView.autoresizesSubviews = YES;
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
	self.gridView.backgroundColor = [UIColor clearColor];
	CGPoint gridOffset = CGPointMake(0.0, 0.0);
	[self.gridView setContentOffset:gridOffset];
	//self.gridView.backgroundColor = [self colorWithHexString:@"ecd2ad"];
		
	// fetched db results
	[self getBookCategoriesFromDB];
	
	//NSLog(@"Categories: %@",cats);

	// load the grid
	[self.gridView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
	
	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait)
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	else
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];

	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	 else 
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
	
}

-(IBAction)bookCategoryAction:(id)sender {
	
	
	
}

-(void)loadCategoryDetail {
	
	CategoryDetailViewController *viewController = [[CategoryDetailViewController alloc] initWithNibName:@"CategoryDetailView" 
																								  bundle:nil];
	self.categoryDetailViewController = viewController;
	[viewController release];
}


#pragma mark -
#pragma mark Grid View Data Source & Delegates

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return ([self.cats count]);
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
	// deselect the selected grid cell
	[self.gridView deselectItemAtIndex:index animated: NO];
		
	// load category detail view
	if (categoryDetailViewController == nil)
		[self loadCategoryDetail];
	
	// configure the modal view
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:categoryDetailViewController];
	modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
	[modalNavController setNavigationBarHidden:NO];
	
	// add book to the presented view
	Categories *cat = (Categories*)[[self cats] objectAtIndex:index];
	[categoryDetailViewController setCategoryId:[NSString stringWithFormat:@"%@",[cat bookcategoryid]]];
	categoryDetailViewController.title = [NSString stringWithFormat:@"%@ (%@ Books)",[cat bookcategory],[cat bookcount]];
	[categoryDetailViewController.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	
	// Present the Controller Modally	
	[self presentModalViewController:modalNavController animated:YES];
	[modalNavController release];
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * GridCellIdentifier = @"GridCellIdentifier";
    
	Categories *citem = (Categories*)[cats objectAtIndex:index];
    AQGridViewCell * cell = nil;
    CategoryGridCell *gridCell = (CategoryGridCell *)[aGridView dequeueReusableCellWithIdentifier: GridCellIdentifier];

	if (gridCell == nil)
	{
		gridCell = [[[CategoryGridCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 600.0, 30.0) 
											reuseIdentifier: GridCellIdentifier] autorelease];
		gridCell.selectionStyle = AQGridViewCellSelectionStyleNone;
	}
	gridCell.item = citem;
	cell = gridCell;
    
    return cell;
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(270.0, 45.0) );
}


#pragma mark -
#pragma mark Fetched results controller

-(void)getBookCategoriesFromDB {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Categories" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *categoryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bookcategory" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:categoryDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
		
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: NO category data was found in the db!\n");
	}
	
	// clean up after yourself
	[categoryDescriptor release];
	[sortDescriptors release];
	
	// set an image for each category
	//[self getCategoryImage:mutableFetchResults];
	
	// set the book ivar object
	self.cats = mutableFetchResults;
	
}

-(void)getCategoryImage:(NSMutableArray*)bookCats {
	
	for (int i = 0; i<[bookCats count]; i++) {

		NSManagedObjectContext *moc = self.managedObjectContext;
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Categorybooks" inManagedObjectContext:moc];
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		[fetchRequest setEntity:entity];
		
		NSSortDescriptor *categoryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bookcategory" ascending:NO];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:categoryDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		// execute the fetch
		NSError *error;
		NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
		if (mutableFetchResults == nil) {
			NSLog(@"Houston, we have a problem: NO category data was found in the db!\n");
		}
		
	}
	
	// set the book ivar object
	self.cats = bookCats;

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
#pragma mark Housekeeping Methods

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
	[myProgressIndicator release];
	[categoryDetailViewController release];
	[cats release];
	[navBar release];
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
