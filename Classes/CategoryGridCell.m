//
//  CategoryGridCell.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/29/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import "CategoryGridCell.h"
#import "GridColors.h"

@implementation CategoryGridCell
@synthesize item, gridColor;

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) aReuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: aReuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    _categoryImage = [[UIImageView alloc] initWithFrame: CGRectMake(5, 5, 75, 108)];

    _categoryName = [[UILabel alloc] initWithFrame: CGRectMake(40, 5, 300, 30)];
	_categoryName.backgroundColor = [UIColor clearColor];
    _categoryName.highlightedTextColor = [UIColor lightGrayColor];
	_categoryName.shadowColor = [UIColor blackColor];
	CGSize textOffset = CGSizeMake(1.0, 3.0);
	_categoryName.shadowOffset  = textOffset;
	_categoryName.textColor = [UIColor whiteColor];
    _categoryName.font = [UIFont boldSystemFontOfSize: 18.0];
    _categoryName.adjustsFontSizeToFitWidth = YES;
    _categoryName.minimumFontSize = 14.0;
	_categoryName.lineBreakMode = UILineBreakModeWordWrap;
	_categoryName.numberOfLines = 2;

    _bookCount = [[UILabel alloc] initWithFrame: CGRectMake(85, 30, 100, 20)];
	_bookCount.backgroundColor = [UIColor clearColor];
    _bookCount.highlightedTextColor = [UIColor whiteColor];
	_bookCount.textColor = [UIColor darkGrayColor];
    _bookCount.font = [UIFont boldSystemFontOfSize: 12.0];
    _bookCount.adjustsFontSizeToFitWidth = YES;
    _bookCount.minimumFontSize = 10.0;
    
    self.backgroundColor = [UIColor clearColor];
    //self.backgroundColor = [gridColor colorWithHexString:@"ecd2ad"];
    self.contentView.backgroundColor = self.backgroundColor;
    //_categoryImage.backgroundColor = self.backgroundColor;
    //_categoryName.backgroundColor = self.backgroundColor;
    //_bookCount.backgroundColor = self.backgroundColor;
    
    //[self.contentView addSubview: _categoryImage];
    [self.contentView addSubview: _categoryName];
    //[self.contentView addSubview: _bookCount];
    
    return ( self );
}

- (void) dealloc
{
    [_categoryImage release];
    [_categoryName release];
    [_bookCount release];
    [super dealloc];
}
/*
- (UIImage *) image
{
    return ( _categoryImage.image );
}

- (void) setImage: (UIImage *) anImage
{
    _categoryImage.image = anImage;
    [self setNeedsLayout];
}

- (NSString *) title
{
    return ( _categoryName.text );
}

- (NSString *) cnt
{
    return ( _bookCount.text );
}

- (void) setTitle: (NSString *) title
{
    _categoryName.text = title;
    [self setNeedsLayout];
}

- (void) setCnt: (NSString *) cnt
{
    _bookCount.text = cnt;
    [self setNeedsLayout];
}
*/



#pragma mark -
#pragma mark Public methods

- (void)setItem:(Categories *)newItem
{
    if (newItem != item)
    {
        [item release];
        item = nil;
        item = [newItem retain];
        
        if (item != nil)
        {
			_categoryName.lineBreakMode = UILineBreakModeWordWrap;
			_categoryName.numberOfLines = 2;
            _categoryName.text = [item bookcategory];
			NSString *totalText = [NSString stringWithFormat:@"%@ Books",[item bookcount]];
			_bookCount.text = totalText;
            _categoryImage.image = [UIImage imageNamed:@"defbook.png"];
			
			//NSLog(@"\nCategory: %@\nTotal: %@\n\n",[item bookcategory],[item bookcount]);
        }
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize imageSize = _categoryImage.image.size;
    CGRect bounds = CGRectInset(self.contentView.bounds, 10.0, 10.0);
    
	//[_categoryName sizeToFit];
	[_categoryName setLineBreakMode:UILineBreakModeWordWrap];
	[_categoryName setNumberOfLines:2];
    //CGRect frame = _categoryName.frame;
    //frame.size.width = MIN(frame.size.width, bounds.size.width);
    //frame.origin.y = CGRectGetMaxY(bounds) - frame.size.height;
    //frame.origin.x = floorf((bounds.size.width - frame.size.width) * 0.5);
    //_categoryName.frame = frame;
    
	/*
    [_bookCount sizeToFit];
    CGRect cntframe = _bookCount.frame;
    cntframe.size.width = MIN(frame.size.width, bounds.size.width);
    cntframe.origin.y = CGRectGetMaxY(bounds) - frame.size.height;
    cntframe.origin.x = floorf((bounds.size.width - frame.size.width) * 0.5);
    _bookCount.frame = cntframe;
    */
	
    // adjust the frame down for the image layout calculation
    //bounds.size.height = frame.origin.y - bounds.origin.y;
    
    if ( (imageSize.width <= bounds.size.width) &&
        (imageSize.height <= bounds.size.height) )
    {
        return;
    }
    
    // scale it down to fit
    CGFloat hRatio = bounds.size.width / imageSize.width;
    CGFloat vRatio = bounds.size.height / imageSize.height;
    CGFloat ratio = MIN(hRatio, vRatio);
    
    [_categoryImage sizeToFit];
    CGRect iframe = _categoryImage.frame;
    iframe.size.width = floorf(imageSize.width * ratio);
    iframe.size.height = floorf(imageSize.height * ratio);
    iframe.origin.x = floorf((bounds.size.width - iframe.size.width) * 0.5);
    iframe.origin.y = floorf((bounds.size.height - iframe.size.height) * 0.5);
    _categoryImage.frame = iframe;
	
}


@end
