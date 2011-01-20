//
//  LibraryGridCell.h
//  WOWIO
//
//  Created by Lawrence Leach on 9/10/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Library.h"
#import "LibraryDelegate.h"
#import "LibraryGridCellDelegate.h"
#import "AQGridViewCell.h"
//#import "GridColors.h"


@interface LibraryGridCell : AQGridViewCell <LibraryDelegate> {
	
	NSObject<LibraryGridCellDelegate> *delegate;
	UIImageView *_bookImage;
	UIImageView *_ratingImage;
	UILabel	*_bookTitle;
	UILabel *_bookAuthor;
	UILabel *_bookCategory;
	UILabel *_bookDwldDate;
	UILabel *_bookFormat;
	UILabel *_bookFileSize;
	
	//GridColors *gridColor;
	
	Library *item;
	UIActivityIndicatorView *spinningWheel;
	UIProgressView *progressBar;
	
	NSNumberFormatter *numberFormatter;
	NSDateFormatter *dateFormatter;
	NSDateFormatter *dateDisplayFormatter;
}

@property (nonatomic, retain) Library *item;
@property (nonatomic, assign) NSObject<LibraryGridCellDelegate> *delegate;

@property (nonatomic, retain) NSNumberFormatter *numberFormatter;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSDateFormatter *dateDisplayFormatter;

//@property (nonatomic, retain) GridColors *gridColor;

-(void)loadImage;

@end
