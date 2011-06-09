//
//  LoginViewModalController.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/11/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOWIOAppDelegate.h"
#import "FormCell.h"

@class ASINetworkQueue;

@protocol LoginViewModalDelegate <NSObject>

@required
-(void)didDismissModalView;

@optional
-(void)nextSteps;


@end

@interface LoginViewModalController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	id<LoginViewModalDelegate> delegate;
	
	ASINetworkQueue *networkQueue;
	WOWIOAppDelegate *appDelegate;
	NSManagedObjectContext *managedObjectContext;
	
	IBOutlet UIButton *joinButton;
	IBOutlet UIButton *loginButton;
	IBOutlet UIButton *backgroundButton;
	IBOutlet UIButton *loginBackgroundButton;
	IBOutlet UIProgressView *progressIndicator;
	IBOutlet UITextField *userNameField;
	IBOutlet UITextField *passWordField;
	IBOutlet UIImageView *backgroundImage;
	IBOutlet UIView *loginView;
	IBOutlet UILabel *infoField;
	
	int fetchCount;
	NSArray *urlArray;
	BOOL featuresFetched;
	NSString *emailDefault;
	NSString *passwordDefault;

	UITableView *theTableView;
	id<UITableViewDataSource> dataSource;
	
	NetworkStatus hostStatus;
	NetworkStatus internetStatus;
	NetworkStatus wifiStatus;
}

@property(nonatomic, assign)id<LoginViewModalDelegate> delegate;

@property(nonatomic, retain)ASINetworkQueue *networkQueue;
@property(nonatomic, retain)WOWIOAppDelegate *appDelegate;

@property(nonatomic, retain)NSManagedObjectContext *managedObjectContext;

@property(nonatomic, assign)int fetchCount;
@property(nonatomic, retain)NSArray *urlArray;

@property(nonatomic, retain)NSString *emailDefault;
@property(nonatomic, retain)NSString *passwordDefault;

@property(nonatomic, retain)UIButton *joinButton;
@property(nonatomic, retain)UIButton *loginButton;
@property(nonatomic, retain)UIButton *backgroundButton;
@property(nonatomic, retain)UIButton *loginBackgroundButton;
@property(nonatomic, retain)UIProgressView *progressIndicator;
@property(nonatomic, retain)UITextField *userNameField;
@property(nonatomic, retain)UITextField *passWordField;
@property(nonatomic, retain)UIImageView *backgroundImage;
@property(nonatomic, retain)UIView *loginView;
@property(nonatomic, retain)UILabel *infoField;

@property(nonatomic, retain)UITableView *theTableView;
@property(nonatomic, retain)id<UITableViewDataSource> dataSource;

@property NetworkStatus hostStatus;
@property NetworkStatus internetStatus;
@property NetworkStatus wifiStatus;

-(void)fetchWowioData;
-(void)fetchFeatures;
-(BOOL)internetCheck;

-(BOOL)bookInUserLibrary:(NSNumber*)bookid forOrderid:(NSNumber*)orderid;
-(void)removeData:(NSString*)theEntity;
-(void)removeBookData:(NSString*)theEntity forFilter:(NSString*)theFilter;
-(void)writeUserDetailsToPlist:(NSDictionary *)ud;
-(void)writeCategoryDataToDB:(NSMutableArray *)data;
-(void)writeUserDataToDB:(NSMutableArray *)data;
-(void)writeBookDataToDB:(NSString*)table withData:(NSMutableArray *)data;
-(void)saveAction;

-(void)getUserDefaults;
-(void)loginAction:(id)sender;
-(IBAction)dismissView:(id)sender;
-(IBAction)joinAction:(id)sender;
-(IBAction)moveToPasswordField:(id)sender;
-(IBAction)textFieldDoneEditing:(id)sender;
-(IBAction)backgroundClickAction:(id)sender;
-(void)configureCell:(FormCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
