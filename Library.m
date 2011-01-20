// 
//  Library.m
//  WOWIO
//
//  Created by Lawrence Leach on 12/8/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "Library.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@interface Library (Private)
- (void)loadURL:(NSURL *)url withFormat:(NSString*)imgFormat;
@end

@implementation Library 
@synthesize networkQueue, bookCover, progressBar, delegate, appDelegate, managedObjectContext;

@dynamic recentlyviewed;
@dynamic admodelid;
@dynamic ratingcount;
@dynamic retailprice;
@dynamic bnoimage;
@dynamic filepath;
@dynamic bookformat;
@dynamic imagesubpath;
@dynamic historycount;
@dynamic authorname;
@dynamic orderbookstatus;
@dynamic mainbookcategoryid;
@dynamic largeimagepath;
@dynamic bookdata;
@dynamic publishername;
@dynamic orderdate;
@dynamic imagepath;
@dynamic adname;
@dynamic publisherid;
@dynamic details;
@dynamic booktypeid;
@dynamic externalip;
@dynamic userrating;
@dynamic bookcategory;
@dynamic purchased;
@dynamic readinglist;
@dynamic thankyoucount;
@dynamic adid;
@dynamic sorttitle;
@dynamic internalip;
@dynamic bookid;
@dynamic avgrating;
@dynamic bookcategoryid;
@dynamic contentratingid;
@dynamic loboserverid;
@dynamic orderbookid;
@dynamic publisherurl;
@dynamic downloadsuccess;
@dynamic previewpagecount;
@dynamic indexname;
@dynamic title;
@dynamic downloaddate;

-(void)dealloc {
	delegate = nil;
		//[bookCover release];
	[networkQueue release];
	[appDelegate release];
	[managedObjectContext release];
	[super dealloc];
}


#pragma mark -
#pragma mark Public methods

- (BOOL)hasLoadedThumbnail
{
    return (self.bookCover != nil);
}

-(UIProgressView *)progressBar {
	return progressBar;
}

#pragma mark -
#pragma mark Overridden setters

- (UIImage *)bookCover
{
	
	NSData *imgData = [self bookdata];
	if ([imgData length] > 0)
		bookCover = [[UIImage alloc] initWithData:imgData];
	
    if (bookCover == nil)
    {
		NSString *imgFormat = @"image/jpeg";
		NSNumber *bid = [self bookid];
		NSNumber *pid = [self publisherid];
		NSString *imgsubpath = [self imagesubpath];
		NSString *lrgimgpath = [self largeimagepath];
		NSNumber *bNoImage = (NSNumber*)[self bnoimage];
		BOOL noImg = [bNoImage boolValue];
		NSURL *imgURL;
		
		if (![imgsubpath isKindOfClass:[NSNull class]] && ![imgsubpath isEqualToString:@""])
			imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wowio.com/images/books/%@/%@/%@_3.jpg",pid,imgsubpath,bid]];
		else {
			
			if (noImg) {
				imgFormat = @"image/png";
				imgURL = [NSURL URLWithString:@"http://www.wowio.com/images/newimages/no-cover-260.png"];
			} else 
				imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wowio.com%@",lrgimgpath]];
		}
		
			//NSLog(@"\n%@",imgURL);
        [self loadURL:imgURL withFormat:imgFormat];
    }
    return bookCover;
}


#pragma mark -
#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)request
{
		// SET THE DB CONTEXT
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];	
	self.managedObjectContext = [appDelegate managedObjectContext];
	
	
		// INSERT THE BOOK IMAGE THAT IS RETURNED
    NSData *data = [request responseData];
    UIImage *remoteImage = [[UIImage alloc] initWithData:data];
    self.bookCover = remoteImage;
    if ([delegate respondsToSelector:@selector(bookItem:didLoadCover:)])
    {
        [delegate bookItem:self didLoadCover:remoteImage];
    }
    [remoteImage release];
	
	
		// SAVE THE BOOK IMAGE TO THE DB
	NSError *saveError;
	self.bookdata = data;
	if (![managedObjectContext save:&saveError])
		NSLog(@"Saving changes to book failed: %@", saveError);
	
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if ([delegate respondsToSelector:@selector(bookItem:couldNotLoadImageError:)])
    {
        [delegate bookItem:self couldNotLoadImageError:error];
    }
}


#pragma mark -
#pragma mark Private methods

-(void)loadURL:(NSURL *)url withFormat:(NSString*)imgFormat
{
	[self setNetworkQueue:[ASINetworkQueue queue]];
		//[self.networkQueue cancelAllOperations];
	[self.networkQueue setDelegate:self];		
	[self.networkQueue setRequestDidFinishSelector:@selector(requestDone:)];
	[self.networkQueue setRequestDidFailSelector:@selector(requestWentWrong:)];
	
		// submit the request
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"Content-Type" value:imgFormat];
	[request addRequestHeader:@"Accept" value:imgFormat];
	
		// add the request to the queue and set it off
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
}

-(void)saveAction {
	
	self.appDelegate = (WOWIOAppDelegate *)[[UIApplication sharedApplication] delegate];	
	self.managedObjectContext = [appDelegate managedObjectContext];
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
		exit(-1);
	}
}


@end
