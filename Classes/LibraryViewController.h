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
	
	IBOutlet UIButton *syncButton;
	IBOutlet UIImageView *backgroundImage;
	IBOutlet UILabel *progressLabel;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIProgressView *progressIndicator;
	IBOutlet UIProgressView *downloadProgress;
	NSMutableArray *books;
	Library *selectedBook;
	NSString *obfuBookId;
	
	BOOL generatingBook;
	BOOL _LibraryLoaded;
}

@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain) WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain) ASINetworkQueue *networkQueue;

@property(nonatomic, retain) IBOutlet AQGridView *theGridView;

@property(nonatomic, retain) UIButton *syncButton;
@property(nonatomic, retain) UIImageView *backgroundImage;
@property(nonatomic, retain) UILabel *progressLabel;
@property(nonatomic, retain) UIProgressView *progressIndicator;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIProgressView *downloadProgress;
@property(nonatomic, retain) NSMutableArray *books;
@property(nonatomic, retain) Library *selectedBook;
@property(nonatomic, retain) NSString *obfuBookId;

@property(nonatomic, assign) BOOL _LibraryLoaded;

-(void)loadContentForVisibleCells;

-(void)bookOpenAction:(Library *)book;
-(BOOL)bookCheck:(Library *)book;
-(void)bookDelete:(Library *)book;
-(void)bookDownload:(Library *)book withAddress:(NSString*)ipaddress;
-(void)bookRegenerate:(NSString *)bookid;
-(void)bookCheckOnWOWIO:(NSString *)bookid;

-(void)getBooksFromDB;
-(BOOL)bookInUserLibrary:(NSNumber*)bookid forOrderid:(NSNumber*)orderid;
-(void)fetchUserLibraryBookFromWOWIO:(NSString*)bookid;
-(IBAction)fetchUserLibraryFromWOWIO;

-(void)saveAction;
-(void)removeData:(NSString*)theEntity;
-(void)removeBook:(NSNumber*)bookid;

-(NSString*)convertBase10To36:(NSNumber*)nBase10;
-(NSString*)obfuscateOrderBookId:(NSNumber*)orderBookId;

@end
