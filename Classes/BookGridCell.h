//
//  BookGridCell.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/29/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "BookDelegate.h"
#import "BookGridCellDelegate.h"
#import "AQGridViewCell.h"
#import "GridColors.h"


@interface BookGridCell : AQGridViewCell <BookDelegate> {
	
	NSObject<BookGridCellDelegate> *delegate;
	UIImageView *_bookImage;
	UIImageView *_ratingImage;
	UILabel	*_bookTitle;
	UILabel	*_bookPrice;
	UILabel *_bookAuthor;
	UILabel *_bookCategory;
	
	GridColors *gridColor;
	
	Book *item;
	UIActivityIndicatorView *spinningWheel;
	
	NSNumberFormatter *numberFormatter;
}

@property (nonatomic, retain) Book *item;
@property (nonatomic, assign) NSObject<BookGridCellDelegate> *delegate;

@property (nonatomic, retain) GridColors *gridColor;
@property(nonatomic, retain) NSNumberFormatter *numberFormatter;

-(void)loadImage;

@end
