//
//  BookGridCellDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 7/9/10.
//  Copyright 2010 WOWIO, Inc. All rights reserved.
//

@class BookGridCell;

@protocol BookGridCellDelegate

@required

@optional
- (void)bookCellAnimationFinished:(BookGridCell *)cell;

@end
