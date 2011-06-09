//
//  CategoryBookGridCell.h
//  WOWIO
//
//  Created by Lawrence Leach on 7/11/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "BookDelegate.h"
#import "AQGridViewCell.h"
#import "GridColors.h"

@interface CategoryBookGridCell : AQGridViewCell <BookDelegate> {
	
	UIImageView *_bookImage;
	UIImageView *_ratingImage;
	UILabel	*_bookTitle;
	UILabel *_bookAuthor;
	UILabel *_bookCategory;
	UILabel *_bookPrice;
	
	GridColors *gridColor;
	
	Book *item;
	UIActivityIndicatorView *spinningWheel;
	
	NSNumberFormatter *numberFormatter;
}

@property(nonatomic, retain)Book *item;
@property(nonatomic, retain)GridColors *gridColor;

@property(nonatomic, retain) NSNumberFormatter *numberFormatter;

-(void)loadImage;

@end
