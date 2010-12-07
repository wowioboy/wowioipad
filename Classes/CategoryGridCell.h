//
//  CategoryGridCell.h
//  WOWIO
//
//  Created by Lawrence Leach on 6/29/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categories.h"
#import "AQGridViewCell.h"
#import "GridColors.h"

@interface CategoryGridCell : AQGridViewCell {
	UIImageView *_categoryImage;
	UILabel	*_categoryName;
	UILabel *_bookCount;
	
	Categories *item;
	GridColors *gridColor;
}

//@property (nonatomic, retain) UIImage * image;
//@property (nonatomic, copy) NSString * category;
//@property (nonatomic, copy) NSString * cnt;

@property (nonatomic, retain) Categories *item;
@property (nonatomic, retain) GridColors *gridColor;

@end
