// 
//  Topbooks.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/23/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import "Topbooks.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@interface Topbooks (Private)
- (void)loadURL:(NSURL *)url;
@end

@implementation Topbooks 
@synthesize networkQueue, bookCover, delegate;

@dynamic listtype;
@dynamic reportdate;
@dynamic tdid;
@dynamic rank;
@dynamic details;
@dynamic publisherid;
@dynamic previewpagecount;
@dynamic publisherstatus;
@dynamic renderstatus;
@dynamic ballowalcohol;
@dynamic sortauthor;
@dynamic mainbookcategoryid;
@dynamic recstatus;
@dynamic authorname;
@dynamic retiredate;
@dynamic ballowgambling;
@dynamic title;
@dynamic endadminid;
@dynamic ballowsex;
@dynamic bookcategoryid;
@dynamic filesize;
@dynamic sorttitle;
@dynamic filepath;
@dynamic parentbookid;
@dynamic pagecount;
@dynamic bpdfcopypaste;
@dynamic bnodrm;
@dynamic previewstartdate;
@dynamic contentratingid;
@dynamic bbooksponsor;
@dynamic urlsuffix;
@dynamic booktypeid;
@dynamic ballowtobacco;
@dynamic bookadtypeid;
@dynamic indexname;
@dynamic availdate;
@dynamic bpdfprint;
@dynamic bavailable;
@dynamic bsponsorship;
@dynamic publishername;
@dynamic filepath1;
@dynamic bookmarkcount;
@dynamic accountid;
@dynamic bookid;
@dynamic coverimagepath_l;
@dynamic lastchangeadminid;
@dynamic begindate;
@dynamic bookfiletypeid;
@dynamic outputfilename;
@dynamic beginadminid;
@dynamic bpdfaccess;
@dynamic retailprice;
@dynamic realpubdate;
@dynamic enddate;
@dynamic lastchangedate;
@dynamic purchased;
@dynamic publicationdate;
@dynamic coverimagepath_s;
@dynamic ratingcount;
@dynamic revenue;
@dynamic becommerce;
@dynamic pricechangelockoutdate;
@dynamic isbn;
@dynamic savequality;
@dynamic avgrating;
@dynamic listtypeid;
@dynamic previewpagestring;
@dynamic initialreleasedate;
@dynamic bookstatus;



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
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wowio.com%@",self.coverimagepath_l]];
		//NSLog(@"\nBook: %@\nImage URL: %@\n\n",[self title],url);
        [self loadURL:url];
    }
    return bookCover;
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)request
{
	//NSLog(@"Got back a book image!");
	
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
	// show activity spinner
	if ([delegate respondsToSelector:@selector(startSpinner:)])
		[delegate performSelector:@selector(startSpinner:)];
	
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
