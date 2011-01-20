//
//  Book.h
//  WOWIO
//
//  Created by Lawrence Leach on 12/6/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "BookDelegate.h"

@class ASINetworkQueue;

@interface Book :  NSManagedObject  
{
@private
	ASINetworkQueue *networkQueue;
	UIImage *bookCover;
	NSObject<BookDelegate> *delegate;
}

@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, retain) UIImage *bookCover;
@property (nonatomic, assign) NSObject<BookDelegate> *delegate;

@property (nonatomic, retain) NSString * groupname;
@property (nonatomic, retain) NSNumber * cpage;
@property (nonatomic, retain) NSNumber * bookgroupid;
@property (nonatomic, retain) NSNumber * tcdid;
@property (nonatomic, retain) NSNumber * downloadsum;
@property (nonatomic, retain) NSNumber * downloadcount;
@property (nonatomic, retain) NSString * coverimagepath_s;
@property (nonatomic, retain) NSNumber * ballowgambling;
@property (nonatomic, retain) NSNumber * savequality;
@property (nonatomic, retain) NSString * previewstartdate;
@property (nonatomic, retain) NSString * sortauthor;
@property (nonatomic, retain) NSNumber * ade_pdf_retailprice;
@property (nonatomic, retain) NSNumber * revenue;
@property (nonatomic, retain) NSString * ereader_filesize;
@property (nonatomic, retain) NSNumber * retailprice;
@property (nonatomic, retain) NSNumber * mainbookcategoryid;
@property (nonatomic, retain) NSString * epub_filesize;
@property (nonatomic, retain) NSString * filepath;
@property (nonatomic, retain) NSNumber * bformatwowio;
@property (nonatomic, retain) NSNumber * bformatade_pdf;
@property (nonatomic, retain) NSString * filesize;
@property (nonatomic, retain) NSNumber * booktypeid;
@property (nonatomic, retain) NSNumber * ereader_retailprice;
@property (nonatomic, retain) NSString * coverimagepath_l;
@property (nonatomic, retain) NSString * enddate;
@property (nonatomic, retain) NSString * previewpagestring;
@property (nonatomic, retain) NSNumber * is_featured;
@property (nonatomic, retain) NSNumber * bpdfcopypaste;
@property (nonatomic, retain) NSString * retiredate;
@property (nonatomic, retain) NSNumber * is_newrelease;
@property (nonatomic, retain) NSNumber * publisherstatus;
@property (nonatomic, retain) NSNumber * bpdfprint;
@property (nonatomic, retain) NSNumber * previewpagecount;
@property (nonatomic, retain) NSNumber * bnodrm;
@property (nonatomic, retain) NSNumber * bnoimage;
@property (nonatomic, retain) NSNumber * bookfiletypeid;
@property (nonatomic, retain) NSString * sorttitle;
@property (nonatomic, retain) NSNumber * antialiasoption;
@property (nonatomic, retain) NSString * authorname;
@property (nonatomic, retain) NSNumber * pagecount;
@property (nonatomic, retain) NSString * urlsuffix;
@property (nonatomic, retain) NSNumber * is_topseller;
@property (nonatomic, retain) NSNumber * ade_epub_retailprice;
@property (nonatomic, retain) NSNumber * contentratingid;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString * imagesubpath;
@property (nonatomic, retain) NSString * endadminid;
@property (nonatomic, retain) NSString * begindate;
@property (nonatomic, retain) NSNumber * is_staffpick;
@property (nonatomic, retain) NSString * initialreleasedate;
@property (nonatomic, retain) NSNumber * is_sponsored;
@property (nonatomic, retain) NSString * ade_pdf_sku13;
@property (nonatomic, retain) NSString * epub_sku13;
@property (nonatomic, retain) NSNumber * recstatus;
@property (nonatomic, retain) NSNumber * bookstatus;
@property (nonatomic, retain) NSNumber * is_brainbyte;
@property (nonatomic, retain) NSNumber * bformatepub;
@property (nonatomic, retain) NSNumber * ballowtobacco;
@property (nonatomic, retain) NSString * bookcategoryid;
@property (nonatomic, retain) NSString * ratingcount;
@property (nonatomic, retain) NSNumber * bookadtypeid;
@property (nonatomic, retain) NSNumber * is_agile;
@property (nonatomic, retain) NSNumber * accountid;
@property (nonatomic, retain) NSString * ade_epub_filesize;
@property (nonatomic, retain) NSString * indexname;
@property (nonatomic, retain) NSNumber * bformatade_epub;
@property (nonatomic, retain) NSString * ade_epub_sku13;
@property (nonatomic, retain) NSNumber * lastchangeadminid;
@property (nonatomic, retain) NSNumber * beginadminid;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSString * renderstatus;
@property (nonatomic, retain) NSString * ereader_sku13;
@property (nonatomic, retain) NSString * realpubdate;
@property (nonatomic, retain) NSNumber * epub_retailprice;
@property (nonatomic, retain) NSString * filepath1;
@property (nonatomic, retain) NSNumber * bpdfaccess;
@property (nonatomic, retain) NSString * reportdate;
@property (nonatomic, retain) NSString * outputfilename;
@property (nonatomic, retain) NSNumber * bookid;
@property (nonatomic, retain) NSNumber * tdid;
@property (nonatomic, retain) NSNumber * parentbookid;
@property (nonatomic, retain) NSNumber * bookmarkcount;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * listtypeid;
@property (nonatomic, retain) NSString * publishername;
@property (nonatomic, retain) NSString * ade_pdf_filesize;
@property (nonatomic, retain) NSNumber * is_topcomic;
@property (nonatomic, retain) NSNumber * ballowsex;
@property (nonatomic, retain) NSNumber * purchased;
@property (nonatomic, retain) NSString * availdate;
@property (nonatomic, retain) NSNumber * bsponsorship;
@property (nonatomic, retain) NSString * publicationdate;
@property (nonatomic, retain) NSNumber * publisherid;
@property (nonatomic, retain) NSString * avgrating;
@property (nonatomic, retain) NSNumber * bbooksponsor;
@property (nonatomic, retain) NSNumber * becommerce;
@property (nonatomic, retain) NSNumber * bformatereader;
@property (nonatomic, retain) NSNumber * userrating;
@property (nonatomic, retain) NSNumber * ballowalcohol;
@property (nonatomic, retain) NSNumber * listtype;
@property (nonatomic, retain) NSNumber * bavailable;
@property (nonatomic, retain) NSString * lastchangedate;
@property (nonatomic, retain) NSString * pricechangelockoutdate;
@property (nonatomic, retain) NSString * isbn;

-(BOOL)hasLoadedThumbnail;

@end



