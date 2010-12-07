//
//  TopSellersDetail.h
//  WOWIO
//
//  Created by Lawrence Leach on 10/20/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOWIOAppDelegate.h"
#import "BookDelegate.h"

@class Book;
@class ASINetworkQueue;

@interface TopSellersDetail : UIViewController <BookDelegate> {
	
	NSManagedObjectContext *managedObjectContext;
	
	WOWIOAppDelegate *appDelegate;
	ASINetworkQueue *networkQueue;
	
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UILabel *bookTitle;
	IBOutlet UILabel *bookAuthor;
	IBOutlet UILabel *bookLength;
	IBOutlet UILabel *bookPublishDate;
	IBOutlet UILabel *bookPublisher;
	IBOutlet UILabel *bookIsbn;
	IBOutlet UILabel *bookIsbnLabel;
	IBOutlet UILabel *bookRetailPrice;
	IBOutlet UILabel *bookRetailLabel;
	IBOutlet UILabel *bookRatingsLabel;
	IBOutlet UITextView *bookDetails;
	IBOutlet UIImageView *bookJacket;
	IBOutlet UIImageView *bookRating;
	IBOutlet UIButton *downloadButton;
	IBOutlet UIButton *previewButton;
	IBOutlet UIButton *buyButton;
	IBOutlet UIButton *readButton;
	
	NSNumberFormatter *numberFormatter;
	
	UIImage *image;
	Book *theBook;
	NSString *bid;
}

@property(nonatomic, retain)NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain)WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain)ASINetworkQueue *networkQueue;

@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UILabel *bookTitle;
@property(nonatomic, retain) UILabel *bookAuthor;
@property(nonatomic, retain) UILabel *bookLength;
@property(nonatomic, retain) UILabel *bookPublishDate;
@property(nonatomic, retain) UILabel *bookPublisher;
@property(nonatomic, retain) UILabel *bookIsbn;
@property(nonatomic, retain) UILabel *bookIsbnLabel;
@property(nonatomic, retain) UILabel *bookRetailPrice;
@property(nonatomic, retain) UILabel *bookRetailLabel;
@property(nonatomic, retain) UILabel *bookRatingsLabel;
@property(nonatomic, retain) UITextView *bookDetails;
@property(nonatomic, retain) UIImageView *bookJacket;
@property(nonatomic, retain) UIImageView *bookRating;

@property(nonatomic, retain) UIButton *downloadButton;
@property(nonatomic, retain) UIButton *previewButton;
@property(nonatomic, retain) UIButton *buyButton;
@property(nonatomic, retain) UIButton *readButton;

@property(nonatomic, retain) NSNumberFormatter *numberFormatter;

@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) Book *theBook;
@property(nonatomic, assign) NSString *bid;

-(IBAction)downloadAction:(id)sender;
-(IBAction)previewAction:(id)sender;
-(IBAction)purchaseBookAction:(id)sender;
-(IBAction)readBookAction:(id)sender;
-(void)dismissBookView:(id)sender;
-(void)loadBookPreview:(NSNumber *)bookid;
-(void)startSpinner:(id)sender;
-(void)stopSpinner:(id)sender;

@end
