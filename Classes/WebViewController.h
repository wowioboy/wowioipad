//
//  WebViewController.h
//  WOWIO
//
//  Created by Lawrence Leach on 8/25/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
	
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;
	IBOutlet UIWebView *webView;
	IBOutlet UIScrollView *scrollView;
}

-(void)dismissView:(id)sender;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) UILabel *activityLabel;
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) UIScrollView *scrollView;

@end
