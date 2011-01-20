    //
//  LoginViewController.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/11/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "WOWIOAppDelegate.h"
#import "FormCell.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "Book.h"
#import "Sponsored.h"
#import "Topbooks.h"
#import "brainbytes.h"
#import "Categories.h"
#import "Topcomics.h"
#import "Newreleases.h"
#import "User.h"
#import "Featuredpublishers.h"
#import "Staffpicks.h"
#import "Featuredbooks.h"
#import "Agilespace.h"
#import "Library.h"


@implementation LoginViewController 
@synthesize progressIndicator, managedObjectContext;
@synthesize appDelegate, networkQueue, theTableView, dataSource;
@synthesize userNameField, passWordField, loginView, backgroundImage;
@synthesize hostStatus, internetStatus, wifiStatus;
@synthesize delegate, fetchCount, urlArray;
@synthesize joinButton, loginButton, loginBackgroundButton, backgroundButton, infoField;
@synthesize emailDefault, passwordDefault;

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
	
	//load up the app delegate
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// set the context
	self.managedObjectContext = [appDelegate managedObjectContext];
	
	fetchCount = 0;
	
	// init the data array
	self.urlArray = [NSArray arrayWithObjects:userURL, bookCatCountURL, topBooksURL, newReleasesURL, homepageAgileSpaceURL, nil];
	/*
	Other Feeds You Can Add to This Array:
	 topComicsURL, topPubsURL, sponsoredBooksURL, brainBytesURL, staffPicksURL, featuredPubURL, featuredBookURL, userLibrary
	*/

	// deal with orientation -- load up the correct orientation
	BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);

	CGRect lframe;
	
	if (isPortrait) {

		lframe = CGRectMake(152.0, 229.0, 464.0, 546.0);
		self.loginView.frame = lframe;
		[self.backgroundImage setImage:[UIImage imageNamed:@"login_portrait.png"]];
		
	} else {

		lframe = CGRectMake(280.0, 101.0, 464.0, 546.0);
		self.loginView.frame = lframe;
		[self.backgroundImage setImage:[UIImage imageNamed:@"login_landscape.png"]];
	}
	
	
	// Set the size for the table view
	CGRect tableViewRect;
	tableViewRect.size.width = 450;
	tableViewRect.size.height = 130;
	tableViewRect.origin.x = 5;
	tableViewRect.origin.y = 130;
	
	// Create a table viiew
	theTableView = [[UITableView alloc] initWithFrame:tableViewRect	style:UITableViewStyleGrouped];
	
	// set the autoresizing mask so that the table will always fill the view
	[theTableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
	
	// set the tableview delegate to this object
	[theTableView setDelegate:self];
	
	// Set the table view datasource to the data source
	[theTableView setDataSource:self];
	
	// set the row height for the table
	[theTableView setRowHeight:40];
	[theTableView setScrollEnabled:NO];
	[theTableView setBounces:NO];
	[theTableView setUserInteractionEnabled:YES];
	[theTableView setBackgroundView:nil];
	
	// set the background color of the table
	[theTableView setBackgroundColor:[UIColor clearColor]];
	[theTableView setSeparatorColor:[UIColor grayColor]];
	
	// Add the items to the current view
	[self.loginView addSubview:theTableView];
	
	// don't forget to flush
	[theTableView release];
	
}

-(void)viewDidAppear:(BOOL)animated {
	
	// put default values into the login fields
	[self getUserDefaults];
	
	if ([emailDefault isEqualToString:@"email"] || [emailDefault isEqualToString:@""] || emailDefault == nil || [emailDefault isKindOfClass:[NSNull class]]) {
		
		// enable fields and buttons for login form
		self.infoField.text = @"";

		[self.joinButton setHidden:NO];
		[self.joinButton setEnabled:YES];
		
		[self.loginButton setHidden:NO];
		[self.userNameField setEnabled:YES];
	
		[self.passWordField setEnabled:YES];

		// make the username field the responder field
		[userNameField becomeFirstResponder];
	
	} else {
		
		// show progress text and hide interface buttons
		infoField.textColor = [UIColor darkGrayColor];
			//self.infoField.text = @"Sign In to WOWIO";

		[self.joinButton setHidden:NO];
		[self.joinButton setEnabled:YES];
		
		[self.loginButton setHidden:NO];
		[self.userNameField setEnabled:YES];
		[self.passWordField setEnabled:YES];
			//[self performSelector:@selector(loginAction:)];
	}
	
}

-(void)getUserDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	emailDefault = [defaults stringForKey:@"emailKey"];
	passwordDefault = [defaults stringForKey:@"passwordKey"];
	[userNameField setText:emailDefault];
	[passWordField setText:passwordDefault];
}

#pragma mark -
#pragma mark Button Methods

-(IBAction)joinAction:(id)sender {
		// NSString *msg = @"Account Creation Will Go Here!\n\n(not yet finished)";
		// [appDelegate alertWithMessage:msg withTitle:@"WOWIO"];
	
	WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
		//viewController.delegate = self;
	
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
	modalNavController.modalPresentationStyle = UIModalPresentationFullScreen;
	
	NSURL *urlLocation = [NSURL URLWithString:joinWOWIOURL];
	[self presentModalViewController:modalNavController animated:YES];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:urlLocation];
		//NSLog(@"%@",urlLocation);
	
	viewController.webView.scalesPageToFit = YES;
	viewController.webView.allowsInlineMediaPlayback = YES;
	viewController.webView.contentMode = UIViewContentModeScaleAspectFit;
	viewController.webView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[viewController.webView loadRequest:urlRequest];
	[viewController release];
}

