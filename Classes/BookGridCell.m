//
//  BookGridCell.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/29/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import "BookGridCell.h"
#import "Book.h"
#import "GridColors.h"

@implementation BookGridCell
@synthesize item, delegate, gridColor, numberFormatter;

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) aReuseIdentifier
{
	numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setUsesGroupingSeparator:YES];
	[numberFormatter setAllowsFloats:YES];
	[numberFormatter setCurrencyCode:@"USD"];
	[numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setCurrencyDecimalSeparator:@"."];
	[numberFormatter setCurrencyGroupingSeparator:@","];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
    self = [super initWithFrame: frame reuseIdentifier: aReuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    _bookImage = [[UIImageView alloc] initWithFrame: CGRectMake(5, 5, 75, 108)];
	
    _bookTitle = [[UILabel alloc] initWithFrame: CGRectMake(85, 5, 100, 30)];
	_bookTitle.backgroundColor = [UIColor clearColor];
    _bookTitle.highlightedTextColor = [UIColor whiteColor];
	_bookTitle.textColor = [UIColor whiteColor];
    _bookTitle.font = [UIFont boldSystemFontOfSize: 12.0];
    _bookTitle.adjustsFontSizeToFitWidth = YES;
    _bookTitle.minimumFontSize = 10.0;
	_bookTitle.lineBreakMode = UILineBreakModeWordWrap;
	_bookTitle.numberOfLines = 2;
	
    _bookAuthor = [[UILabel alloc] initWithFrame: CGRectMake(85, 30, 100, 20)];
	_bookAuthor.backgroundColor = [UIColor clearColor];
    _bookAuthor.highlightedTextColor = [UIColor whiteColor];
	_bookAuthor.textColor = [UIColor lightGrayColor];
    _bookAuthor.font = [UIFont systemFontOfSize:12.0];
    _bookAuthor.adjustsFontSizeToFitWidth = YES;
    _bookAuthor.minimumFontSize = 10.0;
	
    _bookCategory = [[UILabel alloc] initWithFrame: CGRectMake(85, 50, 100, 20)];
	_bookCategory.backgroundColor = [UIColor clearColor];
    _bookCategory.highlightedTextColor = [UIColor whiteColor];
	_bookCategory.textColor = [UIColor darkGrayColor];
    _bookCategory.font = [UIFont boldSystemFontOfSize: 12.0];
    _bookCategory.adjustsFontSizeToFitWidth = YES;
    _bookCategory.minimumFontSize = 10.0;
    
    _bookPrice = [[UILabel alloc] initWithFrame: CGRectMake(85, 56, 100, 40)];
	_bookPrice.backgroundColor = [UIColor clearColor];
    _bookPrice.highlightedTextColor = [UIColor whiteColor];
	_bookPrice.textColor = [UIColor whiteColor];
    _bookPrice.font = [UIFont boldSystemFontOfSize: 12.0];
    _bookPrice.adjustsFontSizeToFitWidth = YES;
    _bookPrice.minimumFontSize = 10.0;
	
    _ratingImage = [[UIImageView alloc] initWithFrame: CGRectMake(85, 95, 79, 19)];
	
	spinningWheel = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(27.0, 27.0, 20.0, 20.0)];
	spinningWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	spinningWheel.hidesWhenStopped = YES;
	[spinningWheel stopAnimating];

    self.backgroundColor = [gridColor colorWithHexString:@"ecd2ad"];
    //self.backgroundColor = [UIColor colorWithWhite: 0.95 alpha: 1.0];
    self.contentView.backgroundColor = self.backgroundColor;
    //_categoryImage.backgroundColor = self.backgroundColor;
    //_categoryName.backgroundColor = self.backgroundColor;
    //_bookCount.backgroundColor = self.backgroundColor;
    
    [self.contentView addSubview: _bookImage];
    [self.contentView addSubview: _bookTitle];
    [self.contentView addSubview: _bookAuthor];
    //[self.contentView addSubview: _bookCategory];
    [self.contentView addSubview: _bookPrice];
    [self.contentView addSubview: _ratingImage];
    [self.contentView addSubview:spinningWheel];
	
    return ( self );
}

- (void) dealloc
{
    [_bookImage release];
    [_ratingImage release];
    [_bookTitle release];
    [_bookAuthor release];
    //[_bookCategory release];
	[_bookPrice release];
	[gridColor release];
    [super dealloc];
}


#pragma mark -
#pragma mark Public methods

