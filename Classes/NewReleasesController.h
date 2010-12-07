//
//  NewReleasesController.h
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
#import "NewReleasesBookDetail.h"
#import "WebViewController.h"
#import "BookViewController.h"
#import "NewReleasesGridCellDelegate.h"
#import "AQGridView.h"
#import "GridColors.h"


@interface NewReleasesController : UIViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate, ModalViewControllerDelegate, AQGridViewDelegate, AQGridViewDataSource, NewReleasesGridCellDelegate, UIWebViewDelegate> {
	
	AQGridView * _releaseGridView;
	NSMutableArray *releaseItems;
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	WOWIOAppDelegate *appDelegate;
	NewReleasesBookDetail *bookViewController;
	WebViewController *webViewController;
}

@property (nonatomic, retain) IBOutlet AQGridView *releaseGridView;
@property (nonatomic, retain) NSMutableArray *releaseItems;

@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain) NewReleasesBookDetail *bookViewController;
@property(nonatomic, retain) WebViewController *webViewController;

// methods
-(void)loadContentForVisibleCells;
-(NSFetchedResultsController *)fetchedResultsController;
-(UIColor *) colorWithHexString: (NSString *) stringToConvert;

@end
