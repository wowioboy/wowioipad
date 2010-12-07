//
//  WOWIOAppDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/8/10.
//  Copyright Pure Engineering 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Reachability.h"

@interface WOWIOAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	
	Reachability *hostReach;
    Reachability *internetReach;
    Reachability *wifiReach;
	
	NetworkStatus hostStatus;
	NetworkStatus internetStatus;
	NetworkStatus wifiStatus;
	
	BOOL _isLoggedIn;
	NSString *userId;
	NSString *sessionId;
	NSString *email;
	NSString *password;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;

@property NetworkStatus hostStatus;
@property NetworkStatus internetStatus;
@property NetworkStatus wifiStatus;

@property (nonatomic, assign) BOOL _isLoggedIn;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *sessionId;

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *password;

// creating a shared delegate
+ (WOWIOAppDelegate *)sharedAppDelegate;

- (NSString *)applicationDocumentsDirectory;
- (NSString *)userProfilePath;

- (void)setupByPreferences;
- (void)saveToPreferences:(NSString *)usr andPassword:(NSString *)pwd;
- (BOOL)internetCheck;
- (void)updateReachabilityStatus;
- (void)alertWithMessage:(NSString *)msg withTitle:(NSString *)title;
- (NSMutableArray *)fetchBookDataFromDB:(NSString*)tableName 
					 withSortDescriptor:(NSString*)bookSortDescriptor;
- (NSMutableArray *)fetchBookDataFromDB:(NSString*)tableName 
					 withSortDescriptor:(NSString*)bookSortDescriptor 
						  withPredicate:(NSString*)bookPredicate;


@end
