//
//  LoadingViewController.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/10/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOWIOAppDelegate.h"

@class ASINetworkQueue;

@interface LoadingViewController : UIViewController {
	@private
		NSManagedObjectContext *managedObjectContext;

	ASINetworkQueue *networkQueue;
	WOWIOAppDelegate *appDelegate;
	
	IBOutlet UIImageView *backgroundImage;

	NetworkStatus hostStatus;
	NetworkStatus internetStatus;
	NetworkStatus wifiStatus;
}

@property(nonatomic, retain)NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain)ASINetworkQueue *networkQueue;
@property(nonatomic, retain)WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain)UIImageView *backgroundImage;

@property NetworkStatus hostStatus;
@property NetworkStatus internetStatus;
@property NetworkStatus wifiStatus;

-(void)getData:(NSString *)feed;
-(void)getCategories;
-(void)getTopSellers;
-(BOOL)internetCheck;

@end
