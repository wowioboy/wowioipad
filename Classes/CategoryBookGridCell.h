//
//  CategoryBookGridCell.h
//  WOWIO
//
//  Created by Lawrence Leach on 7/11/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categorybooks.h"
#import "CategorybooksDelegate.h"
#import "AQGridViewCell.h"
#import "GridColors.h"

@interface CategoryBookGridCell : AQGridViewCell <CategorybooksDelegate> {
	
	UIImageView *_bookImage;
	UIImageView *_ratingImage;
	UILabel	*_bookTitle;
	UILabel *_bookAuthor;
	UILabel *_bookCategory;
	UILabel *_bookPrice;
	
	GridColors *gridColor;
	
	Categorybooks *item;
	UIActivityIndicatorView *spinningWheel;
	
	NSNumberFormatter *numberFormatter;
}

@property(nonatomic, retain)Categorybooks *item;
@property(nonatomic, retain)GridColors *gridColor;

@property(nonatomic, retain) NSNumberFormatter *numberFormatter;

-(void)loadImage;

@end
