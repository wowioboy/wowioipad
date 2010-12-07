//
//  NewReleasesGridCell.h
//  WOWIO
//
//  Created by Lawrence Leach on 10/11/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Newreleases.h"
#import "NewreleasesDelegate.h"
#import "NewReleasesGridCellDelegate.h"
#import "AQGridViewCell.h"
#import "GridColors.h"

@interface NewReleasesGridCell : AQGridViewCell <NewreleasesDelegate> {
	
	NSObject<NewReleasesGridCellDelegate> *delegate;
	UIImageView *_bookImage;
	UIImageView *_ratingImage;
	UILabel	*_bookTitle;
	UILabel *_bookAuthor;
	UILabel *_bookCategory;
	UILabel *_bookPrice;
	
	GridColors *gridColor;
	
	Newreleases *item;
	UIActivityIndicatorView *spinningWheel;
	NSNumberFormatter *numberFormatter;
}

@property (nonatomic, retain) Newreleases *item;
@property (nonatomic, assign) NSObject<NewReleasesGridCellDelegate> *delegate;

@property (nonatomic, retain) GridColors *gridColor;
@property (nonatomic, retain) NSNumberFormatter *numberFormatter;

-(void)loadImage;

@end
