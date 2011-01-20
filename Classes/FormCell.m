//
//  FormCell.m
//  iMogul
//
//  Created by Lawrence Leach on 4/21/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

#import "FormCell.h"


@implementation FormCell
@synthesize fldLabel, fldData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
        self.backgroundColor = [UIColor whiteColor];
		
		fldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 145, 20)];
		[fldLabel setTextColor:[UIColor blackColor]];
		[fldLabel setBackgroundColor:[UIColor clearColor]];
		[fldLabel setFont:[UIFont boldSystemFontOfSize:14]];
		[self.contentView addSubview:fldLabel];
		
		fldData = [[UITextField alloc] initWithFrame:CGRectMake(95, 8, 200, 20)];
		[fldData setBorderStyle:UITextBorderStyleNone];
		[fldData setTextColor:[UIColor lightGrayColor]];
		fldData.backgroundColor = [UIColor clearColor];
		[fldData setFont:[UIFont boldSystemFontOfSize:14]];
		[fldData setTextColor:[UIColor blackColor]];
		[fldData setClearsContextBeforeDrawing:YES];
		[fldData setClearsOnBeginEditing:YES];
		[self.contentView addSubview:fldData];
		
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
