//
//  Library.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/30/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "LibraryDelegate.h"

@class ASINetworkQueue;

@interface Library :  NSManagedObject  
{
@private
	ASINetworkQueue *networkQueue;
	UIImage *bookCover;
	NSObject<LibraryDelegate> *delegate;
}

@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, retain) UIImage *bookCover;
@property (nonatomic, assign) NSObject<LibraryDelegate> *delegate;

@property (nonatomic, retain) NSNumber * adid;
@property (nonatomic, retain) NSNumber * thankyoucount;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imagepath;
@property (nonatomic, retain) NSNumber * orderbookid;
@property (nonatomic, retain) NSNumber * avgrating;
@property (nonatomic, retain) NSNumber * ratingcount;
@property (nonatomic, retain) NSNumber * userrating;
@property (nonatomic, retain) NSString * indexname;
@property (nonatomic, retain) NSString * publishername;
@property (nonatomic, retain) NSString * orderdate;
@property (nonatomic, retain) NSString * filepath;
@property (nonatomic, retain) NSNumber * logoserverid;
@property (nonatomic, retain) NSString * adname;
@property (nonatomic, retain) NSNumber * historycount;
@property (nonatomic, retain) NSNumber * downloadsuccess;
@property (nonatomic, retain) NSString * authorname;
@property (nonatomic, retain) NSNumber * recentlyviewed;
@property (nonatomic, retain) NSNumber * publisherid;
@property (nonatomic, retain) NSNumber * orderbookstatus;
@property (nonatomic, retain) NSNumber * previewpagecount;
@property (nonatomic, retain) NSNumber * readinglist;
@property (nonatomic, retain) NSString * downloaddate;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * mainbookcategoryid;
@property (nonatomic, retain) NSNumber * bookcategory;
@property (nonatomic, retain) NSNumber * bookcategoryid;
@property (nonatomic, retain) NSData * bookdata;
@property (nonatomic, retain) NSNumber * retailprice;
@property (nonatomic, retain) NSString * internalip;
@property (nonatomic, retain) NSNumber * purchased;
@property (nonatomic, retain) NSNumber * bookid;
@property (nonatomic, retain) NSNumber * contentratingid;
@property (nonatomic, retain) NSString * publisherurl;
@property (nonatomic, retain) NSString * externalip;
@property (nonatomic, retain) NSString * sorttitle;
@property (nonatomic, retain) NSNumber * booktypeid;
@property (nonatomic, retain) NSNumber * admodelid;

-(BOOL)hasLoadedThumbnail;

@end



