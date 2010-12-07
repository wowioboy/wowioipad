//
//  NewReleasesGridCellDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 10/11/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//



@class NewReleasesGridCell;

@protocol NewReleasesGridCellDelegate

@required

@optional
- (void)bookCellAnimationFinished:(NewReleasesGridCell *)cell;

@end