- (void)setItem:(Book *)newItem
{
    if (newItem != item)
    {
		item.delegate = nil;
        [item release];
        item = nil;
		
        item = [newItem retain];
        [item setDelegate:self];
		
        if (item != nil)
        {
			NSString *newTitle = [item title];
			newTitle = [newTitle stringByReplacingOccurrencesOfString:@"\"" withString:@""];
			_bookTitle.lineBreakMode = UILineBreakModeWordWrap;
			_bookTitle.numberOfLines = 2;
            _bookTitle.text = newTitle;
			
			_bookAuthor.lineBreakMode = UILineBreakModeWordWrap;
			_bookAuthor.numberOfLines = 2;
            _bookAuthor.text = [item authorname];
			
			// format the display of the retail price
			NSString *priceamt;
			NSNumber *bavailable = [item bavailable];
			NSNumber *becommerce = [item becommerce];
			NSNumber *bnodrm = [item bnodrm];
			NSNumber *bbooksponsor = [item bbooksponsor];
			NSString *indexname = [item indexname];
			NSNumber *retailprice = [item retailprice];
			
			if (![bavailable isEqualToNumber:[NSNumber numberWithInt:0]] && ![becommerce isEqualToNumber:[NSNumber numberWithInt:0]] || ![bnodrm isEqualToNumber:[NSNumber numberWithInt:0]]) {
				
				if ([retailprice intValue] > 0) {
					
					if ([bbooksponsor isEqualToNumber:[NSNumber numberWithInt:0]]) {
						
						NSString *thePrice = [retailprice stringValue];
						NSNumber *fprice = [NSNumber numberWithFloat:[thePrice floatValue]];
						NSString *formattedPrice = [numberFormatter stringFromNumber:fprice];
						priceamt = [NSString stringWithFormat:@"Buy for %@",formattedPrice];
						
					} else {
						priceamt = [NSString stringWithFormat:@"Free from %@",[indexname capitalizedString]];
					}
					
				} else {
					priceamt = @"FREE";
				}
				
			} else {
				
				priceamt = @"";
			}
			
			_bookPrice.numberOfLines = 2;
			_bookPrice.text = [NSString stringWithFormat:@"%@",priceamt];
			
			
			//NSLog(@"\nTitle: %@\nAvg Rating: %@\n",[item title],[item avgrating]);
			NSString *rateStr = [NSString stringWithFormat:@"%@.png",[item avgrating]];
            _ratingImage.image = [UIImage imageNamed:rateStr];
			
			// if a book image download is deferred or in progress, return a placeholder image
			if ([item hasLoadedThumbnail])
			{
				_bookImage.image = [item bookCover];                
				
			} else {
				_bookImage.image = [UIImage imageNamed:@"defbook.png"];
			}
        }
    }
}

- (void)loadImage
{
    UIImage *image = item.bookCover;
    if (image == nil)
    {
        _bookImage.image = [UIImage imageNamed:@"defbook.png"];
		[spinningWheel startAnimating];
    }
    _bookImage.image = image;
}


#pragma mark -
#pragma mark BookGridCellDelegate methods

- (void)bookItem:(Book *)item didLoadCover:(UIImage *)BookImage
{
    _bookImage.image = BookImage;
    [spinningWheel stopAnimating];
}

- (void)bookItem:(Book *)item couldNotLoadImageError:(NSError *)error
{
    // there was an error. so show the "default" book image...
	NSLog(@"Error occured trying to load a book image.");
	_bookImage.image = [UIImage imageNamed:@"defbook.png"];
    [spinningWheel stopAnimating];
}

#pragma mark -
#pragma mark UIView animation delegate methods

- (void)animationFinished
{
    if ([delegate respondsToSelector:@selector(bookCellAnimationFinished:)])
    {
        [delegate bookCellAnimationFinished:self];
    }
}


#pragma mark -
#pragma mark Lay Everything Out

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize bookImageSize = _bookImage.image.size;
    CGSize ratingImageSize = _ratingImage.image.size;
    CGRect bounds = CGRectInset(self.contentView.bounds, 10.0, 10.0);
    
	//[_categoryName sizeToFit];
	[_bookTitle setLineBreakMode:UILineBreakModeWordWrap];
	[_bookTitle setNumberOfLines:2];

	[_bookAuthor setLineBreakMode:UILineBreakModeWordWrap];
	[_bookAuthor setNumberOfLines:2];

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
    
    if ( (bookImageSize.width <= bounds.size.width) &&
        (bookImageSize.height <= bounds.size.height) )
    {
        return;
    }
    
    if ( (ratingImageSize.width <= bounds.size.width) &&
        (ratingImageSize.height <= bounds.size.height) )
    {
        return;
    }
    
    // scale it down to fit
    CGFloat bhRatio = bounds.size.width / bookImageSize.width;
    CGFloat bvRatio = bounds.size.height / bookImageSize.height;
    CGFloat bratio = MIN(bhRatio, bvRatio);
    
    [_bookImage sizeToFit];
    CGRect iframe = _bookImage.frame;
    iframe.size.width = floorf(bookImageSize.width * bratio);
    iframe.size.height = floorf(bookImageSize.height * bratio);
    iframe.origin.x = floorf((bounds.size.width - iframe.size.width) * 0.5);
    iframe.origin.y = floorf((bounds.size.height - iframe.size.height) * 0.5);
    _bookImage.frame = iframe;
    
    // scale it down to fit
    CGFloat rhRatio = bounds.size.width / ratingImageSize.width;
    CGFloat rvRatio = bounds.size.height / ratingImageSize.height;
    CGFloat rratio = MIN(rhRatio, rvRatio);
    
    [_ratingImage sizeToFit];
    CGRect riframe = _ratingImage.frame;
    riframe.size.width = floorf(ratingImageSize.width * rratio);
    riframe.size.height = floorf(ratingImageSize.height * rratio);
    riframe.origin.x = floorf((bounds.size.width - riframe.size.width) * 0.5);
    riframe.origin.y = floorf((bounds.size.height - riframe.size.height) * 0.5);
    _ratingImage.frame = riframe;
	
}


@end
