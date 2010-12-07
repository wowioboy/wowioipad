//
//  TopSellersController.h
//  WOWIO
//
//  Created by Lawrence Leach on 9/17/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "WOWIOAppDelegate.h"
#import "LoginViewController.h"
#import "FeaturedBookDetail.h"
#import "WebViewController.h"
#import "TopSellersDetail.h"
#import "BookGridCellDelegate.h"
#import "AQGridView.h"
#import "GridColors.h"

@interface TopSellersController : UIViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate, BookModalViewControllerDelegate, ModalViewControllerDelegate, AQGridViewDelegate, AQGridViewDataSource, BookGridCellDelegate, UIWebViewDelegate> {

	AQGridView * _gridView;
	NSMutableArray *gridData;

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	WOWIOAppDelegate *appDelegate;
	TopSellersDetail *bookViewController;
	WebViewController *webViewController;
}

@property (nonatomic, retain) IBOutlet AQGridView *theGridView;
@property (nonatomic, retain) NSMutableArray *gridData;

@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain) TopSellersDetail *bookViewController;
@property(nonatomic, retain) WebViewController *webViewController;

// methods
-(void)getBooksFromDB:(id)sender;
-(void)loadContentForVisibleCells;
-(NSFetchedResultsController *)fetchedResultsController;
-(UIColor *) colorWithHexString: (NSString *) stringToConvert;

@end
