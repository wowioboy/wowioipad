//
//  FormCell.h
//  iMogul
//
//  Created by Lawrence Leach on 4/21/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FormCell : UITableViewCell {
	
	UILabel *fldLabel;
	UITextField *fldData;
}

@property(nonatomic, retain) UILabel *fldLabel;
@property(nonatomic, retain) UITextField *fldData;

@end
