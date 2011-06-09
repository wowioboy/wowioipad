//
//  FeaturesViewController.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright Pure Engineering 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "WOWIOAppDelegate.h"
#import "AboutViewController.h"
#import "WebViewController.h"
#import "BookViewController.h"
#import "BookGridCellDelegate.h"
#import "TopSellersController.h"
#import "AQGridView.h"
#import "GridColors.h"
#import "Book.h"
#import "Categories.h"

@class ASINetworkQueue;

@interface FeaturesViewController : UIViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate, BookGridCellDelegate, UIWebViewDelegate, AQGridViewDelegate, AQGridViewDataSource, AboutViewControllerDelegate> {
	
	
	AQGridView * _gridView;
	NSMutableArray *gridData;
	NSArray *urlArray;
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	WOWIOAppDelegate *appDelegate;
	ASINetworkQueue *networkQueue;
	AboutViewController *aboutViewController;
	WebViewController *webViewController;
	TopSellersController *topSellersController;
	
		//TopSellersController *sellersGrid;

	NSNumberFormatter *numberFormatter;
		
	IBOutlet UIImageView *backgroundImage;
	IBOutlet UIView *mainContainer;
	IBOutlet UIView *topSellersView;
	IBOutlet UIScrollView *mainScrollView;	
	IBOutlet UIScrollView *contentView;	
	IBOutlet UIPageControl *pageControl;
	IBOutlet UILabel *topSellersLabel;
	IBOutlet UILabel *headline;
	IBOutlet UIButton *infoButton;
	IBOutlet UIButton *topSellersButton;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIActivityIndicatorView *featLoadIndicator;
	IBOutlet UIActivityIndicatorView *topLoadIndicator;
	IBOutlet UILabel *activityLabel;
	IBOutlet UIWebView *webView;
	IBOutlet UIView *gridList;
	//IBOutlet UIView *featuredContent;
	//IBOutlet UIView *newReleasesView;
	//IBOutlet UIView *topSellersView;
	
	UIButton *bookButton;
	UIImageView *imageView;
	
	NSMutableArray *webViewItems;
	NSMutableArray *featuredItems;
	NSMutableArray *featuredHeadlines;
	NSMutableArray *topbooks;
	NSMutableArray *newReleases;
	NSMutableArray *featured;
	
	NSTimer *repeatingTimer;
	NSInteger agilePage;
	NSNumber *selectedBookid;
	Book *selectedBook;
	
	int fetchCount;
	BOOL _isLoggedIn;
	BOOL _contentLoaded;
	BOOL _topsellersLoaded;
	BOOL _featuresFetched;

	NetworkStatus hostStatus;
	NetworkStatus internetStatus;
	NetworkStatus wifiStatus;

	//LoginViewController *loginController;
	//UINavigationController *modalNavController;
}

	//@property(nonatomic, retain) IBOutlet TopSellersController *sellersGrid;

@property(nonatomic, assign)id<ModalViewControllerDelegate> delegate;

@property(nonatomic, retain) WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain) ASINetworkQueue *networkQueue;

@property(nonatomic, retain) IBOutlet AQGridView *theGridView;
@property(nonatomic, retain) NSMutableArray *gridData;
@property(nonatomic, retain) NSArray *urlArray;

@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain) AboutViewController *aboutViewController;
@property(nonatomic, retain) WebViewController *webViewController;
@property(nonatomic, retain) TopSellersController *topSellersController;

@property(nonatomic, retain) NSNumberFormatter *numberFormatter;

//@property(nonatomic, retain) GridColors *gridColor;

@property(nonatomic, retain) UIImageView *backgroundImage;
@property(nonatomic, retain) UIView *mainContainer;
@property(nonatomic, retain) UIScrollView *mainScrollView;
@property(nonatomic, retain) UIScrollView *contentView;
@property(nonatomic, retain) UIPageControl *pageControl;
@property(nonatomic, retain) UILabel *topSellersLabel;
@property(nonatomic, retain) UILabel *headline;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) UIActivityIndicatorView *featLoadIndicator;
@property(nonatomic, retain) UIActivityIndicatorView *topLoadIndicator;
@property(nonatomic, retain) UILabel *activityLabel;

@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) UIButton *infoButton;
@property(nonatomic, retain) UIButton *topSellersButton;
@property(nonatomic, retain) UIButton *bookButton;
@property(nonatomic, retain) NSMutableArray *webViewItems;
@property(nonatomic, retain) NSMutableArray *featuredItems;
@property(nonatomic, retain) NSMutableArray *featuredHeadlines;
@property(nonatomic, retain) NSMutableArray *topbooks;
@property(nonatomic, retain) NSMutableArray *newReleases;
@property(nonatomic, retain) NSMutableArray *featured;
@property(nonatomic, retain) UIView *gridList;
	//@property(nonatomic, retain) UIView *featuredContent;
	//@property(nonatomic, retain) UIView *newReleasesView;
@property(nonatomic, retain) UIView *topSellersView;

@property(nonatomic, assign) NSTimer *repeatingTimer;
@property(nonatomic, assign) NSInteger agilePage;
@property(nonatomic, retain) NSNumber *selectedBookid;
@property(nonatomic, retain) Book *selectedBook;

@property(nonatomic, assign) int fetchCount;
@property(nonatomic, assign) BOOL _isLoggedIn;
@property(nonatomic, assign) BOOL _contentLoaded;
@property(nonatomic, assign) BOOL _topsellersLoaded;

//@property(nonatomic, retain) LoginViewController *loginController;
//@property(nonatomic, retain) UINavigationController *modalNavController;

// methods
-(void)layoutFeaturedScrollImages;
-(void)layoutFeaturedScrollContent;
-(void)changeAgilePage:(id)sender;
-(IBAction)showAbout:(id)sender;
-(IBAction)showAll:(id)sender;
-(void)swapHeadline:(int)page;
-(void)getTopSellersFromDB:(id)sender;
-(void)fetchAgileContentFromDB;
-(void)setupAgileContentSpace;
-(UIColor *) colorWithHexString: (NSString *) stringToConvert;
-(void)showBook:(NSNumber*)bookid;
-(void)fetchAgileBookData:(NSNumber*)bookid;
-(void)fetchBookData:(NSNumber*)bookid;
-(void)fetchBookDataFromDB:(NSNumber*)bookid;
	//-(void)writeBookDataToDB:(NSMutableArray *)data;

-(void)fetchWowioData;
-(void)fetchFeatures;
-(BOOL)internetCheck;

-(BOOL)bookInUserLibrary:(NSNumber*)bookid forOrderid:(NSNumber*)orderid;
-(void)removeData:(NSString*)theEntity;
-(void)removeBookData:(NSString*)theEntity forFilter:(NSString*)theFilter;
-(void)writeCategoryDataToDB:(NSMutableArray *)data;
-(void)writeBookDataToDB:(NSString*)table withData:(NSMutableArray *)data;
-(void)saveAction;


@end
