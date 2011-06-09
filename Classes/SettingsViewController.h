//
//  SettingsViewController.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOWIOAppDelegate.h"

@interface SettingsViewController : UIViewController {

	IBOutlet UIImageView *backgroundImage;
	IBOutlet UISplitViewController *viewController;
	
	WOWIOAppDelegate *appDelegate;
	NSArray *menuItems;
}

@property(nonatomic, retain)UIImageView *backgroundImage;
@property(nonatomic, retain)UISplitViewController *viewController;

@property(nonatomic, retain)WOWIOAppDelegate *appDelegate;
@property(nonatomic, retain)NSArray *menuItems;

@end
