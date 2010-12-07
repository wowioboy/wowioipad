//
//  LibraryGridCell.m
//  WOWIO
//
//  Created by Lawrence Leach on 9/10/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "LibraryGridCell.h"
#import "Library.h"
//#import "GridColors.h"

@implementation LibraryGridCell
@synthesize item, delegate;

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) aReuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: aReuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    _bookImage = [[UIImageView alloc] initWithFrame: CGRectMake(5, 5, 75, 108)];
	
    _bookTitle = [[UILabel alloc] initWithFrame: CGRectMake(85, 5, 100, 30)];
	_bookTitle.backgroundColor = [UIColor clearColor];
    _bookTitle.highlightedTextColor = [UIColor whiteColor];
	_bookTitle.textColor = [UIColor blackColor];
    _bookTitle.font = [UIFont boldSystemFontOfSize: 12.0];
    _bookTitle.adjustsFontSizeToFitWidth = YES;
    _bookTitle.minimumFontSize = 10.0;
	_bookTitle.lineBreakMode = UILineBreakModeWordWrap;
	_bookTitle.numberOfLines = 2;
	
    _bookAuthor = [[UILabel alloc] initWithFrame: CGRectMake(85, 30, 100, 20)];
	_bookAuthor.backgroundColor = [UIColor clearColor];
    _bookAuthor.highlightedTextColor = [UIColor whiteColor];
	_bookAuthor.textColor = [UIColor darkGrayColor];
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
    
    _ratingImage = [[UIImageView alloc] initWithFrame: CGRectMake(85, 75, 79, 19)];
	
	spinningWheel = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(27.0, 27.0, 20.0, 20.0)];
	spinningWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	spinningWheel.hidesWhenStopped = YES;
	[spinningWheel stopAnimating];
	
    self.backgroundColor = [UIColor clearColor];
    //self.backgroundColor = [UIColor colorWithWhite: 0.95 alpha: 1.0];
    self.contentView.backgroundColor = self.backgroundColor;
    //_categoryImage.backgroundColor = self.backgroundColor;
    //_categoryName.backgroundColor = self.backgroundColor;
    //_bookCount.backgroundColor = self.backgroundColor;
    
    [self.contentView addSubview: _bookImage];
    //[self.contentView addSubview: _bookTitle];
    //[self.contentView addSubview: _bookAuthor];
    //[self.contentView addSubview: _bookCategory];
    //[self.contentView addSubview: _ratingImage];
    [self.contentView addSubview:spinningWheel];
	
    return ( self );
}

- (void) dealloc
{
    [_bookImage release];
    [_ratingImage release];
    [_bookTitle release];
    [_bookAuthor release];
    [_bookCategory release];
	//[gridColor release];
    [super dealloc];
}


#pragma mark -
#pragma mark Public methods

- (void)setItem:(Library *)newItem
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
			_bookTitle.lineBreakMode = UILineBreakModeWordWrap;
			_bookTitle.numberOfLines = 2;
            _bookTitle.text = [item title];
			
			_bookAuthor.lineBreakMode = UILineBreakModeWordWrap;
			_bookAuthor.numberOfLines = 2;
            _bookAuthor.text = [item authorname];
			
            //_bookImage.image = [UIImage imageNamed:@"defbook.png"];
            _ratingImage.image = [UIImage imageNamed:@"ratings_11.png"];
			
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

- (void)bookItem:(Library *)item didLoadCover:(UIImage *)image
{
    _bookImage.image = image;
    [spinningWheel stopAnimating];
}

- (void)bookItem:(Library *)item couldNotLoadImageError:(NSError *)error
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
    //_bookImage.frame = iframe;
    
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
