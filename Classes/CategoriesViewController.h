//
//  CategoriesViewController.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright Pure Engineering 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOWIOAppDelegate.h"
#import "AQGridView.h"
#import "GridColors.h"

@class ASINetworkQueue;
@class CategoryDetailViewController;

@interface CategoriesViewController : UIViewController <NSFetchedResultsControllerDelegate, AQGridViewDelegate, AQGridViewDataSource> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	AQGridView * _gridView;
	
	WOWIOAppDelegate *appDelegate;
	ASINetworkQueue *networkQueue;
	
	GridColors *gridColor;
	
	CategoryDetailViewController *categoryDetailViewController;
	NSMutableArray *cats;

	IBOutlet UINavigationBar *navBar;
	IBOutlet UIImageView *backgroundImage;
	IBOutlet UIImageView *sponsorLegend;
	IBOutlet UIProgressView *myProgressIndicator;
	
	NetworkStatus hostStatus;
	NetworkStatus internetStatus;
	NetworkStatus wifiStatus;
}

@property(nonatomic, retain)NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, retain)NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain)WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain)ASINetworkQueue *networkQueue;

@property(nonatomic, retain)GridColors *gridColor;

@property (nonatomic, retain) IBOutlet AQGridView * gridView;

@property(nonatomic, retain)CategoryDetailViewController *categoryDetailViewController;
@property(nonatomic, retain)NSMutableArray *cats;

@property(nonatomic, retain)UINavigationBar *navBar;
@property(nonatomic, retain)UIImageView *backgroundImage;
@property(nonatomic, retain)UIImageView *sponsorLegend;

@property(nonatomic, retain)UIProgressView *myProgressIndicator;

@property NetworkStatus hostStatus;
@property NetworkStatus internetStatus;
@property NetworkStatus wifiStatus;

-(IBAction)bookCategoryAction:(id)sender;
-(void)getBookCategoriesFromDB;
-(void)loadCategoryDetail;
-(BOOL)internetCheck;
-(void)getCategoryImage:(NSMutableArray*)bookCats;
-(UIColor *) colorWithHexString: (NSString *) stringToConvert;

@end
