//
//  PDFReaderController.h
//  WOWIO
//
//  Created by Lawrence Leach on 9/7/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOWIOAppDelegate.h"
#import "Library.h"

@class ASINetworkQueue;

@interface PDFReaderController : UIViewController <UIWebViewDelegate> {

	ASINetworkQueue *networkQueue;
	WOWIOAppDelegate *appDelegate;

	IBOutlet UIWebView *bookView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;
	
	Library *book;
	NSString *sessionId;
	NSString *userId;
}

@property(nonatomic, retain)ASINetworkQueue *networkQueue;
@property(nonatomic, retain)WOWIOAppDelegate *appDelegate;

@property(nonatomic, retain)UIWebView *bookView;
@property(nonatomic, retain)UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain)UILabel *activityLabel;

@property(nonatomic, retain)Library *book;
@property(nonatomic, retain)NSString *sessionId;
@property(nonatomic, retain)NSString *userId;

-(void)loadBookData:(id)sender;
-(void)openWOWIOBook:(NSString *)pdf;
-(NSString*)convertBase10To36:(NSNumber*)nBase10;
-(NSNumber*)convertBase36To10:(NSString*)strBase36;
-(NSString*)obfuscateOrderBookId:(NSNumber*)orderBookId;

@end
