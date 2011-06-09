//
//  PDFReaderController.h
//  WOWIO
//
//  Created by Lawrence Leach on 9/7/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WOWIOAppDelegate.h"
#import "TiledPDFView.h"
#import "Library.h"

@class ASINetworkQueue;

@interface PDFReaderController : UIViewController <UIScrollViewDelegate> {

	ASINetworkQueue *networkQueue;
	WOWIOAppDelegate *appDelegate;

	IBOutlet UIScrollView *bookView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *pdfLegend;
	
	Library *book;
	NSString *sessionId;
	NSString *userId;
	
	
	// The TiledPDFView that is currently front most
	TiledPDFView *pdfView;
	// The old TiledPDFView that we draw on top of when the zooming stops
	TiledPDFView *oldPDFView;
	
	// A low res image of the PDF page that is displayed until the TiledPDFView
	// renders its content.
	UIImageView *backgroundImageView;
	UIImage *backgroundImage;
	
	// current pdf zoom scale
	CGFloat pdfScale;
	
	CGPDFPageRef page;
	CGPDFDocumentRef pdf;
	
	NSInteger currentpage;
	NSInteger pgcount;
	CGRect pageRect;
}

@property(nonatomic, retain)ASINetworkQueue *networkQueue;
@property(nonatomic, retain)WOWIOAppDelegate *appDelegate;

@property(nonatomic, retain)UIScrollView *bookView;
@property(nonatomic, retain)UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain)UILabel *activityLabel;
@property(nonatomic, retain)UILabel *pdfLegend;

@property(nonatomic, retain)Library *book;
@property(nonatomic, retain)NSString *sessionId;
@property(nonatomic, retain)NSString *userId;

@property(nonatomic, assign)NSInteger currentpage;
@property(nonatomic, assign)NSInteger pgcount;

-(IBAction)previousPage:(id)sender;
-(IBAction)nextPage:(id)sender;
-(void)openBook:(NSString*)bookPath;
-(NSString*)convertBase10To36:(NSNumber*)nBase10;
-(NSNumber*)convertBase36To10:(NSString*)strBase36;
-(NSString*)obfuscateOrderBookId:(NSNumber*)orderBookId;

@end
