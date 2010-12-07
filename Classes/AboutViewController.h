//
//  AboutViewController.h
//  WOWIO
//
//  Created by Lawrence Leach on 10/15/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOWIOAppDelegate.h"

@protocol AboutViewControllerDelegate <NSObject>

- (void)didDismissBookView;

@end

@interface AboutViewController : UIViewController {

	WOWIOAppDelegate *appDelegate;
	id<AboutViewControllerDelegate> delegate;
	UIButton *closeButton;
}

@property(nonatomic, retain) WOWIOAppDelegate *appDelegate;
@property(nonatomic, assign) id<AboutViewControllerDelegate> delegate;
@property(nonatomic, retain) IBOutlet UIButton *closeButton;

-(IBAction)dismissView:(id)sender;

@end
