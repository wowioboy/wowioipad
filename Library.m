// 
//  Library.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/30/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "Library.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@interface Library (Private)
- (void)loadURL:(NSURL *)url;
@end

@implementation Library 
@synthesize networkQueue, bookCover, delegate;

@dynamic adid;
@dynamic thankyoucount;
@dynamic title;
@dynamic imagepath;
@dynamic orderbookid;
@dynamic publishername;
@dynamic orderdate;
@dynamic filepath;
@dynamic avgrating;
@dynamic ratingcount;
@dynamic userrating;
@dynamic indexname;
@dynamic logoserverid;
@dynamic adname;
@dynamic historycount;
@dynamic downloadsuccess;
@dynamic authorname;
@dynamic recentlyviewed;
@dynamic publisherid;
@dynamic orderbookstatus;
@dynamic previewpagecount;
@dynamic readinglist;
@dynamic downloaddate;
@dynamic details;
@dynamic mainbookcategoryid;
@dynamic bookcategory;
@dynamic bookcategoryid;
@dynamic bookdata;
@dynamic retailprice;
@dynamic internalip;
@dynamic purchased;
@dynamic bookid;
@dynamic contentratingid;
@dynamic publisherurl;
@dynamic externalip;
@dynamic sorttitle;
@dynamic booktypeid;
@dynamic admodelid;

-(void)dealloc {
	delegate = nil;
	//[bookCover release];
	[networkQueue release];
	[super dealloc];
}


#pragma mark -
#pragma mark Public methods

- (BOOL)hasLoadedThumbnail
{
    return (self.bookCover != nil);
}


#pragma mark -
#pragma mark Overridden setters

- (UIImage *)bookCover
{
    if (bookCover == nil)
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wowio.com%@",self.imagepath]];
		//NSLog(@"\nBook: %@\nImage URL: %@\n\n",[self title],url);
        [self loadURL:url];
    }
    return bookCover;
}


#pragma mark -
#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)request
{
	//NSLog(@"Got back a book image");
    NSData *data = [request responseData];
    UIImage *remoteImage = [[UIImage alloc] initWithData:data];
    self.bookCover = remoteImage;
	
    if ([delegate respondsToSelector:@selector(bookItem:didLoadCover:)])
    {
        [delegate bookItem:self didLoadCover:remoteImage];
    }
    [remoteImage release];
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

- (void)loadURL:(NSURL *)url
{
	[self setNetworkQueue:[ASINetworkQueue queue]];
	//[self.networkQueue cancelAllOperations];
	[self.networkQueue setDelegate:self];		
	[self.networkQueue setRequestDidFinishSelector:@selector(requestDone:)];
	[self.networkQueue setRequestDidFailSelector:@selector(requestWentWrong:)];
	
	// submit the request
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"Content-Type" value:@"image/jpeg"];
	[request addRequestHeader:@"Accept" value:@"image/jpeg"];
	
	// add the request to the queue and set it off
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
}


@end