-(void)loginAction:(id)sender {

	if ([self internetCheck]) {
		
		// Start the login process
		NSString *usr = [userNameField text];
		usr = [usr lowercaseString];
		
		NSString *pwd = [passWordField text];

		if ([usr length] == 0 || [pwd length] == 0) {
			//[self alertWithMessage:@"You must provide a username and password in order to log into iMogul!" andTitle:nil];
			infoField.textColor = [UIColor yellowColor];
			infoField.text = @"Please provide your WOWIO username and password";
			[self.joinButton setHidden:NO];
			[self.joinButton setEnabled:YES];
			[self.loginButton setHidden:NO];
			[self.loginButton setEnabled:YES];
			[self.userNameField setEnabled:YES];
			[self.passWordField setEnabled:YES];
			[userNameField becomeFirstResponder];
			return;
		}
		
		// Next, show progress text
		infoField.textColor = [UIColor whiteColor];
		self.infoField.text = @"Signing In...";
		
		// disable the login button...
		[self.loginButton setEnabled:NO];
		[self.joinButton setEnabled:NO];
		[self.joinButton setHidden:YES];

		[userNameField setEnabled:NO];
		[passWordField setEnabled:NO];
		[loginButton setEnabled:NO];
		
		NSString *postBody = [NSString 
							  stringWithFormat:@"txtEmail=%@&txtPassword=%@",
							  [usr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							  [pwd stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSData *postData = [postBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%d",[postBody length]];
		
		//NSLog(@"URL: %@\n\n",postBody);
		// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(loginRequestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(loginRequestFailed:)];
		
		// build the request
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:loginURL]] autorelease];
		[request setTimeOutSeconds:20];
		[request setRequestMethod:@"POST"];
		[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded charset=utf-8"];
		[request addRequestHeader:@"Content-Length" value:postLength];
		//[request addRequestHeader:@"Cookie" value:sessionId];
		[request appendPostData:postData];
		
		// add the request to the transmission queue and set it off
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
	}
}

- (void)loginRequestFailed:(ASIHTTPRequest *)request
{
	NSString *errorString = @"A communication error occurred.\nWe are unable to log you in at this time.\n\nPlease retry your request again later.";
	[appDelegate alertWithMessage:errorString withTitle:@"WOWIO"];
	
	// reenable the login button...
	[userNameField setEnabled:YES];
	[passWordField setEnabled:YES];
	[loginButton setEnabled:YES];
	[loginButton setHidden:NO];
	[joinButton setEnabled:YES];
	[joinButton setHidden:NO];
	
	self.infoField.text = @"";
	
	// set the prompt at the username field
	//[self.userNameField becomeFirstResponder];
	
}

- (void)loginRequestFinished:(ASIHTTPRequest *)request
{
	int i,y;
	NSString *usrKey;
	NSRange usrRange;
	NSRange fndRange;
	NSString *userId;
	NSRange sesRange;
	//NSString *sesKey;
	NSString *sessionId;
	NSString *rsltStr = [request responseString];
	NSDictionary *loginHeaders = [request responseHeaders];
		// NSLog(@"\nRaw Login Result String:\n%@",rsltStr);
		// NSLog(@"\nLogin Response Header:\n%@",loginHeaders);
	
	// grab and parse the returned cookie string
	NSString *fullCookieString = (NSString*)[loginHeaders valueForKey:@"Set-Cookie"];
	
	//NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:homeURL]];
    //NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
	//NSString *cookies = (NSString*)[headers valueForKey:@"Cookie"];
	//NSLog(@"\nHeader: %@\n",headers);
	//NSLog(@"\n%@",fullCookieString);	
	
	NSArray *obj= [fullCookieString componentsSeparatedByString:@"; "];
		//NSLog(@"\n%@",obj);	
	
	for (i=0; i<[obj count]; i++) {
		
		usrKey = [obj objectAtIndex:i];
		usrRange = [usrKey rangeOfString:@"UserId" options:(NSLiteralSearch)];
		if (usrRange.length > 0) {
			NSArray *uObjArray = [usrKey componentsSeparatedByString:@"="];
			for (y=0; y<[uObjArray count]; y++) {
				NSString *ky = [uObjArray objectAtIndex:y];
				fndRange = [ky rangeOfString:@"UserId" options:(NSLiteralSearch)];
				if (fndRange.length > 0)
					userId = [uObjArray objectAtIndex:(y+1)];
			}
			
			
		} else {
			
			sesRange = [usrKey rangeOfString:@"SessionId" options:(NSLiteralSearch)];
			if (sesRange.length > 0) {
				NSArray *uObjArray = [usrKey componentsSeparatedByString:@"="];
				for (y=0; y<[uObjArray count]; y++) {
					NSString *ky = [uObjArray objectAtIndex:y];
					fndRange = [ky rangeOfString:@"SessionId" options:(NSLiteralSearch)];
					if (fndRange.length > 0)
						sessionId = [uObjArray objectAtIndex:(y+1)];
				}
			}
		}
	}
	
		//NSLog(@"\nUserID:\n%@SessionID:\n%@\n",userId,sessionId);

	/*
	// set userid
	NSString *userIdString = [obj valueForKey:@"UserId"];
	NSArray *uObjArray = [userIdString componentsSeparatedByString:@"="];
	NSString *userId = [uObjArray objectAtIndex:1];

	// set sessionid
	NSString *sessionString = [obj objectAtIndex:1];
	NSArray *sObjArray = [sessionString componentsSeparatedByString:@"="];
	NSString *sessionId = [sObjArray objectAtIndex:2];
	*/
	
	if ([rsltStr isEqualToString:@"OK"]) {
		
		infoField.textColor = [UIColor whiteColor];
		infoField.text = @"Signing In... DONE!";
		
		//iMogulAppDelegate *appDelegate = (iMogulAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate set_isLoggedIn:YES];
		
		// save the session id
		[appDelegate setSessionId:sessionId];
		[appDelegate setUserId:userId];
		
		// save user details to a propertylist
		NSString *usr = [userNameField text];
		NSString *pwd = [passWordField text];
		usr = [usr lowercaseString];
		
		// write out to app preferences
		[appDelegate saveToPreferences:usr andPassword:pwd];
		
		// write out user object to plist
		//NSDictionary *details = [[NSDictionary alloc] initWithObjectsAndKeys:sessionId,@"sessionId",usr,@"username",pwd,@"password",nil];
		//[self writeUserDetailsToPlist:details];		
		
	} else {
		
		infoField.textColor = [UIColor yellowColor];
		infoField.text = @"Provided Username & Password\nCombonation Does Not Exist!";
		[userNameField setEnabled:YES];	// enable the username field...
		[passWordField setEnabled:YES];	// enable the password field...
		[passWordField setText:@""];	// zap the password field...
		//[saveSwitch setEnabled:YES];	// enable the toggle switch...
		[self.loginButton setEnabled:YES];	// enable the login button...
		[userNameField becomeFirstResponder];
		return;
		
	}
	
		// set the flag the prepare to grab features
	featuresFetched = NO;
	
		// zap book data
	[self removeData:@"Book"];
	
		// get all of the data
	[self fetchWowioData];
}

- (void)writeUserDetailsToPlist:(NSDictionary *)ud {
	
		// write user details to plist
	[ud writeToFile:[appDelegate userProfilePath] atomically:YES];
}


#pragma mark -
#pragma mark Text Field Action Methods

-(IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

-(IBAction)moveToPasswordField:(id)sender {
	[passWordField becomeFirstResponder];
}

-(IBAction)backgroundClickAction:(id)sender {
	
	[self.userNameField resignFirstResponder];
	[self.passWordField resignFirstResponder];
}


#pragma mark -
#pragma mark Table Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"FormTableCell";
	
	FormCell *cell = (FormCell *)[[self theTableView] dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		CGRect fldRect = CGRectMake(1.0, 5.0, 500.0, 170.0);
		cell = [[[FormCell alloc] initWithFrame:fldRect reuseIdentifier:CellIdentifier] autorelease];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

- (void)configureCell:(FormCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	switch (row) {
		case 0:
			[cell.fldLabel setText:@"Username"];
			[cell.fldData setPlaceholder:@"WOWIO Username"];
			[cell.fldData setReturnKeyType:UIReturnKeyNext];
			[cell.fldData addTarget:self action:@selector(moveToPasswordField:) forControlEvents:UIControlEventEditingDidEndOnExit];
			self.userNameField = cell.fldData;
			break;
		case 1:
			[cell.fldLabel setText:@"Password"];
			[cell.fldData setPlaceholder:@"Password"];
			[cell.fldData setSecureTextEntry:YES];
			[cell.fldData setReturnKeyType:UIReturnKeyDone];
			[cell.fldData addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
			self.passWordField = cell.fldData;
			break;
			
		default:
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// deselect the table row
	[self performSelector:@selector(deselect)];
	
}

- (void) deselect
{
	[self.theTableView deselectRowAtIndexPath:[self.theTableView indexPathForSelectedRow] animated:YES];
}


#pragma mark -
#pragma mark Fetch Methods

-(void)fetchWowioData {
	
	if ([self internetCheck]) {
		
		[progressIndicator setHidden:NO];
		[progressIndicator setProgress:0.0];
		
		NSString *sessionId = [appDelegate sessionId];
		
		self.infoField.text = @"Downloading Book Information";
		[self.infoField setFont:[UIFont systemFontOfSize:12.0]];
		
		// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDownloadProgressDelegate:progressIndicator];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
		
		int i;
		int urlCnt = [self.urlArray count];
		for (i=0; i<urlCnt; i++) {
			
			NSString *url = (NSString *) [urlArray objectAtIndex:i];
			
			// build the request
			ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] 
										initWithURL:[NSURL 
													 URLWithString:url]] autorelease];
			[request setTimeOutSeconds:20];
			[request setRequestMethod:@"GET"];
			[request addRequestHeader:@"Cookie" value:sessionId];
			
			// add the request to the transmission queue and set it off
			[self.networkQueue addOperation:request];
		}
		[self.networkQueue go];
		
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSString *errorString = @"A communication error occurred.\n\nPlease retry your request later.";
	[appDelegate alertWithMessage:errorString withTitle:@"WOWIO"];
	self.infoField.text = @"";
	return;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	++fetchCount;
	
	NSString *rsltStr = [request responseString];
	//NSDictionary *responseHeaders = [request responseHeaders];
	//NSDictionary *requestHeaders = [request requestHeaders];
	
	//NSLog(@"Response String: %@\n\n",rsltStr);
	//NSLog(@"Request Headers: %@\n\n",requestHeaders);
	//NSLog(@"Response Headers: %@\n\n",responseHeaders);
	
	// NEW JSON WAY
	NSData *jsonData = [rsltStr dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSMutableDictionary *feed = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	//NSLog(@"Returned Feed:\n%@\n\n",feed);
	
	if ([feed objectForKey:@"categorybookcount"]) {

		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"categorybookcount"];
		//NSLog(@"Category Totals:\n%@\n\n",obj);
		[self writeCategoryDataToDB:obj];
		
	} else if ([feed objectForKey:@"user"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"user"];
			//NSLog(@"User Object:\n%@\n\n",obj);
		[self writeUserDataToDB:obj];
		
	} else if ([feed objectForKey:@"lib_purchased"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"lib_purchased"];
			//NSLog(@"User Library:\n%@\n\n",obj);
		[self writeBookDataToDB:@"Library" withData:obj];
		
	} else if ([feed objectForKey:@"agilespace"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"agilespace"];
		//NSLog(@"Agile Space Object:\n%@\n\n",obj);
		[self writeBookDataToDB:@"Agilespace" withData:obj];
		
	} else if ([feed objectForKey:@"home_topbooks"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_topbooks"];
			//NSLog(@"\nTop Books:\n%@\n\n",obj);
		[self writeBookDataToDB:@"Topbooks" withData:obj];
		
		
	} else if ([feed objectForKey:@"home_topcomics"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_topcomics"];
		[self writeBookDataToDB:@"Topcomics" withData:obj];
		
	} else if ([feed objectForKey:@"home_brainbytes"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_brainbytes"];
		[self writeBookDataToDB:@"brainbytes" withData:obj];
		
	} else if ([feed objectForKey:@"home_newreleases"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_newreleases"];
			//NSLog(@"New Releases:\n%@\n\n",obj);
		[self writeBookDataToDB:@"Newreleases" withData:obj];
		
	} else if ([feed objectForKey:@"home_sponsored"]) {
		
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_sponsored"];		
		[self writeBookDataToDB:@"Sponsored" withData:obj];
		
	} else if ([feed objectForKey:@"home_featuredbook"]) {
		
		//NSLog(@"Found Featured Books");
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_featuredbook"];
		//NSLog(@"\n%@",obj);
		
		[self writeBookDataToDB:@"Featuredbooks" withData:obj];
		
	} else if ([feed objectForKey:@"home_staffpicks"]) {
		
		//NSLog(@"Found Staff Picks");
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_staffpicks"];
		//NSLog(@"\n%@",obj);
		
		[self writeBookDataToDB:@"Staffpicks" withData:obj];
		
	} else if ([feed objectForKey:@"home_featuredpublisher"]) {
		
		//NSLog(@"Found Featured Publishers");
		NSMutableArray *obj = (NSMutableArray*)[feed objectForKey:@"home_featuredpublisher"];
		//NSLog(@"\n%@",obj);
		
		[self writeBookDataToDB:@"Featuredpublishers" withData:obj];
	}	
	
	// show the app interface
	int urlCnt = [self.urlArray count];
	if (fetchCount == urlCnt) {
		[infoField setText:@""];
		[progressIndicator setHidden:YES];
		[progressIndicator setProgress:0.0];
		[delegate didDismissModalView];
		//featuresFetched = YES;
		//[self fetchFeatures];
	}
	
	if (featuresFetched)
		[delegate didDismissModalView];
}


#pragma mark -
#pragma mark Features Methods

-(void)fetchFeatures {
	
	if ([self internetCheck]) {
		
		[progressIndicator setHidden:NO];
		[progressIndicator setProgress:0.0];
		
		NSString *sessionId = [appDelegate sessionId];
		
		self.infoField.text = @"Fetching Features...";
		
		// initialize the transmission queue
		[self setNetworkQueue:[ASINetworkQueue queue]];
		[self.networkQueue cancelAllOperations];
		[self.networkQueue setDownloadProgressDelegate:progressIndicator];
		[self.networkQueue setDelegate:self];
		[self.networkQueue setMaxConcurrentOperationCount:5];
		[self.networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
		[self.networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
		
			
		// build the request
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:homepageAgileSpaceURL]] autorelease];
		[request setTimeOutSeconds:20];
		[request setRequestMethod:@"GET"];
		[request addRequestHeader:@"Cookie" value:sessionId];
			
		// add the request to the transmission queue and set it off
		[self.networkQueue addOperation:request];
		[self.networkQueue go];
		
	}
}


#pragma mark -
#pragma mark Database Methods

-(BOOL)bookInUserLibrary:(NSNumber*)bookid forOrderid:(NSNumber*)orderid {
	
	BOOL luResult;
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
	// set the filter predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookid=%d and orderbookid = %@",[bookid intValue],orderid];
	[fetchRequest setPredicate:predicate];
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		return NO;
	}
	
	if ([mutableFetchResults count] >0)
		luResult = YES;
	else 
		luResult = NO;
	
	// clean up after yourself
	//[predicate release];
	
	return luResult;
}

-(void)removeData:(NSString*)theEntity {
	
	int i;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity;
	if (entity = [NSEntityDescription entityForName:theEntity 
							 inManagedObjectContext:self.managedObjectContext]) {
		
		[fetchRequest setEntity:entity];
		
		NSError *error;
		NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];		
		[fetchRequest release];
		
		for (i = 0; i<[items count]; i++) {
			NSManagedObject *managedObject = [items objectAtIndex:i];		
			[self.managedObjectContext deleteObject:managedObject];
		}
	}
}

-(void)removeBookData:(NSString*)theEntity forFilter:(NSString*)theFilter {
	
	int i;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity;
	if (entity = [NSEntityDescription entityForName:theEntity 
							 inManagedObjectContext:self.managedObjectContext]) {
		
		[fetchRequest setEntity:entity];
		
			// set the filter predicate
		NSPredicate *predicate = [NSPredicate
								  predicateWithFormat:@"%@=1",theFilter];
		[fetchRequest setPredicate:predicate];

		NSError *error;
		NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];		
		[fetchRequest release];
		
		for (i = 0; i<[items count]; i++) {
			NSManagedObject *managedObject = [items objectAtIndex:i];		
			[self.managedObjectContext deleteObject:managedObject];
		}
	}
}




-(void)writeCategoryDataToDB:(NSMutableArray *)data {
	
	// remove existing categories from db
	[self removeData:@"Categories"];
	
	
	int i;
	for (i=0; i<[data count]; i++) {
		Categories * cats = (Categories *)[NSEntityDescription 
										   insertNewObjectForEntityForName:@"Categories" 
										   inManagedObjectContext:self.managedObjectContext];
		
		NSArray *obj = [data objectAtIndex:i];
		NSString *bookcategory = [obj valueForKey:@"bookcategory"];
		NSNumber *bookcategoryid = [obj valueForKey:@"bookcategoryid"];
		NSNumber *bookcount = [obj valueForKey:@"bookcount"];
		NSNumber *totalbooks = [obj valueForKey:@"totalbooks"];
		
		[cats setBookcount:bookcount];
		[cats setBookcategory:bookcategory];
		[cats setBookcategoryid:bookcategoryid];
		[cats setTotalbooks:totalbooks];
		
		// write it to db
		[self saveAction];
	}
}

-(void)writeUserDataToDB:(NSMutableArray *)data {
 
	// remove existing user data from db
	[self removeData:@"User"];
 
	NSLog(@"%@",data);
	
	User * newUser = (User *)[NSEntityDescription 
							  insertNewObjectForEntityForName:@"User" 
							  inManagedObjectContext:self.managedObjectContext];
	
	
	NSArray *obj = [data objectAtIndex:0];
	 
	NSString *address1 = [obj valueForKey:@"address1"];
	NSString *address2 = [obj valueForKey:@"address2"];
	NSNumber *authorizationtype = [obj valueForKey:@"authorizationtype"];
	NSNumber *balance = [obj valueForKey:@"balance"];
	NSNumber *bbooksready = [obj valueForKey:@"bbooksready"];
	NSNumber *bdismissgifthelp1 = [obj valueForKey:@"bdismissgifthelp1"];
	NSNumber *bdismissqueuedlg1 = [obj valueForKey:@"bdismissqueuedlg1"];
	NSNumber *bdismissqueuedlg2 = [obj valueForKey:@"bdismissqueuedlg2"];
	NSNumber *bdismissqueuedlg3 = [obj valueForKey:@"bdismissqueuedlg3"];
	NSNumber *bdismissqueuedlg4 = [obj valueForKey:@"bdismissqueuedlg4"];
	NSString *begindate = [obj valueForKey:@"begindate"];
	NSNumber *bfreegiftbook = [obj valueForKey:@"bfreegiftbook"];
	NSString *birthdate = [obj valueForKey:@"birthdate"];
	NSNumber *bphantom = [obj valueForKey:@"bphantom"];
	NSNumber *bshowsmileyhelp = [obj valueForKey:@"bshowsmileyhelp"];
	NSString *cardfirstname = [obj valueForKey:@"cardfirstname"];
	NSString *cardlastname = [obj valueForKey:@"cardlastname"];
	NSNumber *ccid = [obj valueForKey:@"ccid"];
	NSString *city = [obj valueForKey:@"city"];
	NSString *countrycode = [obj valueForKey:@"countrycode"];
	NSString *emailaddress = [obj valueForKey:@"emailaddress"];
	NSString *enddate = [obj valueForKey:@"enddate"];
	NSString *firstname = [obj valueForKey:@"firstname"];
	NSString *initialip = [obj valueForKey:@"initialip"];
	NSString *initialipcountry = [obj valueForKey:@"initialipcountry"];
	NSString *lastchangedate = [obj valueForKey:@"lastchangedate"];
	NSString *lastip = [obj valueForKey:@"lastip"];
	NSString *lastipcountry = [obj valueForKey:@"lastipcountry"];
	NSString *lastlogondate = [obj valueForKey:@"lastlogondate"];
	NSString *lastorderdate = [obj valueForKey:@"lastorderdate"];
	NSString *lastname = [obj valueForKey:@"lastname"];
	NSString *newpasswordcode = [obj valueForKey:@"newpasswordcode"];
	NSString *newpasswordexpirationdate = [obj valueForKey:@"newpasswordexpirationdate"];
	NSString *password = [obj valueForKey:@"password"];
	NSNumber *profilecount = [obj valueForKey:@"profilecount"];
	NSNumber *recstatus = [obj valueForKey:@"recstatus"];
	NSString *rescountrycode = [obj valueForKey:@"rescountrycode"];
	NSString *reszipcode = [obj valueForKey:@"reszipcode"];
	NSNumber *userid = [obj valueForKey:@"userid"];
	NSString *state = [obj valueForKey:@"state"];
	NSString *zipcode = [obj valueForKey:@"zipcode"];
	
	// make sure there are no nulls
	if ([profilecount isKindOfClass:[NSNull class]])
		profilecount = 0;
	
	if ([reszipcode isKindOfClass:[NSNull class]])
		reszipcode = @"";
	
	if ([rescountrycode isKindOfClass:[NSNull class]])
		rescountrycode = @"";
	
	if ([recstatus isKindOfClass:[NSNull class]])
		recstatus = 0;
	
	if ([lastorderdate isKindOfClass:[NSNull class]])
		lastorderdate = @"";
	
	if ([lastlogondate isKindOfClass:[NSNull class]])
		lastlogondate = @"";
	
	if ([lastipcountry isKindOfClass:[NSNull class]])
		lastipcountry = @"";
	
	if ([lastip isKindOfClass:[NSNull class]])
		lastip = @"";
	
	if ([lastchangedate isKindOfClass:[NSNull class]])
		lastchangedate = @"";
	
	if ([initialipcountry isKindOfClass:[NSNull class]])
		initialipcountry = @"";
	
	if ([initialip isKindOfClass:[NSNull class]])
		initialip = @"";
	
	if ([address1 isKindOfClass:[NSNull class]])
		address1 = @"";
	
	if ([address2 isKindOfClass:[NSNull class]])
		address2 = @"";
	
	if ([cardfirstname isKindOfClass:[NSNull class]])
		cardfirstname = @"";
	
	if ([cardlastname isKindOfClass:[NSNull class]])
		cardlastname = @"";
	
	if ([ccid isKindOfClass:[NSNull class]])
		ccid = 0;
	
	if ([city isKindOfClass:[NSNull class]])
		city = @"";
	
	if ([countrycode isKindOfClass:[NSNull class]])
		countrycode = @"";
	
	if ([enddate isKindOfClass:[NSNull class]])
		enddate = @"";
	
	if ([lastorderdate isKindOfClass:[NSNull class]])
		lastorderdate = @"";
	
	if ([newpasswordcode isKindOfClass:[NSNull class]])
		newpasswordcode = @"";
	
	if ([newpasswordexpirationdate isKindOfClass:[NSNull class]])
		newpasswordexpirationdate = @"";
	
	if ([state isKindOfClass:[NSNull class]])
		state = @"";
	
	if ([zipcode isKindOfClass:[NSNull class]])
		zipcode = @"";
	
	if ([rescountrycode isKindOfClass:[NSNull class]])
		rescountrycode = @"";
	
	if ([reszipcode isKindOfClass:[NSNull class]])
		reszipcode = @"";
	
	[newUser setAddress1:address1];
	[newUser setAddress2:address2];
	[newUser setAuthorizationtype:authorizationtype];
	[newUser setBalance:balance];
	[newUser setBbooksready:bbooksready];
	[newUser setBdismissgifthelp1:bdismissgifthelp1];
	[newUser setBdismissqueuedlg1:bdismissqueuedlg1];
	[newUser setBdismissqueuedlg2:bdismissqueuedlg2];
	[newUser setBdismissqueuedlg3:bdismissqueuedlg3];
	[newUser setBdismissqueuedlg4:bdismissqueuedlg4];
	[newUser setBegindate:begindate];
	[newUser setBfreegiftbook:bfreegiftbook];
	[newUser setBirthdate:birthdate];
	[newUser setBphantom:bphantom];
	[newUser setBshowsmileyhelp:bshowsmileyhelp];
	[newUser setCardfirstname:cardfirstname];
	[newUser setCardlastname:cardlastname];
	[newUser setCcid:[ccid stringValue]];
	[newUser setCity:city];
	[newUser setCountrycode:countrycode];
	[newUser setEmailaddress:emailaddress];
	[newUser setEnddate:enddate];
	[newUser setFirstname:firstname];
	[newUser setInitialip:initialip];
	[newUser setInitialipcountry:initialipcountry];
	[newUser setLastchangedate:lastchangedate];
	[newUser setLastip:lastip];
	[newUser setLastipcountry:lastipcountry];
	[newUser setLastlogondate:lastlogondate];
	[newUser setLastname:lastname];
	[newUser setLastorderdate:lastorderdate];
	[newUser setNewpasswordcode:newpasswordcode];
	[newUser setNewpasswordexpirationdate:newpasswordexpirationdate];
	[newUser setPassword:password];
	[newUser setProfilecount:profilecount];
	[newUser setRecstatus:recstatus];
	[newUser setRescountrycode:rescountrycode];
	[newUser setReszipcode:reszipcode];
	[newUser setState:state];
	[newUser setUserid:userid];
	[newUser setZipcode:zipcode];
	 
	// write it to db
	[self saveAction];
	 
}

-(void)writeBookDataToDB:(NSString*)tablename withData:(NSMutableArray *)data {
	
	int i;
	
		// flush existing data from selected table
	if (![tablename isEqualToString:@"Library"])
		[self removeData:tablename];
	//else
		//[self removeData:@"Library"];
		
	
	if ([tablename isEqualToString:@"Agilespace"]) {
		
		for (i = 0; i<[data count]; i++) {
			Agilespace *item = (Agilespace *)[NSEntityDescription 
											  insertNewObjectForEntityForName:@"Agilespace" 
											  inManagedObjectContext:self.managedObjectContext];
			
			NSArray *obj = [data objectAtIndex:i];
			NSNumber *bookid = [obj valueForKey:@"bookid"];
			NSString *details = [obj valueForKey:@"description"];
			NSString *contenthtml = [obj valueForKey:@"contenthtml"];
			NSString *contenthtmlipad = [obj valueForKey:@"contenthtmlipad"];
			//NSNumber *totalrecords = [obj valueForKey:@"totalrecords"];
			
			//[item setTotalrecords:totalrecords];
			[item setBookid:bookid];
			[item setDetails:details];
			[item setContenthtml:contenthtml];
			[item setContenthtmlipad:contenthtmlipad];
			
				//NSLog(@"%@",contenthtmlipad);
			
			// write it to db
			[self saveAction];
		}
			
	} else if ([tablename isEqualToString:@"Featuredpublishers"]) {
		
		for (i = 0; i<[data count]; i++) {
			Featuredpublishers *book = (Featuredpublishers *)[NSEntityDescription 
															  insertNewObjectForEntityForName:@"Featuredpublishers" 
															  inManagedObjectContext:self.managedObjectContext];
			
			NSArray *obj = [data objectAtIndex:i];
			NSNumber *bookid = [obj valueForKey:@"bookid"];
			NSString *coverimagepath_s = [obj valueForKey:@"coverimagepath_s"];
			NSString *details = [obj valueForKey:@"description"];
			NSNumber *mainbookcategoryid = [obj valueForKey:@"mainbookcategoryid"];
			NSNumber *publisherid = [obj valueForKey:@"publisherid"];
			NSString *publisherurl = [obj valueForKey:@"publisherurl"];
			NSString *booktitle = [obj valueForKey:@"title"];
			NSNumber *retailprice = [obj valueForKey:@"retailprice"];
			NSString *authorname = [obj valueForKey:@"authorname"];
				//NSString *publishername = [obj valueForKey:@"publishername"];
			
			if ([coverimagepath_s isKindOfClass:[NSNull class]])
				coverimagepath_s = @"";
			
			if ([publisherurl isKindOfClass:[NSNull class]])
				publisherurl = @"";
			
			[book setBookid:bookid];
			[book setCoverimagepath_s:coverimagepath_s];
			[book setDetails:details];
			[book setMainbookcategoryid:mainbookcategoryid];
			[book setPublisherurl:publisherurl];
			[book setPublisherid:publisherid];
			[book setTitle:booktitle];
			[book setRetailprice:retailprice];
			[book setAuthorname:authorname];
				//[book setPublishername:publishername];
			
				// write it to db
			[self saveAction];
		}
	
	/*} else if ([tablename isEqualToString:@"Library"]) {
		
		for (i = 0; i<[data count]; i++) {
			Library *book = (Library *)[NSEntityDescription 
													insertNewObjectForEntityForName:@"Library" 
													inManagedObjectContext:self.managedObjectContext];
			
			NSArray *obj = [data objectAtIndex:i];
			NSNumber *bookid = [obj valueForKey:@"bookid"];
			NSNumber *orderbookid = [obj valueForKey:@"orderbookid"];
			
			if (![self bookInUserLibrary:bookid forOrderid:orderbookid]) {
				
				NSNumber *booktypeid = [obj valueForKey:@"booktypeid"];
				NSNumber *contentratingid = [obj valueForKey:@"contentratingid"];
				NSNumber *orderbookstatus = [obj valueForKey:@"orderbookstatus"];
				NSNumber *downloadsuccess = [obj valueForKey:@"downloadsuccess"];
				NSNumber *loboserverid = [obj valueForKey:@"loboserverid"];
				NSString *filepath = [obj valueForKey:@"filepath"];
				NSString *details = [obj valueForKey:@"description"];
				NSString *orderdate = [obj valueForKey:@"orderdate"];
				if ([orderdate isKindOfClass:[NSNull class]])
					orderdate = @"";
				NSString *internalip = [obj valueForKey:@"internalip"];
				NSString *externalip = [obj valueForKey:@"externalip"];
				NSString *downloaddate = [obj valueForKey:@"downloaddate"];
				if ([downloaddate isKindOfClass:[NSNull class]])
					downloaddate = @"";
				
				NSNumber *admodelid = [obj valueForKey:@"admodelid"];
				if ([admodelid isKindOfClass:[NSNull class]])
					admodelid = [NSNumber numberWithInt:0];
				NSNumber *adid = [obj valueForKey:@"adid"];
				if ([adid isKindOfClass:[NSNull class]])
					adid = [NSNumber numberWithInt:0];
				
				NSNumber *bnoimage = [obj valueForKey:@"bnoimage"];
				NSString *imagesubpath = [obj valueForKey:@"imagesubpath"];
				if ([imagesubpath isKindOfClass:[NSNull class]])
					imagesubpath = @"";
				
				NSString *imagepath = [obj valueForKey:@"imagepath"];
				if ([imagepath isKindOfClass:[NSNull class]])
					imagepath = @"";
				
				NSString *largeimagepath = [obj valueForKey:@"largeimagepath"];
				if ([largeimagepath isKindOfClass:[NSNull class]])
					largeimagepath = @"";
				
				NSNumber *bookcategoryid = [obj valueForKey:@"bookcategoryid"];
				if ([bookcategoryid isKindOfClass:[NSNull class]])
					bookcategoryid = [NSNumber numberWithInt:0];
				
				NSNumber *bookcategory = [obj valueForKey:@"bookcategory"];
				if ([bookcategory isKindOfClass:[NSNull class]])
					bookcategory = [NSNumber numberWithInt:0];
				
				NSString *indexname = [obj valueForKey:@"indexname"];
				if ([indexname isKindOfClass:[NSNull class]])
					indexname = @"";
				
				NSNumber *publisherid = [obj valueForKey:@"publisherid"];
				if ([publisherid isKindOfClass:[NSNull class]])
					publisherid = [NSNumber numberWithInt:0];
				
				NSNumber *bookformat = [obj valueForKey:@"bookformat"];
				if ([bookformat isKindOfClass:[NSNull class]])
					bookformat = [NSNumber numberWithInt:0];
				
				NSString *booktitle = [obj valueForKey:@"title"];
				NSString *sorttitle = [obj valueForKey:@"sorttitle"];
				NSString *authorname = [obj valueForKey:@"authorname"];
				NSNumber *retailprice = [obj valueForKey:@"retailprice"];
				NSNumber *thankyoucount = [obj valueForKey:@"thankyoucount"];
				NSNumber *previewpagecount = [obj valueForKey:@"previewpagecount"];
				NSNumber *avgrating = [obj valueForKey:@"avgrating"];
				NSString *avgRatingString = [avgrating stringValue];
				avgRatingString = [avgRatingString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
				
				NSNumber *ratingcount = [obj valueForKey:@"ratingcount"];
				NSNumber *userrating = [obj valueForKey:@"userrating"];
				
				[book setBookid:bookid];
				[book setBookformat:bookformat];
				[book setImagesubpath:imagesubpath];
				[book setImagepath:imagepath];
				[book setLargeimagepath:largeimagepath];
				[book setBnoimage:bnoimage];
				[book setBooktypeid:booktypeid];
				[book setOrderbookid:orderbookid];
				[book setContentratingid:contentratingid];
				[book setOrderbookstatus:orderbookstatus];
				book.downloadsuccess = downloadsuccess;
				book.admodelid = admodelid;
				book.adid = adid;
				book.orderdate = orderdate;
				book.internalip = internalip;
				book.externalip = externalip;
				book.downloaddate = downloaddate;
				book.indexname = indexname;
				book.title = booktitle;
				book.sorttitle = sorttitle;
				book.authorname = authorname;
				book.retailprice = retailprice;
				book.thankyoucount = thankyoucount;
				book.previewpagecount = previewpagecount;
				book.publisherid = publisherid;
				book.authorname = authorname;
				book.avgrating = avgRatingString;
				book.ratingcount = ratingcount;
				book.userrating = userrating;			
				book.loboserverid = loboserverid;			
				book.imagepath = imagepath;			
				book.filepath = filepath;			
				book.details = details;			
				book.bookcategoryid = bookcategoryid;			
				book.bookcategory = bookcategory;			
				
				// write it to db
				[self saveAction];
			}
		}*/
		
	} else if ([tablename isEqualToString:@"Topbooks"] || [tablename isEqualToString:@"Topcomics"] || [tablename isEqualToString:@"Featuredbooks"] || [tablename isEqualToString:@"Newreleases"] || [tablename isEqualToString:@"Staffpicks"] || [tablename isEqualToString:@"Sponsored"] || [tablename isEqualToString:@"brainbytes"]) {
		
		NSNumber *is_topseller;
		NSNumber *is_featured;
		NSNumber *is_staffpick;
		NSNumber *is_newrelease;
		NSNumber *is_sponsored;
		NSNumber *is_brainbyte;
			
		if ([tablename isEqualToString:@"Topcomics"]) {
			
			for (i = 0; i<[data count]; i++) {
				
				Book *book = (Book *)[NSEntityDescription 
									  insertNewObjectForEntityForName:@"Book" 
									  inManagedObjectContext:self.managedObjectContext];
				
				NSArray *obj = [data objectAtIndex:i];
				NSString *groupname = [obj valueForKey:@"groupname"];
				NSNumber *bookid = [obj valueForKey:@"bookid"];
				NSString *coverimagepath_l = [obj valueForKey:@"coverimagepath_l"];
				NSString *coverimagepath_s = [obj valueForKey:@"coverimagepath_s"];
				NSNumber *bookgroupid = [obj valueForKey:@"bookgroupid"];
				NSString *details = [obj valueForKey:@"description"];
				NSNumber *mainbookcategoryid = [obj valueForKey:@"mainbookcategoryid"];
				NSString *publicationdate = [obj valueForKey:@"publicationdate"];
				NSString *booktitle = [obj valueForKey:@"title"];
				NSNumber *downloadcount = [obj valueForKey:@"downloadcount"];
				NSNumber *rank = [obj valueForKey:@"rank"];
				NSNumber *tcdid = [obj valueForKey:@"tcdid"];
				NSNumber *retailprice = [obj valueForKey:@"retailprice"];
				NSNumber *pagecount = [obj valueForKey:@"pagecount"];
				NSNumber *downloadsum = [obj valueForKey:@"downloadsum"];
				NSString *reportdate = [obj valueForKey:@"reportdate"];
				NSString *authorname = [obj valueForKey:@"authorname"];
				NSString *publishername = [obj valueForKey:@"publishername"];
				
				if ([details isKindOfClass:[NSNull class]])
					details = @"";
				
				if ([coverimagepath_l isKindOfClass:[NSNull class]])
					coverimagepath_l = @"";
				
				if ([coverimagepath_s isKindOfClass:[NSNull class]])
					coverimagepath_s = @"";
				
				if ([groupname isKindOfClass:[NSNull class]])
					groupname = @"";
				
				[book setIs_topcomic:[NSNumber numberWithInt:1]];
				[book setGroupname:groupname];
				[book setBookid:bookid];
				[book setCoverimagepath_l:coverimagepath_l];
				[book setCoverimagepath_s:coverimagepath_s];
				[book setBookgroupid:bookgroupid];
				[book setDetails:details];
				[book setMainbookcategoryid:mainbookcategoryid];
				[book setPublicationdate:publicationdate];
				[book setTitle:booktitle];
				[book setDownloadsum:downloadsum];
				[book setDownloadcount:downloadcount];
				[book setRank:rank];
				[book setTcdid:tcdid];
				[book setRetailprice:retailprice];
				[book setPagecount:pagecount];
				[book setReportdate:reportdate];
				[book setAuthorname:authorname];
				[book setPublishername:publishername];
				
					// write it to db
				[self saveAction];
			}
			
		} else {
		
			for (i = 0; i<[data count]; i++) {
				
				if ([tablename isEqualToString:@"Topbooks"]) {
						//NSLog(@"top books object: %@",data);
					is_topseller = [NSNumber numberWithInt:1];
				} else {
					is_topseller = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"Featuredbooks"]) {
					is_featured = [NSNumber numberWithInt:1];
				} else {
					is_featured = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"Newreleases"]) {
						//NSLog(@"new release books object: %@",data);
					is_newrelease = [NSNumber numberWithInt:1];
				} else {
					is_newrelease = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"Staffpicks"]) {
					is_staffpick = [NSNumber numberWithInt:1];
				} else {
					is_staffpick = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"Sponsored"]) {
					is_sponsored = [NSNumber numberWithInt:1];
				} else {
					is_sponsored = [NSNumber numberWithInt:0];
				}
				
				if ([tablename isEqualToString:@"brainbytes"]) {
					is_brainbyte = [NSNumber numberWithInt:1];
				} else {
					is_brainbyte = [NSNumber numberWithInt:0];
				}
				
				
				Book *book = (Book *)[NSEntityDescription 
									  insertNewObjectForEntityForName:@"Book" 
									  inManagedObjectContext:self.managedObjectContext];
				
				NSArray *obj = [data objectAtIndex:i];
				NSNumber *bookid = [obj valueForKey:@"bookid"];
				NSNumber *becommerce = [obj valueForKey:@"becommerce"];
				NSNumber *bnodrm = [obj valueForKey:@"bnodrm"];
				NSNumber *bnoimage = [obj valueForKey:@"bnoimage"];
				NSNumber *bavailable = [obj valueForKey:@"bavailable"];
				NSNumber *bbooksponsor = [obj valueForKey:@"bbooksponsor"];
				NSString *isbn = [obj valueForKey:@"isbn"];
				NSString *coverimagepath_l = [obj valueForKey:@"coverimagepath_l"];
				NSString *coverimagepath_s = [obj valueForKey:@"coverimagepath_s"];
				NSString *imagesubpath = [obj valueForKey:@"imagesubpath"];
				NSString *details = [obj valueForKey:@"description"];
				NSString *indexname = [obj valueForKey:@"indexname"];
				if ([imagesubpath isKindOfClass:[NSNull class]]) {
					imagesubpath = @"";
				}
				if ([indexname isKindOfClass:[NSNull class]]) {
					indexname = @"";
				}
				NSNumber *mainbookcategoryid = [obj valueForKey:@"mainbookcategoryid"];
				NSString *publicationdate = [obj valueForKey:@"publicationdate"];
				NSString *booktitle = [obj valueForKey:@"title"];
				NSNumber *retailprice = [obj valueForKey:@"retailprice"];
				NSNumber *pagecount = [obj valueForKey:@"pagecount"];
				NSNumber *purchased = [obj valueForKey:@"purchased"];
				NSNumber *previewpagecount = [obj valueForKey:@"previewpagecount"];
				NSString *authorname = [obj valueForKey:@"authorname"];
				NSNumber *publisherid = [obj valueForKey:@"publisherid"];
					//NSLog(@"Publisher id: %@",publisherid);
				NSString *publishername = [obj valueForKey:@"publishername"];
				if ([publishername isKindOfClass:[NSNull class]]) {
					publishername = @"";
				}
				NSNumber *recstatus = [obj valueForKey:@"recstatus"];
				NSNumber *ratingcount = [obj valueForKey:@"ratingcount"];
				NSString *ratingString = [ratingcount stringValue];
				NSNumber *avgrating = [obj valueForKey:@"avgrating"];
				NSString *avgRatingString = [avgrating stringValue];
				avgRatingString = [avgRatingString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
				
				NSString *sorttitle = [obj valueForKey:@"sorttitle"];

				NSString *filesize = [obj valueForKey:@"filesize"];

				NSString *ade_epub_filesize = [obj valueForKey:@"ade_epub_filesize"];
				NSNumber *ade_epub_retailprice = [obj valueForKey:@"ade_epub_retailprice"];
				NSString *ade_epub_sku13 = [obj valueForKey:@"ade_epub_sku13"];
				NSString *ade_pdf_filesize = [obj valueForKey:@"ade_pdf_filesize"];
				NSNumber *ade_pdf_retailprice = [obj valueForKey:@"ade_pdf_retailprice"];
				NSString *ade_pdf_sku13 = [obj valueForKey:@"ade_pdf_sku13"];
				
				NSNumber *bformatade_epub = [obj valueForKey:@"bformatade_epub"];
				NSNumber *bformatade_pdf = [obj valueForKey:@"bformatade_pdf"];
				NSNumber *bformatwowio = [obj valueForKey:@"bformatwowio"];
				
				NSString *epub_filesize = [obj valueForKey:@"epub_filesize"];
				NSNumber *epub_retailprice = [obj valueForKey:@"epub_retailprice"];
				NSString *epub_sku13 = [obj valueForKey:@"epub_sku13"];
				NSString *ereader_filesize = [obj valueForKey:@"ereader_filesize"];
				NSNumber *ereader_retailprice = [obj valueForKey:@"ereader_retailprice"];
				NSString *ereader_sku13 = [obj valueForKey:@"ereader_sku13"];
				
				if ([filesize isKindOfClass:[NSNull class]])
					filesize = @"";
				
				if ([ade_epub_filesize isKindOfClass:[NSNull class]])
					ade_epub_filesize = @"";
				
				if ([ade_epub_retailprice isKindOfClass:[NSNull class]])
					ade_epub_retailprice = [NSNumber numberWithFloat:0.00];
				
				if ([ade_epub_sku13 isKindOfClass:[NSNull class]])
					ade_epub_sku13 = @"";
				
				if ([ade_pdf_filesize isKindOfClass:[NSNull class]])
					ade_pdf_filesize = @"";
				
				if ([ade_pdf_retailprice isKindOfClass:[NSNull class]])
					ade_pdf_retailprice = [NSNumber numberWithFloat:0.00];
				
				if ([ade_pdf_sku13 isKindOfClass:[NSNull class]])
					ade_pdf_sku13 = @"";
				
				if ([bformatade_epub isKindOfClass:[NSNull class]])
					bformatade_epub = 0;
				
				if ([bformatade_pdf isKindOfClass:[NSNull class]])
					bformatade_pdf = 0;
				
				if ([bformatwowio isKindOfClass:[NSNull class]])
					bformatwowio = 0;
				
				if ([epub_filesize isKindOfClass:[NSNull class]])
					epub_filesize = @"";
				
				if ([epub_retailprice isKindOfClass:[NSNull class]])
					epub_retailprice = [NSNumber numberWithFloat:0.00];
				
				if ([epub_sku13 isKindOfClass:[NSNull class]])
					epub_sku13 = @"";
				
				if ([ereader_filesize isKindOfClass:[NSNull class]])
					ereader_filesize = @"";
				
				if ([ereader_retailprice isKindOfClass:[NSNull class]])
					ereader_retailprice = [NSNumber numberWithFloat:0.00];
				
				if ([ereader_sku13 isKindOfClass:[NSNull class]])
					ereader_sku13 = @"";
				
				if ([imagesubpath isKindOfClass:[NSNull class]])
					imagesubpath = @"";
				
				if ([coverimagepath_l isKindOfClass:[NSNull class]])
					coverimagepath_l = @"";
				
				if ([coverimagepath_s isKindOfClass:[NSNull class]])
					coverimagepath_s = @"";
				
				if ([publishername isKindOfClass:[NSNull class]])
					publishername = @"";
				
				if ([sorttitle isKindOfClass:[NSNull class]])
					sorttitle = @"";
				
				[book setBookid:bookid];
				[book setIs_topseller:is_topseller];
				[book setIs_newrelease:is_newrelease];
				[book setIs_staffpick:is_staffpick];
				[book setIs_brainbyte:is_brainbyte];
				[book setIs_sponsored:is_sponsored];
				[book setIs_featured:is_featured];
				[book setSorttitle:sorttitle];
				[book setFilesize:filesize];
				[book setAde_epub_filesize:ade_epub_filesize];
				[book setAde_epub_retailprice:ade_epub_retailprice];
				[book setAde_epub_sku13:ade_epub_sku13];
				[book setAde_pdf_filesize:ade_pdf_filesize];
				[book setAde_pdf_retailprice:ade_pdf_retailprice];
				[book setAde_pdf_sku13:ade_pdf_sku13];
				[book setBformatade_epub:bformatade_epub];
				[book setBformatade_pdf:bformatade_pdf];
				[book setBformatwowio:bformatwowio];
				[book setEpub_filesize:epub_filesize];
				[book setEpub_retailprice:epub_retailprice];
				[book setEpub_sku13:epub_sku13];
				[book setEreader_filesize:ereader_filesize];
				[book setEreader_retailprice:ereader_retailprice];
				[book setEreader_sku13:ereader_sku13];
				[book setBecommerce:becommerce];
				[book setBnodrm:bnodrm];
				[book setBnoimage:bnoimage];
				[book setBavailable:bavailable];
				[book setBbooksponsor:bbooksponsor];
				[book setIsbn:isbn];
				[book setIndexname:indexname];
				[book setCoverimagepath_l:coverimagepath_l];
				[book setCoverimagepath_s:coverimagepath_s];
				[book setImagesubpath:imagesubpath];
				[book setDetails:details];
				[book setMainbookcategoryid:mainbookcategoryid];
				[book setPublicationdate:publicationdate];
				[book setPurchased:purchased];
				[book setTitle:booktitle];
				[book setRetailprice:retailprice];
				[book setPagecount:pagecount];
				[book setPreviewpagecount:previewpagecount];
				[book setAuthorname:authorname];
				[book setPublisherid:publisherid];
				[book setPublishername:publishername];
				[book setRecstatus:recstatus];
				[book setRatingcount:ratingString];
				[book setAvgrating:avgRatingString];
				
					// write it to db
				[self saveAction];
			}
		}
	}
}

 - (void)saveAction {
 
	 NSError *error;
	 if (![self.managedObjectContext save:&error]) {
		 NSLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
		 exit(-1);
	 }
 }


#pragma mark -
#pragma mark Connectivity Check Method

-(BOOL)internetCheck {
	
	BOOL _isInternetConnectivity = YES;
	
	// check if there is internet connectivity
	[appDelegate performSelector:@selector(updateReachabilityStatus)];
	
	hostStatus = [appDelegate hostStatus];
	wifiStatus = [appDelegate wifiStatus];
	internetStatus = [appDelegate internetStatus];
	
	if (hostStatus == NotReachable && internetStatus == NotReachable && wifiStatus == NotReachable) {
		
		// alert the user that there is no internet connectivity
		NSString *errorString = @"There is Currently NO Internet Connectivity.\nYou will be unable to use the WOWIO bookstore effectively\nuntil connectivity has been restored.";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:errorString
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		_isInternetConnectivity = NO;
	}
	return _isInternetConnectivity;
}


#pragma mark -
#pragma mark Housekeeping Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	CGRect lframe;
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {

		lframe = CGRectMake(152.0, 229.0, 464.0, 546.0);
		self.loginView.frame = lframe;

		[self.backgroundImage setImage:[UIImage imageNamed:@"login_portrait.png"]];
	} else {
		
		lframe = CGRectMake(280.0, 101.0, 464.0, 546.0);
		self.loginView.frame = lframe;

		[self.backgroundImage setImage:[UIImage imageNamed:@"login_landscape.png"]];
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
	
	/*
	[loginButton release];
	[loginBackgroundButton release];
	[backgroundButton release];
	[backgroundImage release];
	[appDelegate release];
	[networkQueue release];
	[emailDefault release];
	[passwordDefault release];
	[userNameField release];
	[passWordField release];
	[progressIndicator release];
	[managedObjectContext release];
	[dataSource release];
	[theTableView release];
	[loginView release];
	[delegate release];
	[urlArray release];
	[joinButton release];
	[loginButton release];
	[infoField release];
	[loginBackgroundButton release];
	*/
}


@end
