    //
//  AboutViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 10/15/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController
@synthesize delegate, appDelegate;
@synthesize closeButton;

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
	
	[self.navigationController.navigationBar setHidden:YES];
}

-(IBAction)dismissView:(id)sender {
	
    // Call the delegate to dismiss the modal view
    [delegate didDismissModalView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
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
	
	[appDelegate release];
	[closeButton release];
	[delegate release];
}


@end
