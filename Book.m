// 
//  Book.m
//  WOWIO
//
//  Created by Lawrence Leach on 12/6/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "Book.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@interface Book (Private)
-(void)loadURL:(NSURL *)url withFormat:(NSString*)imgFormat;
@end


@implementation Book 
@synthesize networkQueue, bookCover, delegate;

@dynamic groupname;
@dynamic cpage;
@dynamic bookgroupid;
@dynamic tcdid;
@dynamic downloadsum;
@dynamic downloadcount;
@dynamic coverimagepath_s;
@dynamic ballowgambling;
@dynamic savequality;
@dynamic previewstartdate;
@dynamic sortauthor;
@dynamic ade_pdf_retailprice;
@dynamic revenue;
@dynamic ereader_filesize;
@dynamic retailprice;
@dynamic mainbookcategoryid;
@dynamic epub_filesize;
@dynamic filepath;
@dynamic bformatwowio;
@dynamic bformatade_pdf;
@dynamic filesize;
@dynamic booktypeid;
@dynamic ereader_retailprice;
@dynamic coverimagepath_l;
@dynamic enddate;
@dynamic previewpagestring;
@dynamic is_featured;
@dynamic bpdfcopypaste;
@dynamic retiredate;
@dynamic is_newrelease;
@dynamic publisherstatus;
@dynamic bpdfprint;
@dynamic previewpagecount;
@dynamic bnodrm;
@dynamic bookfiletypeid;
@dynamic sorttitle;
@dynamic antialiasoption;
@dynamic authorname;
@dynamic pagecount;
@dynamic urlsuffix;
@dynamic is_topseller;
@dynamic ade_epub_retailprice;
@dynamic contentratingid;
@dynamic rank;
@dynamic imagesubpath;
@dynamic endadminid;
@dynamic begindate;
@dynamic is_staffpick;
@dynamic initialreleasedate;
@dynamic is_sponsored;
@dynamic ade_pdf_sku13;
@dynamic epub_sku13;
@dynamic recstatus;
@dynamic bookstatus;
@dynamic is_brainbyte;
@dynamic bformatepub;
@dynamic ballowtobacco;
@dynamic bookcategoryid;
@dynamic ratingcount;
@dynamic bookadtypeid;
@dynamic is_agile;
@dynamic accountid;
@dynamic ade_epub_filesize;
@dynamic indexname;
@dynamic bformatade_epub;
@dynamic ade_epub_sku13;
@dynamic lastchangeadminid;
@dynamic beginadminid;
@dynamic details;
@dynamic renderstatus;
@dynamic ereader_sku13;
@dynamic realpubdate;
@dynamic epub_retailprice;
@dynamic filepath1;
@dynamic bpdfaccess;
@dynamic reportdate;
@dynamic outputfilename;
@dynamic bookid;
@dynamic tdid;
@dynamic parentbookid;
@dynamic bookmarkcount;
@dynamic title;
@dynamic bnoimage;
@dynamic listtypeid;
@dynamic publishername;
@dynamic ade_pdf_filesize;
@dynamic is_topcomic;
@dynamic ballowsex;
@dynamic purchased;
@dynamic availdate;
@dynamic bsponsorship;
@dynamic publicationdate;
@dynamic publisherid;
@dynamic avgrating;
@dynamic bbooksponsor;
@dynamic becommerce;
@dynamic bformatereader;
@dynamic userrating;
@dynamic ballowalcohol;
@dynamic listtype;
@dynamic bavailable;
@dynamic lastchangedate;
@dynamic pricechangelockoutdate;
@dynamic isbn;

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
		NSString *imgFormat = @"image/jpeg";
		NSNumber *bid = [self bookid];
		NSNumber *pid = [self publisherid];
		NSString *imgsubpath = [self imagesubpath];
		NSNumber *bNoImage = (NSNumber*)[self bnoimage];
		BOOL haveImg = [bNoImage boolValue];
		NSURL *imgURL;
		
		if (![imgsubpath isKindOfClass:[NSNull class]] && ![imgsubpath isEqualToString:@""])
			imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wowio.com/images/books/%@/%@/%@_3.jpg",pid,imgsubpath,bid]];
		else {
			
			if (haveImg){
				imgFormat = @"image/png";
				imgURL = [NSURL URLWithString:@"http://www.wowio.com/images/newimages/no-cover-260.png"];
			} else
				imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wowio.com/images/books/%@/%@_3.jpg",pid,bid]];
			
		}
		
			// NSLog(@"\n%@",imgURL);
        [self loadURL:imgURL withFormat:imgFormat];
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

@end
