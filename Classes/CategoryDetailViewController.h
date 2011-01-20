//
//  CategoryDetailViewController.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/29/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WOWIOAppDelegate.h"
#import "BookGridCellDelegate.h"
#import "AQGridView.h"
#import "GridColors.h"

@class Book;
@class ASINetworkQueue;

@interface CategoryDetailViewController : UIViewController <NSFetchedResultsControllerDelegate, AQGridViewDelegate, AQGridViewDataSource, BookGridCellDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	AQGridView * _gridView;
	WOWIOAppDelegate *appDelegate;
	ASINetworkQueue *networkQueue;
	
	GridColors *gridColor;
	
	IBOutlet UIImageView *backgroundImage;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIProgressView *progressIndicator;
	IBOutlet UILabel *progressLabel;
	IBOutlet UIButton *nextButton;
	IBOutlet UIButton *prevButton;
	
	NSInteger currentPage;
	NSInteger previousPage;
	
	NSString *categoryId;
	NSMutableArray *books;
	
	NetworkStatus hostStatus;
	NetworkStatus internetStatus;
	NetworkStatus wifiStatus;
}

@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain) WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain) ASINetworkQueue *networkQueue;

@property(nonatomic, retain) GridColors *gridColor;

@property(nonatomic, retain) UIImageView *backgroundImage;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) UIProgressView *progressIndicator;
@property(nonatomic, retain) UILabel *progressLabel;
@property(nonatomic, retain) UIButton *nextButton;
@property(nonatomic, retain) UIButton *prevButton;

@property(nonatomic, assign) NSInteger currentPage;
@property(nonatomic, assign) NSInteger previousPage;

@property (nonatomic, retain) IBOutlet AQGridView * gridView;

@property(nonatomic, retain) NSString *categoryId;
@property(nonatomic, retain) NSMutableArray *books;

-(void)getBooksForCategoryFromDB:(NSString*)catid;
-(void)getBooksForCategoryFromWOWIO;
-(void)writeBookDataToDB:(NSString*)tablename withData:(NSMutableArray *)data;
-(void)saveAction;
-(void)dismissCategoryView:(id)sender;
-(IBAction)nextButtonAction:(id)sender;
-(IBAction)prevButtonAction:(id)sender;
-(BOOL)internetCheck;
-(UIColor *)colorWithHexString:(NSString *)stringToConvert;

@end
