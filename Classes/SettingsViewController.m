    //
//  SettingsViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController
@synthesize backgroundImage, viewController;
@synthesize appDelegate, menuItems;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
	
	if (isPortrait)
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	else
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
	} else {
		[self.backgroundImage setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
	}
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[backgroundImage release];
	[viewController release];
	[appDelegate release];
}


@end
