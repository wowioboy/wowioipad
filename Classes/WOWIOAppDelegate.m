//
//  WOWIOAppDelegate.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright Pure Engineering 2010. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "WOWIOAppDelegate.h"
#import "Reachability.h"

@interface WOWIOAppDelegate()
- (NSString *)wowioHome;
@end

@implementation WOWIOAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize hostStatus, internetStatus, wifiStatus, _isLoggedIn, userId, sessionId;
@synthesize email, password;

+ (WOWIOAppDelegate *)sharedAppDelegate
{
    return (WOWIOAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        NSLog(@"\nNo Context");
    }
	
	// Check to see if the eval site is reachable
	hostReach = [[Reachability reachabilityWithHostName: @"http://www.wowio.com"] retain];
	[hostReach startNotifier];
	
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	
    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	
	// update network reachability...
	[self updateReachabilityStatus];
	
	// login using saved preferences...
	[self setupByPreferences];
	
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
	
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }	
}


#pragma mark -
#pragma mark App Settings

- (void)setupByPreferences
{
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"emailKey"];
	if (testValue == nil)
	{
		// no default values have been set, create them here based on what's in our Settings bundle info
		//
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
        
		NSDictionary *prefItem;
		NSString *emailDefault = nil;
		NSString *passwordDefault = nil;
		
		for (prefItem in prefSpecifierArray)
		{
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			
			if ([keyValueStr isEqualToString:@"emailKey"])
			{
				emailDefault = defaultValue;
			}
			else if ([keyValueStr isEqualToString:@"emailKey"])
			{
				passwordDefault = defaultValue;
			}
		}
        
		// since no default values have been set (i.e. no preferences file created), create it here		
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                     emailDefault, @"emailKey",
                                     passwordDefault, @"passwordKey",
                                     nil];
        
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	// we're ready to go, so lastly set the key preference values
	email = [[NSUserDefaults standardUserDefaults] stringForKey:@"emailKey"];
	password = [[NSUserDefaults standardUserDefaults] stringForKey:@"passwordKey"];
}

-(void)saveToPreferences:(NSString *)usr andPassword:(NSString *)pwd {
	
	// save user values to dictionary object
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setValue:usr forKey:@"emailKey"];
	[prefs setValue:pwd forKey:@"passwordKey"];
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"wowio.sqlite"];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"wowio" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	NSError *error;
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSString *)userProfilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	return [documentDirectory stringByAppendingString:userProfileFile];
}


#pragma mark -
#pragma mark Reachability Methods

-(BOOL)internetCheck {
	
	
	BOOL _isInternetConnectivity = YES;
	
	// check if there is internet connectivity
	[self performSelector:@selector(updateReachabilityStatus)];
	
	hostStatus = [hostReach currentReachabilityStatus];
	wifiStatus = [wifiReach currentReachabilityStatus];
	internetStatus = [internetReach currentReachabilityStatus];
	
	if (hostStatus == NotReachable && internetStatus == NotReachable && wifiStatus == NotReachable) {
		
		// alert the user that there is no internet connectivity
		NSString *errorString = @"There is Currently NO Internet Connectivity.\nYou will be unable to use the WOWIO bookstore effectively\nuntil connectivity has been restored.";
		[self alertWithMessage:errorString withTitle:@"ERROR"];
		
		_isInternetConnectivity = NO;
	}
	
	return _isInternetConnectivity;
}

- (void)updateReachabilityStatus
{
	hostStatus = [hostReach currentReachabilityStatus];
	wifiStatus = [wifiReach currentReachabilityStatus];
	internetStatus = [internetReach currentReachabilityStatus];
	
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
		
	}
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	if(curReach == hostReach)
		hostStatus = [curReach currentReachabilityStatus];
	else if (curReach == wifiReach)
		wifiStatus = [curReach currentReachabilityStatus];
	else if (curReach == internetReach)
		internetStatus = [curReach currentReachabilityStatus];
	
	[self updateReachabilityStatus];
}


#pragma mark -
#pragma mark Checking for Internet Connectivity

-(NSString *)wowioHome {
	return @"www.wowio.com";
}


#pragma mark -
#pragma mark Alert Message Method

- (void)alertWithMessage:(NSString *)msg withTitle:(NSString *)title 
{
	
	if ([title length] == 0)
		title = @"Error";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:msg
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark DB Methods

- (BOOL)bookInUserLibrary:(NSNumber*)bookid forOrderid:(NSString*)orderid {

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


- (NSMutableArray *)fetchBookDataFromDB:(NSString*)tableName 
					 withSortDescriptor:(NSString*)bookSortDescriptor {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];

	// set the sorting
	if (![bookSortDescriptor isEqualToString:@""]) {
		NSSortDescriptor *theDescriptor = [[NSSortDescriptor alloc] initWithKey:bookSortDescriptor ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:theDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		// clean up after yourself
		[theDescriptor release];
		[sortDescriptors release];
	}
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: NO category data was found in the db!\n");
	}

	// set the book ivar object
	return mutableFetchResults;
}

- (NSMutableArray *)fetchBookDataFromDB:(NSString*)tableName 
					 withSortDescriptor:(NSString*)bookSortDescriptor 
						  withPredicate:(NSString*)bookPredicate {
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:moc];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
		// set the filter predicate
	if (![bookPredicate isEqualToString:@""]) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@=1",bookPredicate];
		[fetchRequest setPredicate:predicate];
	}
	
		// set the sorting
	if (![bookSortDescriptor isEqualToString:@""]) {
		NSSortDescriptor *theDescriptor = [[NSSortDescriptor alloc] initWithKey:bookSortDescriptor ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:theDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		// clean up after yourself
		[theDescriptor release];
		[sortDescriptors release];
	}
	
	
	// execute the fetch
	NSError *error;
	NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		NSLog(@"Houston, we have a problem: NO category data was found in the db!\n");
	}
	
	// set the book ivar object
	return mutableFetchResults;
}


#pragma mark -
#pragma mark UITabBar Delegate Methods

/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
 */

/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
 */


#pragma mark -
#pragma mark Housekeeping Methods

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

