//
//  LibraryViewController.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WOWIOAppDelegate.h"
#import "AQGridView.h"
#import "GridColors.h"
#import "LibraryGridCellDelegate.h"

@class Library;
@class ASINetworkQueue;

@interface LibraryViewController : UIViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate, AQGridViewDelegate, AQGridViewDataSource, LibraryGridCellDelegate> {
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	WOWIOAppDelegate *appDelegate;
	ASINetworkQueue *networkQueue;
	
	AQGridView * _gridView;
	
	IBOutlet UIImageView *backgroundImage;
	NSMutableArray *books;
}

@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain) WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain) ASINetworkQueue *networkQueue;

@property (nonatomic, retain) IBOutlet AQGridView *theGridView;

@property(nonatomic, retain)UIImageView *backgroundImage;
@property(nonatomic, retain) NSMutableArray *books;

-(void)loadContentForVisibleCells;
-(void)getBooksFromDB;

@end
