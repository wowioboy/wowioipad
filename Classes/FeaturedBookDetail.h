//
//  FeaturedBookDetail.h
//  WOWIO
//
//  Created by Lawrence Leach on 7/8/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOWIOAppDelegate.h"
#import "BookGridCell.h"

@class Topbooks;
@class ASINetworkQueue;

@protocol BookModalViewControllerDelegate <NSObject>

- (void)didDismissBookView;

@end

@interface FeaturedBookDetail : UIViewController {

	NSManagedObjectContext *managedObjectContext;
	WOWIOAppDelegate *appDelegate;
	ASINetworkQueue *networkQueue;
	
	id<BookModalViewControllerDelegate> delegate;
		
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UILabel *bookTitle;
	IBOutlet UILabel *bookAuthor;
	IBOutlet UILabel *bookLength;
	IBOutlet UILabel *bookPublishDate;
	IBOutlet UILabel *bookPublisher;
	IBOutlet UILabel *bookIsbn;
	IBOutlet UILabel *bookIsbnLabel;
	IBOutlet UITextView *bookDetails;
	IBOutlet UIImageView *bookJacket;
	IBOutlet UIImageView *bookRating;
	IBOutlet UIButton *downloadButton;
	IBOutlet UIButton *previewButton;
	
	Topbooks *book;
	
}

@property(nonatomic, retain)NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain)WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain)ASINetworkQueue *networkQueue;

@property (nonatomic, assign) id<BookModalViewControllerDelegate> delegate;

@property(nonatomic, retain) UILabel *bookTitle;
@property(nonatomic, retain) UILabel *bookAuthor;
@property(nonatomic, retain) UILabel *bookLength;
@property(nonatomic, retain) UILabel *bookPublishDate;
@property(nonatomic, retain) UILabel *bookPublisher;
@property(nonatomic, retain) UILabel *bookIsbn;
@property(nonatomic, retain) UILabel *bookIsbnLabel;
@property(nonatomic, retain) UITextView *bookDetails;
@property(nonatomic, retain) UIImageView *bookJacket;
@property(nonatomic, retain) UIImageView *bookRating;

@property(nonatomic, retain) Topbooks *book;

-(void)loadBookPreview:(NSNumber *)bookid;
-(IBAction)purchaseAction:(id)sender;
-(IBAction)downloadAction:(id)sender;
-(IBAction)previewAction:(id)sender;
-(void)dismissBookView:(id)sender;
-(void)fetchBookJacket:(NSURL *)url;

@end
