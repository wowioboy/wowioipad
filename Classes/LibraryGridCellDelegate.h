//
//  LibraryGridCellDelegate.h
//  WOWIO
//
//  Created by Lawrence Leach on 9/10/10.
//  Copyright 2010 Pure Engineering. All rights reserved.
//

@class LibraryGridCell;

@protocol LibraryGridCellDelegate

@required

@optional
- (void)bookCellAnimationFinished:(LibraryGridCell *)cell;


@end
