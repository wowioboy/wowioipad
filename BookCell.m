//
//  BookCell.m
//  WOWIO
//
//  Created by Lawrence Leach on 6/10/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "BookCell.h"
#import "Book.h"

@implementation BookCell
@synthesize bookJacket, bookRating, bookTitle, bookAuthor, bookCategory;
@synthesize item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

		bookJacket = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 84, 110)];
		bookJacket.clipsToBounds = YES;
		bookJacket.contentMode = UIViewContentModeScaleAspectFill;
		[self.contentView addSubview:bookJacket];
				
		bookRating = [[UIImageView alloc] initWithFrame:CGRectMake(112, 92, 143, 30)];
		bookRating.clipsToBounds = YES;
		bookRating.contentMode = UIViewContentModeScaleAspectFill;
		[self.contentView addSubview:bookRating];
		
		bookTitle = [[UILabel alloc] initWithFrame:CGRectMake(112, 20, 168, 21)];
		[bookTitle setFont:[UIFont boldSystemFontOfSize:17.0]];
		[bookTitle setTextColor:[UIColor darkGrayColor]];
		[bookTitle setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:bookTitle];
		
		bookAuthor = [[UILabel alloc] initWithFrame:CGRectMake(112, 39, 163, 21)];
		[bookAuthor setFont:[UIFont systemFontOfSize:14.0]];
		[bookAuthor setTextColor:[UIColor darkGrayColor]];
		[bookAuthor setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:bookAuthor];
		
		bookCategory = [[UILabel alloc] initWithFrame:CGRectMake(112, 58, 163, 21)];
		[bookCategory setFont:[UIFont systemFontOfSize:14.0]];
		[bookCategory setTextColor:[UIColor darkGrayColor]];
		[bookCategory setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:bookCategory];
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark -
#pragma mark Public methods

- (void)setItem:(Book *)newItem
{
    if (newItem != item)
    {
        [item release];
        item = nil;
        
        item = [newItem retain];
        
        if (item != nil)
        {
            bookTitle.text = [item title];
            bookAuthor.text = [item authorname];
			bookCategory.text = @"";
        }
    }
}

- (void)dealloc {
    [super dealloc];
	[bookCategory release];
	[bookTitle release];
	[bookAuthor release];
	[bookJacket release];
	[bookRating release];
}


@end
