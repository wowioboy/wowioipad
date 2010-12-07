//
//  BookCell.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/10/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookCell : UITableViewCell {

	UIImageView *bookJacket;
	UIImageView *bookRating;
	UILabel	*bookTitle;
	UILabel	*bookAuthor;
	UILabel	*bookCategory;
	
	Book *item;
}

@property(nonatomic, retain) UIImageView *bookJacket;
@property(nonatomic, retain) UIImageView *bookRating;
@property(nonatomic, retain) UILabel *bookTitle;
@property(nonatomic, retain) UILabel *bookAuthor;
@property(nonatomic, retain) UILabel *bookCategory;

@property(nonatomic, retain) Book *item;

-(void)setItem:(Book *)newItem;

@end
